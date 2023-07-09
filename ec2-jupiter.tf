data "aws_ami" "jupiter" {
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


resource "aws_instance" "jupiter" {
	ami           = data.aws_ami.jupiter.id
	instance_type = "t3.large"
		
	subnet_id = "${aws_subnet.main_subnet_hpc.id}"
	vpc_security_group_ids = ["${aws_security_group.SG_hpc.id}"]
	key_name  = aws_key_pair.kp.key_name

	user_data = file("userdata-jupiter.sh")

	tags = {
        Name = "jupiter"
  	}
}