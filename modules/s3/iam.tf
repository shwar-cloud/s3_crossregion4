# IAM Role for S3 Replication
resource "aws_iam_role" "sclr_replication_role" {
  name = "sclr_replication_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for replication
resource "aws_iam_policy" "sclr_replication_policy" {
  name = "sclr_replication_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Read access to source bucket
      {
        Sid    = "ProvideReadAccessToSourceBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetReplicationConfiguration"
        ]
        Resource = aws_s3_bucket.sclr_source.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention",
          "s3:GetObjectLegalHold"
        ]
        Resource = "${aws_s3_bucket.sclr_source.arn}/*"
      },

      # Write to destination bucket
      {
        Sid    = "AllowReplicationToDestinationBucket"
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:GetObjectVersionTagging",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ]
        Resource = "${aws_s3_bucket.sclr_destination.arn}/*"
        Condition = {
          StringLikeIfExists = {
            "s3:x-amz-server-side-encryption" = ["aws:kms", "AES256"]
          }
        }
      },

      #Decrypt source objects with KMS
      {
        Sid    = "AllowDecryptOfSourceObjects"
        Effect = "Allow"
        Action = ["kms:Decrypt"]
        Resource = aws_kms_key.sclr_source_kms.arn
        Condition = {
          StringLike = {
            "kms:ViaService" = "s3.${var.source_region}.amazonaws.com"
          }
        }
      },

      # Encrypt destination objects with KMS
      {
        Sid    = "AllowEncryptOfDestinationObjects"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ]
        Resource = aws_kms_key.sclr_destination_kms.arn
        Condition = {
          StringLike = {
            "kms:ViaService" = "s3.${var.destination_region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "replication_attachment" {
  role       = aws_iam_role.sclr_replication_role.name
  policy_arn = aws_iam_policy.sclr_replication_policy.arn
}