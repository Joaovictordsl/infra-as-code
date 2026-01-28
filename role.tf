# 1. Criar a Role que será assumida pela EC2
resource "aws_iam_role" "ecr_readonly_role" {
  name = "App-ECR-ReadOnly-Role"

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

# 2. Criar a Policy com permissões de LEITURA DO ECR (O que a EC2 faz)
resource "aws_iam_policy" "ecr_readonly_policy" {
  name        = "ECRReadOnlyPolicy"
  description = "Permite que a EC2 realize pull de imagens do ECR"
  
  policy = jsonencode({
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
        Resource = "*" # Permite ler qualquer repositório ECR
      }
    ]
  })
}

# 3. Anexar a Policy à Role
resource "aws_iam_role_policy_attachment" "attach_readonly" {
  role       = aws_iam_role.ecr_readonly_role.name
  policy_arn = aws_iam_policy.ecr_readonly_policy.arn
}

# 4. Criar o Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-instance-profile"
  role = aws_iam_role.ecr_readonly_role.name
}
