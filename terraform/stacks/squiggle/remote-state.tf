data "terraform_remote_state" "quri" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = "quri-tf-state-us-east-1"
    key    = "stacks/quri.tfstate"
  }
}

