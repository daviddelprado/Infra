resource "aws_vpc" "main_vpc_hpc"{
	cidr_block = "172.31.0.0/16"
	enable_dns_support = "true"
	enable_dns_hostnames = "true"
	instance_tenancy = "default"

	tags = {
		Name = "main_vpc_hpc"
	
	}
}


resource "aws_subnet" "main_subnet_hpc" {
	vpc_id = "${aws_vpc.main_vpc_hpc.id}"
	cidr_block = "172.31.0.0/24"
	availability_zone = "us-east-1a"
	map_public_ip_on_launch = "true"

	tags = {
		Name="main_subnet_hpc"
		
	}

}

resource "aws_subnet" "main_subnet_nodes" {
        vpc_id = "${aws_vpc.main_vpc_hpc.id}"
        cidr_block = "172.31.1.0/28"
        availability_zone = "us-east-1b"

        tags = {
                Name="main_subnet_nodes"
                
        }

}

resource "aws_internet_gateway" "main_internet_gateway"{
	vpc_id = "${aws_vpc.main_vpc_hpc.id}"

	tags = { 
		Name="main_internet_gateway"
		
	}
}


resource "aws_route_table" "Custom_Main_Route_Table"{
	vpc_id = "${aws_vpc.main_vpc_hpc.id}"

	route{
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.main_internet_gateway.id}"
		#gateway_id = aws_nat_gateway.nat_gateway.id
	}
	tags = {
		Name="Custon_Main_Route_Table"
		
	}
}


resource "aws_route_table_association" "hpc-route"{
	subnet_id ="${aws_subnet.main_subnet_hpc.id}"
	route_table_id ="${aws_route_table.Custom_Main_Route_Table.id}"
}


resource "aws_eip" "ip_nat"{
	vpc = true
	tags = {
		Name="ip_nat"
		
	}
}


resource "aws_nat_gateway" "nat_gateway" {
	allocation_id = aws_eip.ip_nat.id
	subnet_id = aws_subnet.main_subnet_hpc.id
	tags = {
		Name = "NatGateway-HPC"
		
	}

}

resource "aws_route_table" "NAT-Gateway-RT" {
  depends_on = [
    aws_nat_gateway.nat_gateway
  ]

  vpc_id = aws_vpc.main_vpc_hpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Route Table for NAT Gateway"
  }

}

resource "aws_route_table_association" "Nat-Gateway-RT-Association" {
  subnet_id      = aws_subnet.main_subnet_nodes.id
  route_table_id = aws_route_table.NAT-Gateway-RT.id
}


