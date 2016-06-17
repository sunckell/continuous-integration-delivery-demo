variable DEFAULT_REGION_NAME {}
variable AWS_ACCESS_KEY_ID  {}
variable AWS_SECRET_ACCESS_KEY {}
variable DEFAULT_VPC_ID {}
variable DEFAULT_GATEWAY_ID {}
variable DEFAULT_ROUTE_ID {}
variable APP_SERVER_PEM_FILE {}
variable WEB_SERVER_PEM_FILE {}
variable DB_SERVE_PEM_FILE {}

provider "aws" {
    region = "${var.DEFAULT_REGION_NAME}"
    access_key = "${var.AWS_ACCESS_KEY_ID}"
    secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "cloud_principles_elb"
  description = "Used in the Cloud Principles Demo"
  vpc_id      = "${var.DEFAULT_VPC_ID}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "cloud_principles_sg"
  description = "Used in the Cloud Principles demostration"
  vpc_id      = "${var.DEFAULT_VPC_ID}"


  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- generate a Web Server
resource "aws_instance" "Cloud_Principles_WebServer-1" {
    
    instance_type = "t2.micro"
    ami = "ami-23f5ed49"
    key_name = "webserver1_aws"
    associate_public_ip_address = true
    
    connection {
        # The default username for our AMI
        user = "ubuntu"
        private_file = "${var.WEB_SERVER_PEM_FILE}"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt-get -y update",
            "sudo apt-get -y install nginx",
            "sudo service nginx start"
        ]
    }
    # Our Security group to allow HTTP and SSH access
    vpc_security_group_ids = ["${aws_security_group.default.id}"]

}

# --- generate the app server
resource "aws_instance" "Cloud_Principles_AppServer-1" {
    instance_type = "t2.micro"
    ami = "ami-23f5ed49"
    key_name = "appserver1_aws"
    connection {
        # The default username for our AMI
        user = "ubuntu"
        private_file = "${var.APP_SERVER_PEM_FILE}"
    }
    provisioner "remote-exec" {
        inline = [
            "sudo apt-get -y update",
            "sudo apt-get -y install tomcat7",
            "sudo service tomcat7 start"
        ]
    }
    # Our Security group to allow HTTP and SSH access
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
}
