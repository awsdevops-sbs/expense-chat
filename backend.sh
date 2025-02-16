#!/bin/bash

source common.sh

component="backend"
app_dir="/app"
pass=$1

if [ -z "$pass" ]; then
  print "No MySQL password provided!"
  exit 1
fi

print "Setting up Node.js..."
dnf module disable nodejs -y &>>$LOG
dnf module enable nodejs:20 -y &>>$LOG
install_package nodejs

print "Adding application user..."
id expense &>>$LOG || useradd expense &>>$LOG
check_status $?

print "Copying backend systemd service..."
cp backend.service /etc/systemd/system/backend.service &>>$LOG
check_status $?

app_req  # Download & setup backend applicat ion

print "Installing NPM dependencies..."
cd $app_dir
npm install &>>$LOG
check_status $?

manage_service backend  # Start & enable backend service

install_package mysql  # Install MySQL client

print "Loading database schema..."
mysql -h mysql-dev.awsdevops.sbs -uroot -p${pass} < $app_dir/schema/backend.sql &>>$LOG
check_status $?
