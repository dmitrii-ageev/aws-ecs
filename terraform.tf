terraform {
  backend "s3" {
    bucket = "dageev.terraform"
    key    = "orion/test-assignment"
    region = "us-east-1"
  }
}
