/usr/sbin/mysqld &
sleep 10
#echo "ALTER USER 'root'@'%' IDENTIFIED BY 'YOUR_PASSWORD'; FLUSH PRIVILEGES" | mysql
echo "CREATE USER 'root'@'%' IDENTIFIED BY 'root_password';GRANT ALL ON *.* TO root@'%'; FLUSH PRIVILEGES" | mysql
echo "CREATE USER 'newuser'@'%' IDENTIFIED BY 'root_password';GRANT ALL ON *.* TO newuser@'%'; FLUSH PRIVILEGES" | mysql
