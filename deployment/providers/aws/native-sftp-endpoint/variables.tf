variable "bucket_name" {
}

variable "transfer_server_name" {
  default = "aws_legacy_s3_ftp"
}

variable "transfer_server_user_names" {
  description = "User name(s) for SFTP server"
  type        = list(string)
}

variable "transfer_server_ssh_keys" {
  description = "SSH Key(s) for transfer server user(s)"
  type        = list(string)
}
