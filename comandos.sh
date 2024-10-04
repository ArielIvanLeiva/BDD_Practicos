# Crear nuevo container
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 --name NOMBRE mysql

# Conectarse desde la terminal
mariadb -u root -p123456 -h 127.0.0.1

# Para ejecutar un script concreto
mariadb -u root -p123456 -h 127.0.0.1 < script.sql

# Para iniciar el container y que empiece a hostear:
docker start NOMBRE
