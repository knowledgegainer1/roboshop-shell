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

dnf install maven -y
validate $? "installing maven"
id roboshop
if [ $? -eq 0 ]; then
    echo "already user there so skipped"
else
    useradd roboshop
    validate $? "adding user"
fi

mkdir -p /app
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip
cd /app
unzip -o /tmp/shipping.zip

mvn clean package
mv target/shipping-1.0.jar shipping.jar

validate $? "installed dependencies user"
systemctl daemon-reload


systemctl enable shipping 
systemctl start shipping

validate $? "  started serbice"

dnf install mysql -y
validate $? " installed"


mysql -h mysql.ssrg.online -uroot -pRoboShop@1 < /app/schema/shipping.sql 
systemctl restart shipping