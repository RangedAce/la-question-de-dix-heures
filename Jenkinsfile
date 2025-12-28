pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  environment {
    REGISTRY = 'ghcr.io'
  }

  parameters {
    string(name: 'IMAGE_REPO', defaultValue: 'ghcr.io/rangedace/la-question-de-dix-heures', description: 'Repo d’image (ex: ghcr.io/rangedace/la-question-de-dix-heures).')
    string(name: 'IMAGE_TAG', defaultValue: '', description: 'Tag d’image à publier (vide = tag Git, sinon numéro de build).')
    string(name: 'SWARM_SERVICE', defaultValue: 'la-question-de-dix-heures', description: 'Nom du service Swarm.')
    string(name: 'PUBLISH_PORT', defaultValue: '32600:80', description: 'Publication de port Swarm (ex: 32600:80).')
    string(name: 'SWARM_SSH_HOST', defaultValue: 'node-master', description: 'Hôte SSH du manager Swarm (ex: node-master ou 192.168.2.100).')
  }

  stages {
    // Note: Declarative pipelines already do "Checkout SCM" automatically.

    stage('Compute Tag') {
      steps {
        script {
          def gitTag = sh(script: "git describe --tags --exact-match 2>/dev/null || true", returnStdout: true).trim()
          def paramTag = params.IMAGE_TAG?.trim()
          if (paramTag) {
            env.EFFECTIVE_TAG = paramTag
          } else if (gitTag) {
            env.EFFECTIVE_TAG = gitTag.startsWith('v') ? gitTag.substring(1) : gitTag
          } else {
            env.EFFECTIVE_TAG = env.BUILD_NUMBER
          }
          env.IMAGE = "${params.IMAGE_REPO}:${env.EFFECTIVE_TAG}"
        }
      }
    }

    stage('Verify Docker') {
      steps {
        script {
          def status = sh(script: "command -v docker >/dev/null 2>&1", returnStatus: true)
          if (status != 0) {
            error("Docker CLI introuvable sur l'agent Jenkins. Installe Docker (ou utilise un agent avec Docker) et donne accès au daemon (ex: mount /var/run/docker.sock).")
          }
        }
      }
    }

    stage('Build') {
      steps {
        sh "docker build -t ${env.IMAGE} ."
      }
    }

    stage('Login & Push (GHCR)') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'ghcr-creds', usernameVariable: 'REG_USER', passwordVariable: 'REG_TOKEN')]) {
          sh """
            echo "$REG_TOKEN" | docker login ${env.REGISTRY} -u "$REG_USER" --password-stdin
            docker push ${env.IMAGE}
          """
        }
      }
    }

    stage('Deploy to Swarm') {
      steps {
        sshagent(credentials: ['swarm-ssh']) {
          sh """
            ssh -o StrictHostKeyChecking=no ${params.SWARM_SSH_HOST} '
              set -eu
              if docker service inspect ${params.SWARM_SERVICE} >/dev/null 2>&1; then
                docker service update --with-registry-auth --image ${env.IMAGE} --force ${params.SWARM_SERVICE}
              else
                docker service create --name ${params.SWARM_SERVICE} --replicas 1 --restart-condition any --publish ${params.PUBLISH_PORT} --with-registry-auth ${env.IMAGE}
              fi
              docker service ls | grep -E \"\\\\b${params.SWARM_SERVICE}\\\\b\" || true
            '
          """
        }
      }
    }
  }
}
