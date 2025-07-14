resource "aws_s3_bucket" "my_bucket" {
  bucket = "baekgwa-blog-s3-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "my_bucket_public" {
  bucket                  = aws_s3_bucket.my_bucket.id
  block_public_policy     = false       # 정책을 통한 퍼블릭 허용
  restrict_public_buckets = false       # 퍼블릭 정책 자체를 차단하지 않음
  block_public_acls       = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
      },
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.my_bucket_public]
}
