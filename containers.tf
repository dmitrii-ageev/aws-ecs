# Repository

resource "aws_ecr_repository" "smtp_proxy" {
  name                 = "smtp_proxy"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "smtp_proxy_policy" {
  repository = "${aws_ecr_repository.smtp_proxy.name}"
  policy     = "${file("policy/ecr.json")}"

  provisioner "local-exec" {
    command = "scripts/docker_build_smtp_proxy.sh ${aws_ecr_repository.smtp_proxy.repository_url}"
  }
}

resource "aws_ecr_repository" "smtp_auth" {
  name                 = "smtp_auth"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "smtp_auth_policy" {
  repository = "${aws_ecr_repository.smtp_auth.name}"
  policy     = "${file("policy/ecr.json")}"

  provisioner "local-exec" {
    command = "scripts/docker_build_smtp_auth.sh ${aws_ecr_repository.smtp_auth.repository_url}"
  }
}

