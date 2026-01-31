# סינון של אזורי זמינות (Availability Zones) שזמינים באזור שלנו
data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"

  name = var.vpc_name
  cidr = "10.0.0.0/16"

  # שימוש דינמי ב-3 אזורי זמינות (לשרידות גבוהה)
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # הגדרות NAT Gateway (עולה כסף ב-AWS!)
  # enable_nat_gateway = true -> מאפשר לשרתים פרטיים לצאת לאינטרנט
  # single_nat_gateway = true -> חוסך עלויות במעבדה (NAT אחד לכולם במקום אחד לכל AZ)
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  # הגדרות DNS נדרשות ל-EKS
  enable_dns_hostnames = true
  enable_dns_support   = true

  # תיוג קריטי ל-EKS (כדי שידע איפה לשים Load Balancers)
  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = "lab-devops"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29" # גרסה יציבה ומומלצת

  # חיבור הקלאסטר ל-VPC שיצרנו למעלה
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets # ה-Nodes יושבים ברשת פרטית בלבד!

  # גישה לקלאסטר
  cluster_endpoint_public_access = true # כדי שתוכל להריץ kubectl מהמחשב בבית

  # הענקת הרשאות אדמין למי שיצר את הקלאסטר (אתה)
  # בגרסאות חדשות של המודול (v20+) זה חובה כדי למנוע נעילה
  enable_cluster_creator_admin_permissions = true

# הגדרת השרתים (Nodes)
  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      # הופך את השרתים ל-Spot Instances
      capacity_type = "SPOT" 

      # t3.medium הוא המינימום המומלץ ל-EKS
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1 
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# יצירת Repository לאפליקציה שלנו
resource "aws_ecr_repository" "app_repo" {
  name                 = "lab-devops-app"
  image_tag_mutability = "MUTABLE"

  # השורה החדשה שפותרת את הבעיה:
  force_delete = true 

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}