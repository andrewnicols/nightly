sleep 25
docker exec -it "${HOST_DB}" sh -c 'exec echo "SET GLOBAL innodb_large_prefix=1; " | mysql -u root --password=moodle ${DB_NAME}'
docker exec -it "${HOST_DB}" sh -c 'exec echo "SET GLOBAL innodb_file_per_table=1; " | mysql -u root --password=moodle ${DB_NAME}'
docker exec -it "${HOST_DB}" sh -c 'exec echo "SET GLOBAL innodb_file_format=Barracuda; " | mysql -u root --password=moodle ${DB_NAME}'
