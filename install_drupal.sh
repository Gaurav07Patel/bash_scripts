#!/usr/bin/env bash

# Name of the WordPress tarball
tarball="drupal-7.32.tar.gz"

# Checks to see if User passed a variable from the command line
# If they did not, sets the default password to Drawsap
password=${1:-Drawsap}

# Install and Start Apache Web Server
install_apache () {
  echo ""
  echo "Install and Start Apache Web Server"
  echo ""
  cd $HOME
  sudo yum install httpd -y
  sudo systemctl start httpd.service
  sudo systemctl enable httpd.service
  echo ""
  echo "Finished"
  echo ""
}

# Install and Start MySQL(MariaDB)
install_mysql () {
  echo ""
  echo "Install and Start MySQL(MariaDB)"
  echo ""
  cd $HOME
  sudo yum install mariadb-server mariadb -y
  sudo systemctl start mariadb
  # sudo mysql_secure_installation
  mysql -u root -e "UPDATE mysql.user SET Password=PASSWORD('$password') WHERE User='root';"
  mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
  mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
  mysql -u root -e "DROP DATABASE IF EXISTS test;"
  mysql -u root -e "FLUSH PRIVILEGES;"
  sudo systemctl enable mariadb.service
  echo ""
  echo "Finished"
  echo ""
}

# Install and Start PHP
install_php () {
  echo ""
  echo "Install and Start PHP"
  echo ""
  cd $HOME
  sudo yum install php php-mbstring php-gd php-xml php-pear php-fpm php-mysql php-pdo -y
  sudo systemctl restart httpd.service
  echo ""
  echo "Finished"
  echo ""
}

# Create MySQL Database and User for Drupal
set_up_sql_user () {
  echo ""
  echo "Create MySQL Database and User for Drupal"
  echo ""
  cd $HOME
  mysql -u root -p$password -e "CREATE DATABASE IF NOT EXISTS drupal;"
  mysql -u root -p$password -e "CREATE USER drupaluser@localhost IDENTIFIED BY 'password';"
  mysql -u root -p$password -e "GRANT ALL PRIVILEGES ON drupal.* TO drupaluser@localhost IDENTIFIED BY 'password';"
  mysql -u root -p$password -e "FLUSH PRIVILEGES;"
  echo ""
  echo "Finished"
  echo ""
}

# Install Drupal
install_drupal () {
  echo ""
  echo "Install Drupal"
  echo ""
  cd $HOME
  wget http://ftp.drupal.org/files/projects/$tarball
  tar -zxf $tarball
  cd drupal*
  sudo rsync -az . /var/www/html
  sudo chown -R apache:apache /var/www/html/*
  sudo systemctl restart httpd.service
  echo ""
  echo "Finished"
  echo ""
}

# Runs the Individual Scripts
echo "Starting Script to Install and Set up Drupal"
install_apache
install_mysql
install_php
set_up_sql_user
install_drupal
echo ""
echo "Script Finished"
echo ""
