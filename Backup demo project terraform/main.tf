provider "aws" {
  region = "ap-south-1"
  
}


variable "VPC_cidr_block" {}
variable "subnet_cidr_block" {} 
variable "availability_zone" {}
variable "env_prefix" {}
variable "myip" {}
variable "instance_type" {}
# var public_key_location {}


resource "aws_vpc" "myapp-VPC" {
  cidr_block = var.VPC_cidr_block
  tags = {
    "Name" = "${var.env_prefix}-vpc"
  }
  
}

resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-internet-gateway.id
  }
  tags = {
    "Name" = "${var.env_prefix}-RT"
  }
  
}


resource "aws_internet_gateway" "myapp-internet-gateway" {
  vpc_id = aws_vpc.myapp-VPC.id
  tags = {
    "Name" = "${var.env_prefix}-igw"
  }

}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-VPC.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    "Name" = "${var.env_prefix}-Subnet-1"

  }
  
}

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
  
  
}

resource "aws_security_group" "myapp-sg1" {
  name = "myapp-sg1"
  vpc_id = aws_vpc.myapp-VPC.id
  ingress {                       
    cidr_blocks = [ var.myip ]
    description = "value"
    from_port = 22
    # ipv6_cidr_blocks = [ "value" ]    #incoming traffic
    # prefix_list_ids = [ "value" ]
    protocol = "tcp"
    # security_groups = [ "value" ]
    # self = false
    to_port = 22
  } 

  ingress {                       
    cidr_blocks = ["0.0.0.0/0"]    
    from_port = 8080
    to_port = 8080   
    protocol = "tcp"    
    
  }  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks =["0.0.0.0/0"]
    prefix_list_ids =[]

 

  }
   tags = {
    "Name" = "${var.env_prefix}-SG1"

  }
 

}



data "aws_ami" "sample" {

  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"  
    values = ["amzn2-ami-kernel-*-hvm-2.0.20220719.0-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]

  }
}

output "aws_ami_id" {
  value = data.aws_ami.sample.id
  
}

# output "aws_instance_public_ip" {
#   value = aws_instance.aws-ec2-1.public_ip
  
# }

# resource "aws_key_pair" "ssh-key" {
#   key_name = "server-key"
#   public_key = var.my_public_ip  // "$(file(var.public_key_location))"
  
# }

resource "aws_instance" "aws-ec2-1" {
  ami = data.aws_ami.sample.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [ aws_security_group.myapp-sg1.id ]
  availability_zone = var.availability_zone
  associate_public_ip_adress = true
  key_name = aws_key_pair.ssh-key.key_name
  # user_data = <<-EOF 
  # #!/bin/bash
  # sudo yum update -y && sudo yum install -y docker
  # sudo systemctl start docker
  # sudo usermod -aG docker ec2-user
  # docker run -p 8080:80 nginx 
              
  # EOF 

  # user_data = file("entry-script.sh")

  connection {
    type = "ssh"
    host = self.public_ip
    user ="ec2-user"
    private_key = file(var.private_key_location)

  }
  provisioner "file" {    #to copy file from local to remote
    source = "entry-script.sh"
    destination = "/home/sc2-user/entry-script-on-ec2user.sh"
    
  }



  provisioner "remote-exec" {
    # inline = [
    #   "mkdir newdir"

    # ]

    script = file("entry-script.sh")
  }
  
  provisioner "local-exec" {  #to execute locally
      command = "echo ${self.public_ip}> output.txt"
    
  }

  tags = {
    "Name" = "${var.env_prefix}-EC2-1"
  }
  
}


# resource "aws_default_route_table" "main_route_table" {
#   # default_route_table_id =  aws_vpc_id.myapp_vpc_id.default_route_table_id to view terraform route table id  terraform state show 
    #route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_internet_gateway.myapp-internet-gateway.id
  # }
  # tags = {
  #   "Name" = "${var.env_prefix}-RT"
  # }
# }

# resource "aws_subnet" "subnet" {
#   vpc_id = aws_vpc.myapp-VPC.id
#   availability_zone = var.availability_zone
#   cidr_block = var.subnet_cidr_block
#   tags = {
#     "Name" = "${var.env_prefix}-subnet-1"
#   }
  
# }


# data "aws_ami" "latest-ami" {
#   most_recent = "latest"
#   owners = [ "amazon" ]
#   filter {
#     name = "name"
#     values = ["amzon-ami-hvm-*"]
#   }
  
# }


# resource "aws_instance" "myapp-server" {
#   # ami = "ami id"
  
# }
