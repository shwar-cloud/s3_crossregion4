
#replication takes longer than expected
resource "aws_cloudwatch_metric_alarm" "replication_lag" {
  alarm_name          = "sclr-replication-lag-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ReplicationLatency"
  namespace           = "AWS/S3"
  period              = 300  # CloudWatch evaluates every 5 minutes 60 to 300
  statistic           = "Maximum"
  threshold           = 60   # triggers if replication takes more than 60 seconds
  alarm_description   = "Alarm when S3 replication latency exceeds 1 minute"

  dimensions = {
    BucketName = aws_s3_bucket.sclr_source.bucket
    }

  alarm_actions = [
    aws_sns_topic.sclr_replication_alert.arn
  ]
}


# alarm triggers immediately for single object fails to replicate.

resource "aws_cloudwatch_metric_alarm" "replication_failures" {
  alarm_name          = "sclr-replication-failed-operations"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2   #period changed to 2
  metric_name         = "ReplicationFailedOperations"
  namespace           = "AWS/S3"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when replication failures occur"

  dimensions = {
    BucketName = aws_s3_bucket.sclr_source.bucket
    RuleId = "ReplicateKMSOnly"
  }

  alarm_actions = [
    aws_sns_topic.sclr_replication_alert.arn
  ]
}
