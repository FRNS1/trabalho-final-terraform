terraform {
  backend "s3" {
    bucket         = "meu-bucket-terraform"  # Substitua pelo nome do seu bucket S3
    key            = "path/to/my/terraform-${terraform.workspace}.tfstate"  # Caminho do estado no bucket S3, incluindo o workspace
    region         = "us-east-1"  # Região do S3
    encrypt        = true  # Habilita criptografia do estado
    dynamodb_table = "terraform-lock"  # Nome da tabela DynamoDB para bloqueio de estado (opcional)
  }
}

module "fiap_lab" {
  source          = "./module"
  aws_region      = "us-east-1"

  # Variável diferenciada por ambiente
  number_of_nodes = terraform.workspace == "prod" ? 5 : 2  # Especifique a quantidade de nós para cada ambiente
}