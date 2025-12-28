# Déploiement Swarm

1. Construire l'image : `docker build -t la-question-de-dix-heures:latest .`
2. Déployer sur Swarm : `docker stack deploy -c docker-stack.yml la-question-de-dix-heures`
3. Accéder au site : `http://<manager>:32600`
