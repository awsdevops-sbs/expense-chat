#!/bin/bash

source common.sh

component=frontend
app_dir=/usr/share/nginx/html

print "Installing Nginx..."
install_package nginx

print "Copying Nginx configuration..."
cp expense.conf /etc/nginx/default.d/expense.conf &>>$LOG
check_status $?

app_req  # This will download and set up the frontend app

manage_service nginx  # Starts and enables Nginx
