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


dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y   &>> $logfile
validate $? "installed version 8"

dnf module enable redis:remi-6.2 -y  &>> $logfile
validate  $? "enabled 6.2"

dnf install redis -y  &>> $logfile
validate  $? " installed redis"

sed -i 's/127.0.0.1/0.0.0.0/g'    /etc/redis.conf    &>> $logfile
validate  $? " changes URL "
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf   &>> $logfile
validate  $? " changes URL redis"
systemctl enable redis   &>> $logfile
validate  $? "enabled redis"
systemctl start redis   &>> $logfile
validate  $? " started redis"
systemctl restart redis   &>> $logfile
validate  $? " restarted redis"