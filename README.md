# Grotto

This application is a Trello clone. It only runs locally and is mainly for my own personal use. There are no guarantees it will work. There is an included docker-compose file for playing around with it.

# Docker

Migrations have to run before starting the app:

```
docker-compose up -d postgres
docker-compose run grotto /app/bin/migrate
docker-compose up -d grotto
```
