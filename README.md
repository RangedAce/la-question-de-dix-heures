# Déploiement

## Docker (local)

- Build : `docker build -t la-question-de-dix-heures:local .`
- Run : `docker run --rm -p 32600:80 la-question-de-dix-heures:local`
- Ouvrir : `http://localhost:32600`

## Docker Swarm

Option A (stack) :
- `docker build -t la-question-de-dix-heures:latest .`
- `docker stack deploy -c docker-stack.yml la-question-de-dix-heures`

Option B (service) :
```bash
docker service create \
  --name la-question-de-dix-heures \
  --replicas 1 \
  --restart-condition any \
  --publish 32600:80 \
  rangedace/la-question-de-dix-heures:0.3.0
```

Accès : `http://<manager>:32600`

# CI/CD avec Jenkins (build + push + déploiement Swarm)

Ce repo fournit un `Jenkinsfile` qui :
- build l'image Docker
- push sur GHCR
- crée/upgrade le service Swarm (port `32600:80`)

## Prérequis Jenkins

- L'agent Jenkins doit avoir `docker` disponible (CLI + accès au daemon) pour builder/push l'image.
- Jenkins doit pouvoir SSH vers le manager Swarm.

### Jenkins dans Docker (solution au `docker: not found`)

Si Jenkins tourne dans un conteneur, le plus simple est de lui donner :
- un binaire `docker` dans l'image Jenkins
- l'accès au daemon via le socket `/var/run/docker.sock`

Exemple prêt à l'emploi : `jenkins/docker-compose.yml` et `jenkins/Dockerfile`.

```bash
cd jenkins
docker compose up -d --build
```

## Credentials Jenkins à créer

Dans Jenkins → Manage Jenkins → Credentials :

1) `ghcr-creds` (Username with password)
- Username: `RangedAce`
- Password: un token GitHub avec `read:packages` + `write:packages`

2) `swarm-ssh` (SSH Username with private key)
- Clé SSH qui a accès au manager Swarm (ex `node-master` / `192.168.2.100`)

## Job Jenkins

- Créer un Pipeline job qui pointe sur ce repo.
- Lancer le job ; paramètre `SWARM_SSH_HOST` = hostname/IP du manager Swarm.

## Déclenchement automatique (GitHub → Jenkins)

Option 1 (simple) : dans le job Jenkins, activer "Poll SCM".

Option 2 (webhook) :
- GitHub repo → Settings → Webhooks → Add webhook
- Payload URL : `https://<jenkins>/github-webhook/`
- Content type : `application/json`
- Events : "Just the push event" (ou tags/releases si tu préfères)
