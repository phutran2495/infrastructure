
# 11. Create IAM Role
resource "aws_iam_role" "ec2-role" {
  name               = "ec2-role"
  description        = "IAM role for webapp ec2 instance"
  assume_role_policy = file("iam-policy/ec2-assume-policy.json")
}

# 12. Create IAM Policy    
resource "aws_iam_policy" "s3-policy" {
  name        = "s3-policy"
  description = "Policy to allow services to access S3 bucket"
  policy      = file("iam-policy/s3-cloudwatch-policy.json")
}

# 13. Attach policy to role created
resource "aws_iam_role_policy_attachment" "iam-s3-attach" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = aws_iam_policy.s3-policy.arn
}

# 14. Create IAM instance profile to link role with EC2 instance
resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-access-s3-codedeploy"
  role = aws_iam_role.ec2-role.name
}

resource "aws_key_pair" "csyekeypair" {
  key_name = "csye6225keypair"
  public_key = "${file("~/csyekeypair.pub")}"
}


resource "aws_launch_configuration" "webapp_lc"{
  name = "webapp-lc"
  image_id = var.AMI
  instance_type               = "t2.micro"
  iam_instance_profile =      aws_iam_instance_profile.ec2-profile.name
  security_groups = [aws_security_group.application.id]
  associate_public_ip_address = true
  root_block_device  {
    volume_size                = 20
    volume_type                = "gp2"
    delete_on_termination      = true
  }
  key_name                    = aws_key_pair.csyekeypair.key_name
  user_data            = <<-EOF
                          #!/bin/bash
                          sudo echo "#!/bin/bash" > /etc/profile.d/envvars.sh
                          sudo echo "export dbusername=${var.DB_USERNAME} ">> /etc/profile.d/envvars.sh
                          sudo echo "export dbpassword=${var.DB_PASSWORD} ">> /etc/profile.d/envvars.sh
                          sudo echo "export bucketname=${var.BUCKETNAME} ">> /etc/profile.d/envvars.sh
                          sudo echo "export dbendpoint=${aws_db_instance.mysql.endpoint} ">> /etc/profile.d/envvars.sh
                          sudo echo "export bucketregion=${var.AWS_REGION} ">> /etc/profile.d/envvars.sh
                          chmod +x /etc/profile.d/envvars.sh

                        EOF
 
}

resource "aws_autoscaling_group" "webapp_asg" {
  name = "webapp_asg"
  desired_capacity = 3
  max_size = 5
  min_size = 2
  health_check_grace_period = 500
  launch_configuration = aws_launch_configuration.webapp_lc.name
  vpc_zone_identifier = [ aws_subnet.main-public-1.id,aws_subnet.main-public-2.id, aws_subnet.main-public-3.id ]
  target_group_arns = [aws_lb_target_group.webapptg.arn]
  
  tag {
    key                 = "Name"
    value               = "cicd"
    propagate_at_launch = true
  }

}


## Scaling Policy
resource "aws_autoscaling_policy" "scale_up_policy" {
  name = var.asg_policy_config.scale_up_policy_name
  scaling_adjustment = var.asg_policy_config.scale_up_adjustment
  adjustment_type = var.asg_policy_config.adjustment_type
  cooldown = var.asg_policy_config.cooldown
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name = var.asg_policy_config.scale_down_policy_name
  scaling_adjustment = var.asg_policy_config.scale_down_adjustemnt
  adjustment_type = var.asg_policy_config.adjustment_type
  cooldown = var.asg_policy_config.cooldown
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name = var.cloudwatch_alarm_config.scale_up_alarm_name
  comparison_operator = var.cloudwatch_alarm_config.scale_up_comparison_operator
  evaluation_periods = var.cloudwatch_alarm_config.evaluation_periods
  metric_name = var.cloudwatch_alarm_config.metric_name
  namespace = var.cloudwatch_alarm_config.namespace
  period = var.cloudwatch_alarm_config.period
  statistic = var.cloudwatch_alarm_config.statistic
  threshold = var.cloudwatch_alarm_config.scale_up_cpu_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }

  alarm_description = var.cloudwatch_alarm_config.scale_up_description
  alarm_actions = [aws_autoscaling_policy.scale_up_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name = var.cloudwatch_alarm_config.scale_down_alarm_name
  comparison_operator = var.cloudwatch_alarm_config.scale_down_comparison_operator
  evaluation_periods = var.cloudwatch_alarm_config.evaluation_periods
  metric_name = var.cloudwatch_alarm_config.metric_name
  namespace = var.cloudwatch_alarm_config.namespace
  period = var.cloudwatch_alarm_config.period
  statistic = var.cloudwatch_alarm_config.statistic
  threshold = var.cloudwatch_alarm_config.scale_down_cpu_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }

  alarm_description = var.cloudwatch_alarm_config.scale_down_description
  alarm_actions = [aws_autoscaling_policy.scale_down_policy.arn]
}

