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

dnf module disable nodejs -y &>>$logfile
validate $? "disabled"
dnf module enable nodejs:18 -y &>>$logfile
validate $? "enabled"

dnf install nodejs -y &>>$logfile
validate $? "installing node js"

id roboshop
if [ $? -eq 0 ]; then
    echo "user existd"
else
    useradd roboshop &>>$logfile
    validate $? "craeting new user"
fi

mkdir -p /app  &>>$logfile


curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip  &>>$logfile
cd /app   &>>$logfile
unzip -o /tmp/user.zip  &>>$logfile
npm install  &>>$logfile
validate $? "unzipped"

cp /home/centos/roboshop-shell/cart.service  /etc/systemd/system/cart.service
validate $? "copied"

systemctl daemon-reload  &>>$logfile
systemctl enable user  &>>$logfile
systemctl start user &>>$logfile
validate $? "resatred"  


