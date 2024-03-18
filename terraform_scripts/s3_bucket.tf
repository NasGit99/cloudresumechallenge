#Creating S3 Bucket

resource "aws_s3_bucket" "resume_bucket" {
  bucket = "ntcloudresume"


  tags = {
    Name        = "Cloud Resume Bucket"
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

#Establishing ACL for Bucket

resource "aws_s3_bucket_acl" "resume_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.resume_bucket_ownership]

  bucket = aws_s3_bucket.resume_bucket.id
  acl    = "private"
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
}


locals {
  object_source_2 = "${path.module}/../website/index.html"
}

resource "aws_s3_object" "file_upload_2" {
  bucket      = aws_s3_bucket.resume_bucket.id
  source      = local.object_source_2
  source_hash = filemd5(local.object_source_2)
  key = "index.html"
}



locals {
  object_source_3 = "${path.module}/../website/styles.css"
}

resource "aws_s3_object" "file_upload_3" {
  bucket      = aws_s3_bucket.resume_bucket.id
  source      = local.object_source_3
  source_hash = filemd5(local.object_source_3)
  key = "styles.css"
}




resource "aws_s3_bucket_versioning" "resume_bucket_versioning" {
  bucket = aws_s3_bucket.resume_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}