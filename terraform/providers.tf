terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # בשלב הראשון נעבוד עם State מקומי כדי לוודא שהכל רץ.
  # בהמשך, נעביר את זה ל-S3 (Remote State) כמו מקצוענים.
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.region
}