resource "aws_instance" "terraform-ec2" {
    ami = "ami-02b8269d5e85954ef"
    key_name = "august-2025"
    instance_type = "t2.micro"
    tags = {
        Name = "Ec2-terraform"
    }
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "ravi03122026"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}
