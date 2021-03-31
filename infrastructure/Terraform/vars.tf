variable "AWS_REGION" {
}

variable "AMI" {
}

variable "DB_USERNAME"{

}

variable "DB_PASSWORD"{

}

variable "BUCKETNAME"{

}

variable "zone_id"{

}

variable "domain_name"{
    
}


variable "asg_policy_config" {
    type = map
    default = {
        scale_up_policy_name = "scale_up_policy"
        scale_down_policy_name  = "scale_down_policy"
        cooldown = "60"
        adjustment_type = "ChangeInCapacity"
        scale_up_adjustment = "1"
        scale_down_adjustemnt =  "-1"
    }
}

variable "cloudwatch_alarm_config" {
    type = map
    default = {
        scale_up_alarm_name = "scale_up_alarm"
        scale_down_alarm_name = "scale_down_alarm"
        scale_up_description =  "Scale-up if CPU > 5%"
        scale_down_description = "Scale-down if CPU < 3%"
        metric_name =  "CPUUtilization"
        namespace = "AWS/EC2"
        statistic = "Average"
        evaluation_periods = "2"
        period = "300"
        scale_up_comparison_operator = "GreaterThanThreshold"
        scale_down_comparison_operator = "LessThanThreshold"
        scale_up_cpu_threshold = "5"
        scale_down_cpu_threshold = "3"
    }
}