#!/bin/bash

# Conteneur PostgreSQL en CLI avec variables directes
docker run -d --name pg1 \
  -e POSTGRES_USER=john \
  -e POSTGRES_DB=doe \
  -e POSTGRES_PASSWORD=johndoe \
  postgres

# Conteneur PostgreSQL avec fichier env.txt
docker run -d --name pg2 --env-file ./env.txt postgres

# Dossier par défaut contenant les données PostgreSQL
echo "Le dossier contenant les données dans le conteneur PostgreSQL est : /var/lib/postgresql/data"

# Conteneur PostgreSQL avec volume système (dossier local 'data')
mkdir -p data
docker run -d --name pg3 \
  -e POSTGRES_USER=john \
  -e POSTGRES_DB=doe \
  -e POSTGRES_PASSWORD=johndoe \
  -v $(pwd)/data:/var/lib/postgresql/data \
  postgres

# Conteneur PostgreSQL avec volume Docker
docker volume create pgdata
docker run -d --name pg4 \
  -e POSTGRES_USER=john \
  -e POSTGRES_DB=doe \
  -e POSTGRES_PASSWORD=johndoe \
  -v pgdata:/var/lib/postgresql/data \
  postgres
