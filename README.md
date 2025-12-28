# Déploiement Swarm

1. Déployer sur Swarm :
`
docker service rm la-question-de-dix-heures
docker service create --name la-question-de-dix-heures --replicas 1 --restart-condition any --publish 32600:80 rangedace/la-question-de-dix-heures:0.3.0
`
3. Accéder au site : `http://<manager>:32600`
