# resource "aws_s3_bucket" "tebucket" {
#   bucket = "testing"

#   tags = {
#     Name = "My-bucket"
#     Environment = "Dev"
#   }
# }
resource "aws_s3_bucket" "example" {
  bucket = "bhola-bucket"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.example.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.example.arn
}