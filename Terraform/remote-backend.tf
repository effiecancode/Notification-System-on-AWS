# store the terraform state file in s3 and lock with dynamodb
terraform {
  backend "s3" {
    bucket         = "prj-remote-backend"
    key            = "Contract_Management_V1-main/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "cmsteam5-state-lock"
  }
}