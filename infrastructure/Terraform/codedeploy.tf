resource "aws_iam_role" "CodeDeployServiceRole" {
  name               = "CodeDeployServiceRole"
  assume_role_policy = file("iam-policy/codedeploy-assume.json")
}

resource "aws_iam_policy" "CodeDeployPolicy" {
  name        = "CodeDeployPolicy"
  policy      = file("iam-policy/codedeploy-policy.json")
}

resource "aws_iam_role_policy_attachment" "codedeploy-ec2-attach" {
  role       = aws_iam_role.CodeDeployServiceRole.name
  policy_arn = aws_iam_policy.CodeDeployPolicy.arn
}



resource "aws_codedeploy_app" "csye6225-webapp" {
  compute_platform = "Server"
  name             = "csye6225-webapp"
}


resource "aws_codedeploy_deployment_group" "csye6225-deployment-group" {
  app_name               = aws_codedeploy_app.csye6225-webapp.name
  deployment_group_name  = "csye6225-webapp-deployment"
  service_role_arn       = aws_iam_role.CodeDeployServiceRole.arn
  deployment_config_name = "CodeDeployDefault.OneAtATime"
  autoscaling_groups = [aws_autoscaling_group.webapp_asg.name]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type = "IN_PLACE"
  }

  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.webapptg.name
    }
  }

  ec2_tag_filter {
    key   = "Name"
    type  = "KEY_AND_VALUE"
    value = "cicd"
  }

  auto_rollback_configuration {
    enabled = false
  }

}




# resource "aws_codedeploy_app" "csye6225-lambda" {
#   compute_platform = "Lambda"
#   name             = "csye6225-lambda"
# }


# resource "aws_codedeploy_deployment_group" "csye6225-lambda-deployment-group" {
#   app_name               = aws_codedeploy_app.csye6225-lambda.name
#   deployment_group_name  = "csye6225-lambda-deployment"
#   service_role_arn       = aws_iam_role.CodeDeployServiceRole.arn
#   deployment_config_name = "CodeDeployDefault.OneAtATime"
#   deployment_style {
#     deployment_type = "IN_PLACE"
#   }

#   auto_rollback_configuration {
#     enabled = false
#   }

# }


