# store the terraform state file in s3 and lock with dynamodb
terraform {
  backend "s3" {
    bucket         = "notificationsystem-bucket-london"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "NotificationSystem-state-lock"
  }
}