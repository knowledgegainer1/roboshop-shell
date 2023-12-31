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

dnf install python36 gcc python3-devel -y &>> $logfile


useradd roboshop  &>> $logfile
mkdir -p /app   &>> $logfile
curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip  &>> $logfile
cd /app  &>> $logfile

unzip -o /tmp/payment.zip  &>> $logfile
pip3.6 install -r requirements.txt  &>> $logfile
echo "depe installed"
cp /home/centos/roboshop-shell/payment.service  /etc/systemd/system/payment.service  &>> $logfile

systemctl daemon-reload  &>> $logfile

systemctl enable payment   &>> $logfile
systemctl start payment  &>> $logfile
echo "done installing"