data "aws_ami" "master" {
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



resource "tls_private_key" "pk" {
  algorithm     = "RSA"
  rsa_bits      = 4096
}

resource "aws_key_pair" "kp" {
  key_name      = "hpc-key"
  public_key    = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo "${tls_private_key.pk.private_key_pem}" > hpc-key.pem
    EOT
  }
}

resource "aws_network_interface" "lanmaster" {
  subnet_id   = "${aws_subnet.main_subnet_hpc.id}"
  private_ips = ["172.31.0.100"]

  tags = {
    Name = "private master network"
  }
}

resource "aws_instance" "master" {
	ami           = data.aws_ami.master.id
	instance_type = "t3.large"
		
	#subnet_id = aws_subnet.main_subnet_hpc.id
	#vpc_security_group_ids = ["${aws_security_group.SG_hpc.id}"]
	key_name  = aws_key_pair.kp.key_name
  network_interface {
     network_interface_id = aws_network_interface.lanmaster.id
     device_index = 0
  }

	user_data = file("userdata-master.sh")

	tags = {
        Name = "master"
  	}
}

output "master_public_ip" {
  value = ["${aws_instance.master.*.public_ip}"]
}