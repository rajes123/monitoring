resource "aws_s3_bucket" "terraform-learning" {
    bucket = "terraform-config90"

     force_destroy = true

    tags = {
      name = "terraform-config90"
      envorment = "dev"
    }
}


# Allow public access settings needed for this example
resource "aws_s3_bucket_public_access_block" "terraform-bucket-access" {
  bucket = aws_s3_bucket.terraform-learning.id

  block_public_acls = true
  ignore_public_acls = true
  block_public_policy = false
  restrict_public_buckets = false

}

data "aws_iam_policy_document" "allow_public_read" {
  statement {
    sid    = "AllowPublicRead"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.terraform-learning.arn}/*"
    ]
  }
}

# Create bucket policy to allow GetObject
resource "aws_s3_bucket_policy" "terraform-bucket-policy" {
  bucket = aws_s3_bucket.terraform-learning.id
  depends_on = [
    aws_s3_bucket_public_access_block.terraform-bucket-access
  ]
  policy = data.aws_iam_policy_document.allow_public_read.json
}

resource "aws_s3_bucket_versioning" "terraform-bucket-versioning" {
    bucket = aws_s3_bucket.terraform-learning.id
    versioning_configuration {
      status = "Enabled"
    }
  
}

provider "aws" {
  region = "ap-south-1"
}