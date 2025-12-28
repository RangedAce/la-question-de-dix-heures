# Déploiement (manuel)

Ce projet sert un site statique via Nginx (port conteneur `80`).

## Local

- Build : `docker build -t la-question-de-dix-heures:local .`
- Run : `docker run --rm -p 32600:80 la-question-de-dix-heures:local`
- Ouvrir : `http://localhost:32600`

## Build + push (GHCR)

```bash
docker login ghcr.io
docker build -t ghcr.io/rangedace/la-question-de-dix-heures:0.3.0 .
docker push ghcr.io/rangedace/la-question-de-dix-heures:0.3.0
```

## Docker Swarm (service)

Créer :
```bash
docker service create \
  --name la-question-de-dix-heures \
  --replicas 1 \
  --restart-condition any \
  --publish 32600:80 \
  --with-registry-auth \
  ghcr.io/rangedace/la-question-de-dix-heures:0.3.0
```

Mettre à jour :
```bash
docker service update \
  --image ghcr.io/rangedace/la-question-de-dix-heures:0.3.0 \
  --with-registry-auth \
  --force \
  la-question-de-dix-heures
```

Accès : `http://<ip-d-un-noeud>:32600`

## Docker Swarm (stack)

- Mettre l'image/tag voulu dans `docker-stack.yml`
- Déployer : `docker stack deploy -c docker-stack.yml la-question-de-dix-heures`
