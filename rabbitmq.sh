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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash   &>> $logfile
   
validate $? "installing vendre"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash  &>> $logfile
validate $? "installing pkg"

dnf install rabbitmq-server -y   &>> $logfile

validate $? "installing pks"
systemctl enable rabbitmq-server  &>> $logfile
systemctl start rabbitmq-server   &>> $logfile

validate $? "service sratred"

rabbitmqctl add_user roboshop roboshop123  &>> $logfile
validate $? "user  vendre"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $logfile

validate $? "user vendre"