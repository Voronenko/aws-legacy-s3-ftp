data "aws_s3_bucket" "sftp_bucket" {
  bucket = var.bucket_name
}

data "aws_iam_policy_document" "transfer_server_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "transfer_server_assume_policy" {
  # https://docs.aws.amazon.com/transfer/latest/userguide/users-policies.html
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      data.aws_s3_bucket.sftp_bucket.arn,
      "${data.aws_s3_bucket.sftp_bucket.arn}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObjectVersion",
      "s3:GetObjectACL",
      "s3:PutObjectACL"
    ]

    resources = [
      "${data.aws_s3_bucket.sftp_bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "transfer_scale_down_policy" {
  # https://docs.aws.amazon.com/transfer/latest/userguide/users-policies.html
  statement {
    #    sid = "AllowListingOfUserFolder"

    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::$${transfer:HomeBucket}"
    ]

    condition {
      test = "StringLike"
      values = [
        "$${transfer:HomeFolder}*",
        "$${transfer:HomeFolder}"
      ]
      variable = "s3:prefix"
    }
  }

  //TODO: is it needed?
  statement {
    #    sid = "AWSTransferRequirements"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]
    resources = [
      "*"
    ]
  }


  statement {
    //    sid = "HomeDirObjectAccess",
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObjectVersion",
      "s3:DeleteObject",
      "s3:GetObjectVersion",
      "s3:GetObjectACL",
      "s3:PutObjectACL"
    ]

    resources = [
      "arn:aws:s3:::$${transfer:HomeDirectory}*"
    ]
  }
}

data "aws_iam_policy_document" "transfer_server_to_cloudwatch_assume_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "transfer_server_role" {
  name               = "${var.transfer_server_name}-transfer_server_role"
  assume_role_policy = data.aws_iam_policy_document.transfer_server_assume_role.json
  tags = {
    Project = "ftp"
  }
}

resource "aws_iam_role_policy" "transfer_server_policy" {
  name   = "${var.transfer_server_name}-transfer_server_policy"
  role   = aws_iam_role.transfer_server_role.name
  policy = data.aws_iam_policy_document.transfer_server_assume_policy.json
}

resource "aws_iam_role_policy" "transfer_server_to_cloudwatch_policy" {
  name   = "${var.transfer_server_name}-transfer_server_to_cloudwatch_policy"
  role   = aws_iam_role.transfer_server_role.name
  policy = data.aws_iam_policy_document.transfer_server_to_cloudwatch_assume_policy.json
}

resource "aws_transfer_server" "transfer_server" {
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.transfer_server_role.arn

  tags = {
    NAME    = var.transfer_server_name
    Project = "ftp"
  }
}

resource "aws_transfer_user" "transfer_server_user" {
  count          = length(var.transfer_server_user_names)
  server_id      = aws_transfer_server.transfer_server.id
  user_name      = element(var.transfer_server_user_names, count.index)
  role           = aws_iam_role.transfer_server_role.arn
  home_directory = "/${var.bucket_name}/${element(var.transfer_server_user_names, count.index)}"
  policy         = data.aws_iam_policy_document.transfer_scale_down_policy.json

  tags = {
    Name    = element(var.transfer_server_user_names, count.index)
    Project = "ftp"
  }

}

resource "aws_transfer_ssh_key" "transfer_server_ssh_key" {
  count = length(var.transfer_server_user_names)

  server_id = aws_transfer_server.transfer_server.id
  user_name = element(aws_transfer_user.transfer_server_user.*.user_name, count.index)
  body      = element(var.transfer_server_ssh_keys, count.index)
}
