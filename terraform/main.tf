
module "networking" {
  source         = "./modules/networking"
  region         = var.region
  az-2           = var.az-2
  az-1           = var.az-1
  pub-sub-cidr   = var.public-subnet-cidr-1
  pub-sub-cidr-2 = var.public-subnet-cidr-2
  priv-sub-cidr  = var.private-subnet-cidr
  vpc-cidr       = var.vpc-cidr
}

module "ecs" {
  source        = "./modules/ecs"
  region = var.region
  app_password = var.app_password
  alb-target-group = module.alb.alb-target-group
  public-subnet = module.networking.public-subnet
  public-subnet-2 = module.networking.public-subnet-2
  alb-sg = module.alb.alb-sg 
  my-vpc = module.networking.my-vpc
  alb-listener-443 = module.alb.alb-listener-443
  image_tag = var.image_tag

}

module "alb" {
  source = "./modules/alb"
  my-vpc = module.networking.my-vpc
  acm-cert-arn = module.acm.acm-cert-arn
  public-subnet = module.networking.public-subnet
  public-subnet-2 = module.networking.public-subnet-2
}


module "acm" {
  source = "./modules/acm"
}

module "dns"{
  source = "./modules/dns"
  alb-url = module.alb.alb-url
  alb-zone-id = module.alb.alb-zone-id 
  alb-dns = module.alb.alb-dns 
}

output "alb-url" {
  value = module.alb.alb-url
}