pipeline {
    agent any
    tools {
        maven 'Maven'
    }
    environment {
      DOCKER_TAG = getVersion()
    }	
    stages {
        stage('SCM-Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github-credentials', 
				url: 'https://github.com/mbinui/K8S-pipeline.git'
            }
        }
        stage('Maven-Package') {
            steps {
                sh 'mvn clean compile package'
            }
        }
        stage('Docker-build') {
            steps {
                sh 'docker build . -t mbinui/k8s-app:${DOCKER_TAG}' 
            }
        }
        stage('Docker-Push') {
            steps {
				withCredentials([string(credentialsId: 'docker-hub', variable: 'dockerHubPwd')]) {
					sh 'docker login -u mbinui -p ${dockerHubPwd}'
				}
			sh 'docker push mbinui/k8s-app:${DOCKER_TAG}'				
            }
        }
        stage('Ansible Deploy'){
            steps{
			ansiblePlaybook credentialsId: 'k8snew-ssh', disableHostKeyChecking: true, extras: "-e DOCKER_TAG=${DOCKER_TAG}", installation: 'ansible', inventory: 'dev.inv', playbook: 'deploy-docker.yml'     
		   }
        }
        stage('Deploy to k8s'){
            steps{
              sh "chmod +x changeTag.sh"
              sh "./changeTag.sh ${DOCKER_TAG}"
              sshagent(['k8snew-ssh']) {
                    sh "scp -o StrictHostKeyChecking=no services.yml node-app-pod.yml ec2-user@3.10.53.254:/home/ec2-user/"
                }
		script{
			try{
				sh "sudo ssh ec2-user@3.10.53.254 kubectl apply -f ."
			}catch(error){
				 sh "sudo ssh ec2-user@3.10.53.254 kubectl create -f ."
			}
		     }
              }
        }		
    }
}
def getVersion(){
    def commitHash = sh returnStdout: true, script: 'git rev-parse --short HEAD'
    return commitHash
}
