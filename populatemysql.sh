service mysql start &
sleep 10
mysql -u root < "/tmp/mysqlinitdb.sql"