terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "~> 3.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "minioadmin"
  secret_key                  = "minioadmin123"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "http://minio:9000" 
  }
}
provider "minio" {
  minio_server   = "minio:9000"
  minio_user     = "minioadmin"
  minio_password = "minioadmin123"
  minio_ssl      = false
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "kind-mycluster"  
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "kind-mycluster"  
  }
}