# Output our important values
output "s3_ftp_user" {
  value = aws_iam_access_key.s3bucketwriter.user
}
output "s3_ftp_user_id" {
  value = aws_iam_access_key.s3bucketwriter.id
}
output "s3_ftp_user_secret" {
  value     = aws_iam_access_key.s3bucketwriter.secret
  sensitive = true
}

output "s3_ftp_user_bucket_name" {
  value = aws_s3_bucket.s3bucket.bucket
}

output "s3_ftp_user_bucket_arn" {
  value = aws_s3_bucket.s3bucket.arn
}

#output "s3_ftp_user_transfer_server_id" {
#  value = module.sftp.transfer_server_id_apsignals
#}
#
#output "s3_ftp_user_transfer_server_endpoints" {
#  value = module.sftp.transfer_server_endpoint_apsignals
#}
