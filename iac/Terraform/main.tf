provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"
  my_ip  = var.my_ip
}

module "application" {
  source                       = "./modules/application"
  vpc_id                       = module.network.vpc_id
  public_subnet_1_id           = module.network.public_subnet_1_id
  public_subnet_2_id           = module.network.public_subnet_2_id
  private_subnet_1_id          = module.network.private_subnet_1_id
  private_subnet_2_id          = module.network.private_subnet_2_id
  alb_security_group_id        = module.network.alb_security_group_id
  web_server_security_group_id = module.network.web_server_security_group_id
  backend_security_group_id    = module.network.backend_security_group_id
  instance_type                = var.app_instance_type
  ami_id                       = data.aws_ami.ubuntu.id
  key_name                     = var.app_key_name
}

module "database" {
  source                     = "./modules/database"
  private_subnet_1_id        = module.network.private_subnet_1_id
  database_security_group_id = module.network.database_security_group_id
  instance_type              = var.db_instance_type
  ami_id                     = data.aws_ami.ubuntu.id
  key_name                   = var.db_key_name
}

module "storage" {
  source = "./modules/storage"
}
