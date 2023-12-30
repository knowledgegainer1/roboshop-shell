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




dnf module disable nodejs -y  &>> $logfile
validate $? "disabled"
dnf module enable nodejs:18 -y  &>> $logfile
validate $? "enabled"

dnf install nodejs -y  &>> $logfile
validate $? "installing node js latest verison"

useradd roboshop
mkdir /app
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
cd /app 
unzip /tmp/catalogue.zip
npm install 
validate $? "user added, dir created downloaded unzipped and installed dependencies"
 #here cat.service  path shoulb be linux ,git pulled path and what is stoerd in my pc path both should be matched
cp /home/centos/Roboshop-Shellscript/catalogue.service /etc/systemd/system/catalogue.service
validate $? "copied"

systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue
validate $? "restared"
#think that you are in linux folder after gil pull ,then tou r chanign to ect folder
cp /home/centos/Roboshop-Shellscript/mongo.repo etc/yum.repos.d/mongo.repo


yum list installed mongodb-org-shell  &>>$logfile
if [ $? -eq 0 ]; then
    echo -e  "Already installed so .. $Y SKIPPED INSTALLATION $N"
else
    dnf install mongodb-org-shell -y &>>$logfile
    validate $? "Installed "
fi


mongo --host mongo.ssrg.online </app/schema/catalogue.js