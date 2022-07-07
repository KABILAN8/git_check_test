#!/bin/bash

d_file_name=mysql-5.7.37
URL="https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.37-linux-glibc2.12-x86_64.tar.gz"
f_file_name=$(basename ${URL})
filename=$(basename ${URL} .tar.gz)

port=3306
home=~

if [ -e ~/.my.cnf ]
then
    echo ""
    echo "Installation failed due to  the file (.my.cnf) : ${home}" 
    echo "Please Delete the File and rerun the Script "
    exit
else
    echo ""
fi


dpkg -l libaio1 > /dev/null

if [[ "$?" != 0 ]]; then
    echo ""
    echo  "Installation failed : libaio1 package not found"
    echo " "
    echo "Please install the package using the command"
    echo ""
    echo "sudo apt-get install libaio1"
    echo ""
    echo "And rerun the script : sql_5.7_install_script.sh"
    exit
else
    echo ""
    echo "Libaio package found "
   
fi


if lsof -Pi :${port} -sTCP:LISTEN -t > /dev/null ; then
    echo ""
    echo  "Installation failed : Port 3306 is BUSY "
    echo  ""
    exit
else
    echo ""
    echo "Port 3306 is OPEN"
    
fi

echo ""
echo "Started Downloading : ${f_file_name}   "
echo ""
echo ""

wget -c "${URL}"

if [[ "$?" != 0 ]]; then
    echo ""
    echo ""
    echo "Error downloading file"
    echo ""
    echo  "Installation failed : Check INTERNET Connection"
    echo ""
    exit
else
    echo ""
    echo ""
    echo "     Downloaded the File : ${f_file_name}  Successfully  "
    echo ""
    echo ""
    
    echo ""
    echo "Extracting the downloaded file"
    
    tar -xvzf $f_file_name
    
    mv $filename $d_file_name
    echo $PWD
    SQL_FOLDER_NAME=mysql-5.7.37
    cd $SQL_FOLDER_NAME
    SQL_HOME=$PWD
    echo $SQL_HOME
    echo ""
    echo ""
    echo "Dowloaded and Extracted the file sucessfully"
    echo ""
    cat <<EOF >$PWD/my.cnf
[mysqld]
basedir= $SQL_HOME
datadir = $SQL_HOME/data
EOF
    cd $PWD/bin
    echo $PWD
    $PWD/mysqld --defaults-file=$SQL_HOME/my.cnf --initialize
    $PWD/mysqld_safe --defaults-file=$SQL_HOME/my.cnf --skip-grant-tables &
    while ! [[ "$mysqld_process_pid" =~ ^[0-9]+$ ]]; do
    mysqld_process_pid=$(echo "$(ps -C mysqld -o pid=)" | sed -e 's/^ *//g' -e 's/ *$//g')
    sleep 1
    done
    ./mysql -u "root" <<EOF
    use mysql;
    update user set authentication_string=password('') where user='root';
    flush privileges;
    quit
EOF
    killall mysqld
    sleep 5
    
    echo "Starting Mysql_safe "
    $PWD/mysqld_safe --defaults-file=$SQL_HOME/my.cnf &
    while ! [[ "$mysqld_process_pid" =~ ^[0-9]+$ ]]; do
    mysqld_process_pid=$(echo "$(ps -C mysqld -o pid=)" | sed -e 's/^ *//g' -e 's/ *$//g')
    sleep 1
    done
    sleep 3
    echo "Resetting  the password"
    ./mysql -u "root"  --connect-expired-password <<EOF
    SET PASSWORD = PASSWORD('');
    quit
EOF
    sleep 3
    killall mysqld
    echo ""
    echo "Mysql server is stopped"
    echo ""
    sleep 1
    echo ""
    echo "*****************************************************"
    echo ""
    echo "Completed ${d_file_name} Installation Process"
    echo ""
    echo "**********************Steps to Manage MYSQL Process *******************"
    echo ""
    echo "1:Go to the Path : ${PWD}"
    echo "2.use command: './mysqld_safe &' to start MYSQL server"
    echo "3.use command: './mysql -u root' to start MYSQL client"
    echo "4.To check MYSQL is running -command : 'ps aux | grep -i mysqld' "
    echo "5.To kill mysql server - command : 'killall mysqld'"
    echo ""
    echo ""
    echo "Note:"
    echo "To avoid typing the path name of client programs when working with MySQL, add the ${PWD} directory to your PATH variable in bashrc"
    echo "Eg :  export PATH=\$PATH:${PWD}"  
    echo ""
    
    echo "You can also read MYSQL managing steps in the file(manage_mysql.txt) : ${SQL_HOME}"
    echo ""  
    cat <<EOF >$SQL_HOME/Manage_mysql.txt
    **********************Steps to Manage MYSQL Process ****************
1:Go to the Path : ${PWD}
2.use command: './mysqld_safe &' to start MYSQL server
3.use command: './mysql -u root' to start MYSQL client
4.To check MYSQL is running -command : 'ps aux | grep -i mysqld' 
5.To kill mysql server - command : 'killall mysqld'


Note:
To avoid typing the path name of client programs when working with MySQL, add the ${PWD} directory to your PATH variable in bashrc
Eg : echo "export PATH=\$PATH:${PWD}"  
EOF
     sleep 5
fi
    


