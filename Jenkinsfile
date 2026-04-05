pipeline {
    agent any
    
    environment {
        DOCKER_HOST = "tcp://docker-dind:2375"
        EXPECTED_NODES = '3'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "✅ Code checked out"
            }
        }
        
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
                echo "✅ Terraform init"
            }
        }
        
        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
                echo "✅ Terraform validate"
            }
        }
        
        stage('Check Node Count') {
            steps {
                script {
                    sh 'echo "var.node_count" | terraform console > node_count.txt'
                    def nodeCount = readFile('node_count.txt').trim()
                    echo "Detected node_count = ${nodeCount}"
                    
                    if (nodeCount != EXPECTED_NODES) {
                        error("❌ Node count is ${nodeCount}, expected ${EXPECTED_NODES}")
                    }
                    echo "✅ Node count is correct (${EXPECTED_NODES})"
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
                echo "✅ Kind cluster created"
            }
        }
        
        // Rest of stages...
    }
    
    post {
        success {
            echo "🎉 Pipeline SUCCESS!"
        }
        failure {
            echo "❌ Pipeline FAILED!"
        }
    }
}