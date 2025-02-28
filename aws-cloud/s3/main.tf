resource "aws_s3_bucket" "test-bucket" {
  bucket = "testing"

  tags = {
    Name = "My-bucket"
    Environment = "Dev"
  }
}
