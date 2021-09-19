resource "aws_s3_bucket" "s3bucket" {

  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Name = var.bucket_name
  }

}
// Application user
resource "aws_iam_user" "s3bucketwriter" {
  name = var.s3_ftp_user_name
  tags = {
    Project = "ftp"
  }
}

resource "aws_iam_access_key" "s3bucketwriter" {
  user = aws_iam_user.s3bucketwriter.name
}

# Create user policy and attach directly to user
resource "aws_iam_user_policy" "s3bucketwriter" {
  name = "grant_${var.s3_ftp_user_name}_access"
  user = aws_iam_user.s3bucketwriter.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1500494355000",
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject",
                "s3:Put*",
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.s3bucket.bucket}",
                "arn:aws:s3:::${aws_s3_bucket.s3bucket.bucket}/*"

            ]
        }
    ]
}
EOF
}



#module "sftp" {
#  source = "./sftp-endpoint"
#  transfer_server_name       = var.transfer_server_name
#  transfer_server_user_names = [var.sftp_user_name_1]
#  transfer_server_ssh_keys   = [var.sftp_user_pubkey_1]
#  bucket_name                = aws_s3_bucket.s3bucket.bucket
#}

