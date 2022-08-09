provider "aws"{
  region = "ap-south-1"
  # access_key = "AKIAYSELN7WJSDB6AEGE"
  # secret_key = "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"
  # we have to set it as environment varibale for safety purpose 
  # in CMD we type the following   export is for linux  , set for windows 
  # set AWS_SECRET_ACCESS_KEY=CfzCTVePowPqjcg+oSoxWVash20jdGid2pNB6fPD
  # set AWS_ACCESS_KEY_ID=AKIAYSELN7WJSDB6AEGE
  # export AWS_SECRET_ACCESS_KEY=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
  # export AWS_ACCESS_KEY_ID=AKIAYSELN7WJSDB6AEGE
}

variable "subnet_cidr_block" {
  description = "subnet cidr block"
  default = "10.0.10.0/24"
  # type = number , ztring,bool 
  #type = list(string)

  
}

variable avail_zone {
  
}

variable "aws_vpc_tag" {
  description = "AWS VPC TAG"
  
}

resource "aws_vpc" "development-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.aws_vpc_tag
  }
   
  
}

resource "aws_subnet" "dev-subnet" {
  vpc_id = aws_vpc.development-vpc.id  
  cidr_block = var.subnet_cidr_block
  #cidr_block = var.subnet_cidr_block[1]
  # cidr_block = "10.0.10.0/24"
  availability_zone = "ap-south-1a"
  # availability_zone = var.avail_zone
    tags = {
    "Name" = "Subnet-Development-1"
  }

  
}


data "aws_vpc" "existing_vpc" {
  default = true
  
}


resource "aws_subnet" "dev-subnet-2" {
  vpc_id = data.aws_vpc.existing_vpc.id
  cidr_block = "172.31.48.0/20"
  #
  availability_zone = "ap-south-1a"
    tags = {
    "Name" = "Subnet-Development-2"
  }

}


# output "development-subnet-availability_zone" {
#   value = aws_subnet.dev-subnet.availability_zone
  
# }

###NEW CHECKOUT####
