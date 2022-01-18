echo "Hello World=============" > /dev/console
/bin/setupexim4.sh
mongorestore --db sample_airbnb /sample_airbnb/sample_airbnb
#/etc/init.d/exim4 restart