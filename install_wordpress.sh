#!/usr/bin/env bash

# Name of the WordPress tarball
tarball="wordpress-5.1.1.tar.gz"

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
  sudo yum install php php-mysql -y
  sudo systemctl restart httpd.service
  echo ""
  echo "Finished"
  echo ""
}

# Create MySQL Database and User for WordPress
set_up_sql_user () {
  echo ""
  echo "Create MySQL Database and User for WordPress"
  echo ""
  cd $HOME
  mysql -u root -p$password -e "CREATE DATABASE IF NOT EXISTS wordpress;"
  mysql -u root -p$password -e "CREATE USER IF NOT EXISTS wordpressuser@localhost IDENTIFIED BY 'password';"
  mysql -u root -p$password -e "GRANT ALL PRIVILEGES ON wordpress.* TO wordpressuser@localhost IDENTIFIED BY 'password';"
  mysql -u root -p$password -e "FLUSH PRIVILEGES;"
  echo ""
  echo "Finished"
  echo ""
}

# Install WordPress
install_wordpress () {
  echo ""
  echo "Install WordPress"
  echo ""
  cd $HOME
  sudo yum install php-gd -y
  sudo service httpd restart
  wget https://wordpress.org/$tarball
  tar -xzf $tarball
  sudo rsync -avP ~/wordpress/ /var/www/html/
  mkdir /var/www/html/wp-content/uploads
  sudo chown -R apache:apache /var/www/html/*
  sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
  sed -i s/database_name_here/wordpress/ /var/www/html/wp-config.php
  sed -i s/username_here/wordpressuser/ /var/www/html/wp-config.php
  sed -i s/password_here/password/ /var/www/html/wp-config.php
  echo ""
  echo "Finished"
  echo ""
}

# Runs the Individual Scripts
echo "Starting Script to set up WordPress"
install_apache
install_mysql
install_php
set_up_sql_user
install_wordpress
echo ""
echo "Script Finished"
echo ""
