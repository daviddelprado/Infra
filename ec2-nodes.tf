data "aws_ami" "nodes" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



resource "aws_instance" "nodes" {
	depends_on = [aws_nat_gateway.nat_gateway,aws_instance.master]
  ami           = data.aws_ami.nodes.id
	instance_type = "t3.large"
  count         = var.nodes_count
		
	subnet_id = "${aws_subnet.main_subnet_nodes.id}"
	vpc_security_group_ids = ["${aws_security_group.SG_hpc.id}"]
	key_name  = aws_key_pair.kp.key_name
 
	user_data = file("userdata-nodes.sh")

	tags = {
        Name = "node${count.index + 1}"
  	}
}
