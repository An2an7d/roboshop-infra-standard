module "vpn_sg" {
  source = "../../terraform-aws-securitygroup"
  sg_name = "${var.project_name}-vpn"
  project_name = var.project_name
  sg_description = "allowing all ports from my home"
#   sg_ingress_rules = var.sg_ingress_rules
  vpc_id = data.aws_vpc.default.id
   common_tags = merge(
    var.common_tags,
    {
        Component = "VPN",
        Name = "roboshop-vpn"
    }
  )
}

module "mongodb_sg" {
  source = "../../terraform-aws-securitygroup"
  sg_name = "mongodb"
  project_name = var.project_name
  sg_description = "allowing traffic from catalogue, user and vpn"
#   sg_ingress_rules = var.sg_ingress_rules
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = merge(
    var.common_tags,
    {
        Component = "MongoDB",
        Name = "MongoDB"
    }
  )
}

module "catalogue_sg" {
  source = "../../terraform-aws-securitygroup"
  sg_name = "catalogue"
  project_name = var.project_name
  sg_description = "allowing traffic"
#   sg_ingress_rules = var.sg_ingress_rules
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = merge(
    var.common_tags,
    {
        Component = "Catalogue",
        Name = "Catalogue"
    }
  )
}

module "web_sg" {
  source = "../../terraform-aws-securitygroup"
  sg_name = "web"
  project_name = var.project_name
  sg_description = "allowing traffic"
#   sg_ingress_rules = var.sg_ingress_rules
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = merge(
    var.common_tags,
    {
        Component = "Web"
    }
  )
}

module "app_alb_sg" {
  source = "../../terraform-aws-securitygroup"
  sg_name = "App-ALB"
  project_name = var.project_name
  sg_description = "allowing traffic"
#   sg_ingress_rules = var.sg_ingress_rules
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = merge(
    var.common_tags,
    {
        Component = "APP",
        Name = "App-ALB"
    }
  )
}

module "web_alb_sg" {
  source = "../../terraform-aws-securitygroup"
  sg_name = "Web-ALB"
  project_name = var.project_name
  sg_description = "allowing traffic"
#   sg_ingress_rules = var.sg_ingress_rules
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = merge(
    var.common_tags,
    {
        Component = "Web",
        Name = "Web-ALB"
    }
  )
}

resource "aws_security_group_rule" "vpn" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
#   ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.vpn_sg.security_group_id
}

# This is allowing connections from all catalogue instances to mongodb
resource "aws_security_group_rule" "mongodb_catalogue" {
  type              = "ingress"
  description = "Allowing port number 27017 from catalogue"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  source_security_group_id =module.catalogue_sg.security_group_id
  security_group_id = module.mongodb_sg.security_group_id
}

# This is allowing traffic from vpn on port number 22 for trouble shooting
resource "aws_security_group_rule" "mongodb_vpn" {
  type              = "ingress"
  description = "allowing port number 22 from vpn"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.mongodb_sg.security_group_id
}

resource "aws_security_group_rule" "catalogue_vpn" {
  type              = "ingress"
  description = "allowing port number 22 from vpn"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.catalogue_sg.security_group_id
}

resource "aws_security_group_rule" "catalogue_app_alb" {
  type              = "ingress"
  description = "Allowing port number 8080 from app alb"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb_sg.security_group_id
  security_group_id = module.catalogue_sg.security_group_id
}

resource "aws_security_group_rule" "app_alb_vpn" {
  type              = "ingress"
  description = "allowing port number 80 from vpn"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.app_alb_sg.security_group_id
}

resource "aws_security_group_rule" "app_alb_web" {
  type              = "ingress"
  description = "allowing port number 80 from web"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web_sg.security_group_id
  security_group_id = module.app_alb_sg.security_group_id
}

resource "aws_security_group_rule" "web_vpn" {
  type              = "ingress"
  description = "allowing port number 80 from vpn"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.web_sg.security_group_id
}

resource "aws_security_group_rule" "web_vpn_ssh" {
  type              = "ingress"
  description = "allowing port number 22 from vpn"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.web_sg.security_group_id
}

resource "aws_security_group_rule" "web_web_alb" {
  type              = "ingress"
  description = "allowing port number 80 from web alb"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web_alb_sg.security_group_id
  security_group_id = module.web_sg.security_group_id
}

resource "aws_security_group_rule" "web_alb_internet" {
  type              = "ingress"
  description = "allowing port number 80 from vpn"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  #source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.web_alb_sg.security_group_id
}

resource "aws_security_group_rule" "web_alb_internet_https" {
  type              = "ingress"
  description = "allowing port number 443 from vpn"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  #source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.web_alb_sg.security_group_id
}