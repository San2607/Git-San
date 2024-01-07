terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }
  backend "s3" {
    bucket = "api-gateway-lambda-dynamodb" # change to name of your bucket
    region = "us-west-1"                   # change to your region
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_dynamodb_table" "questions" {
  name           = "questions"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
