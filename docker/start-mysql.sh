docker build --tag upgrader/mysql8:1.0 .; \
docker run -d \
-p 3311:3306 \
--name upgrader-mysql8 \
upgrader/mysql8:1.0
