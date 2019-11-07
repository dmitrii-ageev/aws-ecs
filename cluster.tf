# Role and policy
## EC2
resource "aws_iam_role" "ecs_service_role" {
  name               = "ecs_service_role"
  assume_role_policy = "${file("policy/ec2.json")}"
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_attachment" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

## ECS
resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecs_instance_role"
  assume_role_policy = "${file("policy/ecs.json")}"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  path = "/"
  role = aws_iam_role.ecs_instance_role.id
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

# ELB

resource "aws_elb" "ecs_load_balancer" {
  name = "ecs-load-balancer"
  // security_groups     = ["${aws_security_group.test_public_sg.id}"]
  subnets = [aws_subnet.orion_sn.id]

  listener {
    instance_port     = 25
    instance_protocol = "TCP"
    lb_port           = 25
    lb_protocol       = "TCP"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:25"
    interval            = 30
  }
}

# Auto-Scaling
resource "aws_launch_configuration" "ecs_launch_configuration" {
  name                        = "ecs_launch_configuration"
  image_id                    = data.aws_ami.latest_ecs.id
  instance_type               = "t2.small"
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.id
  associate_public_ip_address = "true"
}

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name                 = "ecs_autoscaling_group"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = [aws_subnet.orion_sn.id]
  launch_configuration = aws_launch_configuration.ecs_launch_configuration.name
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.ecs_load_balancer.name]
}

# Cluster
resource "aws_ecs_cluster" "orion_cc" {
  name = "orion_cc"

  tags = {
    Name      = "Containers cluster",
    Temporary = "Yes"
  }
}

resource "aws_ecs_task_definition" "smtp_proxy_task" {
  family = "smtp_proxy_task"
  container_definitions = templatefile("task-definitions/smtp-proxy.json",
    {
      proxy_image = aws_ecr_repository.smtp_proxy.repository_url,
      auth_image  = aws_ecr_repository.smtp_auth.repository_url
  })
}


resource "aws_ecs_service" "smtp_proxy_service" {
  name            = "smtp_proxy_service"
  cluster         = aws_ecs_cluster.orion_cc.id
  task_definition = aws_ecs_task_definition.smtp_proxy_task.arn

  iam_role      = aws_iam_role.ecs_service_role.arn
  launch_type   = "EC2"
  desired_count = 1

  scheduling_strategy = "REPLICA"

  load_balancer {
    elb_name       = aws_elb.ecs_load_balancer.name
    container_port = 80
    container_name = "nginx-smtp-proxy"
  }
}

