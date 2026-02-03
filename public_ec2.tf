resource "aws_instance" "public-instance" {
  ami                         = lookup(var.amis, var.aws_region)
  count                       = var.environment == "production" ? 3 : 1
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = element(var.public-subnet, count.index)
  vpc_security_group_ids      = ["${var.sg_id}"]
  associate_public_ip_address = true
  tags = {
    Name        = "${var.vpc_name}-Public-Server-${count.index + 1}"
    environment = var.environment
  }
  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    exec > /var/log/user-data.log 2>&1
    
    apt-get update -y
    apt-get install -y nginx git
    
    cd /tmp
    git clone https://github.com/iam-rayees/Cloud-Spectrum-Master.git
    
    rm -f /var/www/html/index.nginx-debian.html
    cp /tmp/Cloud-Spectrum-Master/index.html /var/www/html/index.html
    cp /tmp/Cloud-Spectrum-Master/style.css /var/www/html/style.css
    cp /tmp/Cloud-Spectrum-Master/script.js /var/www/html/script.js

    # Inject Server Name into index.html
    sed -i "s|<body>|<body><h1>Server Name: ${var.vpc_name}-Public-Server-${count.index + 1}</h1>|g" /var/www/html/index.html
    
    systemctl restart nginx
    systemctl enable nginx

  EOF
}
