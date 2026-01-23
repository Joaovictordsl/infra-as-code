# 1. A Role em si (Define que o EC2 pode usar esta identidade)
resource "aws_iam_role" "ecr_readonly_role" {
  name = "ec2-ecr-readonly-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 2. A Policy com o seu JSON (Define o que a role pode fazer)
resource "aws_iam_policy" "ecr_readonly_policy" {
  name        = "ECRReadOnlyPolicy"
  description = "Permite que a EC2 de um pull no ECR"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings"
        ]
        Resource = "*"
      }
    ]
  })
}

# 3. Anexar a Policy à Role
resource "aws_iam_role_policy_attachment" "attach_readonly" {
  role       = aws_iam_role.ecr_readonly_role.name
  policy_arn = aws_iam_policy.ecr_readonly_policy.arn
}
