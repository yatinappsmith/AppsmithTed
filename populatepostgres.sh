service postgresql start &
sleep 10
psql fakeapi -f /tmp/pgdump.sql