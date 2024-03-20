#Creating S3 Bucket

resource "aws_s3_bucket" "resume_bucket" {
  bucket = "www.ntcloudresume.com"


  tags = {
    Name        = "Subdomain"
    Environment = "DEV"
  }
}

resource "aws_s3_bucket" "resume_bucket_root" {
  bucket = "ntcloudresume.com"


  tags = {
    Name        = "Root Domain"
    Environment = "DEV"
  }
}


#Creating Ownership Controls

resource "aws_s3_bucket_ownership_controls" "resume_bucket_ownership" {
  bucket = aws_s3_bucket.resume_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "resume_bucket_public_access" {
  bucket = aws_s3_bucket.resume_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


#Establishing ACL for Bucket

resource "aws_s3_bucket_acl" "resume_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.resume_bucket_ownership]

  bucket = aws_s3_bucket.resume_bucket.id
  acl    = "public-read"
}

#Uploading website files to S3 Bucket. Will condense code down later to upload all files with less code

locals {
  object_source = "${path.module}/../website/avatar.png"
}

resource "aws_s3_object" "file_upload" {
  bucket      = aws_s3_bucket.resume_bucket.id
  source      = local.object_source
  source_hash = filemd5(local.object_source)
  key = "avatar.png"
  content_type = "image/png"
}


locals {
  object_source_2 = "${path.module}/../website/index.html"
}

resource "aws_s3_object" "file_upload_2" {
  bucket      = aws_s3_bucket.resume_bucket.id
  source      = local.object_source_2
  source_hash = filemd5(local.object_source_2)
  key = "index.html"
  content_type = "text/html"
}

locals {
  object_source_3 = "${path.module}/../website/styles.css"
}

resource "aws_s3_object" "file_upload_3" {
  bucket      = aws_s3_bucket.resume_bucket.id
  source      = local.object_source_3
  source_hash = filemd5(local.object_source_3)
  key = "styles.css"
  content_type = "text/css"
}

#Bucket versioning
resource "aws_s3_bucket_versioning" "resume_bucket_versioning" {
  bucket = aws_s3_bucket.resume_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Bucket Policy To Access Objects In Bucket

resource "aws_s3_bucket_policy" "resume_bucket_policy" {
  bucket = aws_s3_bucket.resume_bucket.id
  policy = data.aws_iam_policy_document.resume_bucket_policy.json
}

data "aws_iam_policy_document" "resume_bucket_policy" {
 
 statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.account.account_id]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.resume_bucket.arn,
      "${aws_s3_bucket.resume_bucket.arn}/*"
    ]
 }
 statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.resume_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_subdomain_origin_access.iam_arn]
    }
  }
}

#Static website set up for Root Bucket


resource "aws_s3_bucket_website_configuration" "resume_bucket_static" {
  bucket = aws_s3_bucket.resume_bucket_root.id

redirect_all_requests_to {
  host_name = "www.ntcloudresume.com"
  protocol = "https"
}


}