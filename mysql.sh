#!/bin/bash

date=$(date +%F-%R-%S)
logfile="/tmp/$0-$date.log"
id=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
validate() {
    if [ $1 -eq 1 ]; then
        echo -e " $R FAILED ...$N   $2 check logs at  /tmp/$0-$date.log"
        exit 1
    else
        echo -e "$G Successfully $2 $N"
    fi
}
if [ $id -ne 0 ]; then
    echo -e "Dont have permission to do this !! $R Please run this by SUDO access $N"
    exit 1
fi

dnf module disable mysql -y &>> $logfile
validate $? "disbaled"
cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo
validate $? "cpoied"
dnf install mysql-community-server -y   &>> $logfile
validate $? "installed "
systemctl enable mysqld  &>> $logfile
systemctl start mysqld  &>> $logfile
validate $? "started"
mysql_secure_installation --set-root-pass RoboShop@1  &>> $logfile
validate $? "swl user created"


mysql -uroot -pRoboShop@1   &>> $logfile
validate $? "swl user created and logged in "