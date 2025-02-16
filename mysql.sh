#!/bin/bash

source common.sh  # Load common functions

mysql_root_password=$1

if [ -z "${mysql_root_password}" ]; then
  print "Input password is missing!"
  exit 1
fi

install_package mysql-server  # Install MySQL server

manage_service mysqld  # Start and enable MySQL service

print "Checking MySQL root access...."
echo "Show database" | mysql -h mysql-dev.awsdevops.sbs -uroot -p${mysql_root_password} &>>$LOG
if [ $? -eq 0 ]; then
  print "Setting up MySQL root password..."
  mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOG
  check_status $?
else
  print "MySQL root access already configured."
fi

 print "setting up the password"
echo "Show database" | mysql -h mysql-dev.awsdevops.sbs -uroot -p${pass} &>>$Log
check_status $? &>>$Log
   if [ $? -eq 0 ]; then
     mysql_secure_installation --set-root-pass ${pass} &>>$Log
     check_status $?
     fi


