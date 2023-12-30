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
        echo -e "$G Successfully $2"
    fi
}
if [ $id -ne 0 ]; then
    echo -e "Dont have permission to do this !! $R Please run this by SUDO access $N"
    exit 1
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$logfile
validate $? "Copied "

yum list installed mongodb-org  &>>$logfile
if [ $? -eq 0 ]; then
    echo "Already installed so .. $Y SKIPPED INSTALLATION $N"
else
    dnf install mongodb-org -y &>>$logfile
    validate $? "Installed "
fi

systemctl enable mongod &>>$logfile
validate $? "enabled "

systemctl start mongod &>>$logfile
validate $? "started "

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$logfile
validate $? "Replaced Ip to 0.0.0.0 "

systemctl restart mongod &>>$logfile
validate $? "restarted  and completing process"
