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

yum list installed nginx &>>$logfile

if [ $? -eq 0 ]; then
    echo " existed"
else
    dnf install nginx -y &>>$logfile
    validate $? "installing nignx"
fi

systemctl enable nginx &>>$logfile
validate $? "Enabled"
systemctl start nginx &>>$logfile
validate $? "started"

rm -rf /usr/share/nginx/html/*   &>>$logfile
validate $? "removed old files"


curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip   &>>$logfile
validate $? "downloaded content"

cd /usr/share/nginx/html  &>>$logfile
unzip -o  /tmp/web.zip    &>>$logfile
validate $? "unzipped content"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf   &>>$logfile
validate $? "copied"

systemctl restart nginx   &>>$logfile
validate $? "rewstared and completed"
