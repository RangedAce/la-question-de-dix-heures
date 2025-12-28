# Image (GHCR)

Ce repo sert à builder/publier l'image `ghcr.io/rangedace/la-question-de-dix-heures` (site statique via Nginx, port conteneur `80`).

## Build + push (GHCR)

```bash
docker login ghcr.io
docker build -t ghcr.io/rangedace/la-question-de-dix-heures:latest .
docker push ghcr.io/rangedace/la-question-de-dix-heures:latest
```

## Docker Compose (standalone)

```yml
  la-question-de-dix-heures:
    image: ghcr.io/rangedace/la-question-de-dix-heures:latest
    container_name: la-question-de-dix-heures
    restart: unless-stopped
    ports:
      - 36301:80
```

## Docker Swarm

### Option A (stack)

Créer un `docker-stack.yml` :

```yml
version: "3.9"
services:
  la-question-de-dix-heures:
    image: ghcr.io/rangedace/la-question-de-dix-heures:latest
    ports:
      - "36301:80"
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
```

Déployer : `docker stack deploy -c docker-stack.yml la-question-de-dix-heures`

### Option B (service)

Créer :
```bash
docker service create \
  --name la-question-de-dix-heures \
  --replicas 1 \
  --restart-condition any \
  --publish 36301:80 \
  --with-registry-auth \
  ghcr.io/rangedace/la-question-de-dix-heures:latest
```

Mettre à jour :
```bash
docker service update \
  --image ghcr.io/rangedace/la-question-de-dix-heures:latest \
  --with-registry-auth \
  --force \
  la-question-de-dix-heures
```
