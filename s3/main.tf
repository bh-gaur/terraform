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