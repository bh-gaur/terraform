provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.92.0"
    }
  }
}

resource "aws_s3_bucket" "my_bucket-1" {
  bucket = "${var.name}-source"
}

resource "aws_s3_bucket" "my_bucket-2" {
  bucket = "${var.name}-destination"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-s3-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_s3_attach" {
  name       = "lambda-s3-access"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_lambda_function" "backup_lambda" {
  function_name = "s3-backup-lambda"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  timeout       = 10

  filename         = "${path.module}/lambda_function_payload.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function_payload.zip")

  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.my_bucket-2.bucket
    }
  }
}

resource "aws_s3_bucket_notification" "trigger" {
  bucket = aws_s3_bucket.my_bucket-1.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.backup_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backup_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.my_bucket-1.arn
}