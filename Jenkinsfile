pipeline {
    agent any

    stages {
        stage('Git checkout') {
            steps {
               git branch: 'main', url: 'https://github.com/mdashrafadib/express.git'
            }
        }
        stage('Docker Build Images') {
            steps {
               sh 'docker build -t mdashrafadib/expressjs .'
            }
        }
        stage('Image Push To DockerHub') {
            steps {
               withCredentials([usernamePassword(credentialsId: 'Dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD} docker.io'
                    sh 'docker push mdashrafadib/expressjs'
               }
        }
    }
    
    stage('ECS Service Update') {
            steps {
               sh 'aws ecs update-service --cluster my-cluster --service my-service --force-new-deployment --region us-east-1'
            }
        }
    
}
}

