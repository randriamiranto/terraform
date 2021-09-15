provider "aws" {
	region = "eu-west-3"
}

resource "aws_vpc" "wp" {
	cidr_block = "10.0.0.0/16"
	instance_tenancy = "default"
	
	tags = {
		Name = "wp"
	}
}

resource "aws_subnet" "wp" {
	vpc_id 					= aws_vpc.wp.id
	cidr_block 				= "10.0.200.0/24"
	map_public_ip_on_launch = true
	availability_zone 		= "eu-west-3a"
	tags = {
		Name = "wp"
	}
}

resource "aws_internet_gateway" "default" {
	vpc_id = aws_vpc.wp.id
	tags = {
		Name = "wp"
	}
}

resource "aws_route" "route_web" {
	route_table_id		= aws_vpc.wp.default_route_table_id
	destination_cidr_block	= "0.0.0.0/0"
	gateway_id		= aws_internet_gateway.default.id
}

resource "aws_security_group" "sg_elb" {
        name = "sg_elb"
        vpc_id = aws_vpc.wp.id
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
         tags = {
         Name = "sg_elb"
        }
}


resource "aws_elb" "elb-wp" {
	name = "elb-wp"
	subnets = [aws_subnet.wp.id]
	security_groups = [aws_security_group.sg_elb.id]
	instances = [aws_instance.wp-1.id, aws_instance.wp-2.id]
	listener {
	    lb_port = 80
		lb_protocol = "http"
		instance_port = 80
		instance_protocol = "http"
	}
    health_check {
		healthy_threshold = 2 
		unhealthy_threshold = 2
		timeout = 3
		interval = 5
		target = "TCP:80"
	}
	tags = {
		Name = "wp"
	}
}


resource "aws_instance" "wp-1" {
	ami = "ami-017467a4160a0dc89"
	instance_type = "t2.micro"
	vpc_security_group_ids = [aws_security_group.sg_elb.id]
	subnet_id = aws_subnet.wp.id
	associate_public_ip_address = true
	tags = {
		Name = "wp"
	}
}

resource "aws_instance" "wp-2" {
	ami = "ami-017467a4160a0dc89"
	instance_type = "t2.micro"
	vpc_security_group_ids = [aws_security_group.sg_elb.id]
	subnet_id = aws_subnet.wp.id
	associate_public_ip_address = "true"
	tags = {
		Name = "wp"
	}
}

/*
resource "aws_instance" "backoffice" {
	ami = "ami-03213010deeb10b58"
	instance_type = "t2.micro"
	vpc_security_group_ids = [aws_security_group.sg_elb.id]
	subnet_id = aws_subnet.wp.id
	associate_public_ip_address = true
	tags = {
		Name = "bo"
	}
}

*/
