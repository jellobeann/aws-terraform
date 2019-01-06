# Terraform for single server

variable "region" {
  default = "ap-southeast-1"
}
variable "shared_credentials_file" {
  default = "C:\\Users\\profile\\.aws\\credentials"
}

variable "profile" {
  default = "default"
}

provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.profile}"
}
resource "aws_instance" "web" {
  ami = "ami-08569b978cc4dfa10"
  instance_type = "t2.micro"
  key_name= "terraformKP"
  count = 1
  vpc_security_group_ids = ["${aws_security_group.terraforserverSG.id}"]
  tags {
    Name = "TERRAFORM SERVER"
  }
  user_data = <<-EOF
            #!/bin/bash
            yum update -y
            EOF
}

resource "aws_security_group" "terraforserverSG" {
	name = "terraforserverSG"
	description = "Security Group for terraform server"

# SSH Access
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"] # 0.0.0.0/0 is just for the purpose of the repo. Whitelist only your IP.
	}

# HTTP Access
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
	from_port = 0
	to_port = 0
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
	}

}

output "public_ip" {
  value = "${aws_instance.web.public_ip}"
}
