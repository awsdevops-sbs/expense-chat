#!/bin/bash

set -e  # Exit immediately if a command fails

LOG="/tmp/expense.log"
rm -f $LOG  # Clear log before running new tasks

print() {
  echo -e "\e[1;36m[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1\e[0m"
  echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1" >>$LOG
}

check_status() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[1;32m[SUCCESS]\e[0m"
  else
    echo -e "\e[1;31m[ERROR] Check logs: $LOG\e[0m"
    exit 1
  fi
}

install_package() {
  package=$1
  if ! rpm -q $package &>/dev/null; then
    print "Installing $package..."
    sudo dnf install -y $package &>>$LOG
    check_status $?
  else
    print "$package is already installed. Skipping..."
  fi
}

manage_service() {
  service=$1
  action=${2:-restart}  # Default to restart if no action is provided
  reload_systemd=${3:-false}  # Optional reload systemd, default is false

  print "Managing $service service: $action..."

  # Optionally reload systemd if specified
  if [[ "$reload_systemd" == "true" ]]; then
    print "Reloading systemd to apply service file changes..."
    systemctl daemon-reload &>>$LOG
    check_status $?
  fi

  # Perform the actual action on the service
  systemctl $action $service &>>$LOG
  check_status $?

}
app_req() {
  print "Downloading and extracting application files..."
  sudo curl -o /tmp/${component}.zip https://expense-artifacts.s3.amazonaws.com/expense-${component}-v2.zip &>>$LOG

  check_status $?

  print "Cleaning up old application files..."
  rm -rf $app_dir/* &>>$LOG
  check_status $?

  print "Extracting new application files......"
  mkdir -p ${app_dir} # Ensure directory exists
   cd ${app_dir} &>>$LOG
   unzip /tmp/${component}.zip &>>$LOG
  check_status $?


}
