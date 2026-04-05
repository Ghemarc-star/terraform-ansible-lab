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
        
        stage('Get Node IPs') {
            steps {
                script {
                    sh """
                        docker ps --filter "name=local-cluster-worker" --format "{{.Names}}" | while read name; do
                            docker inspect \$name -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
                        done > hosts
                        cat hosts
                    """
                }
                echo "✅ Node IPs saved"
            }
        }
        
        stage('Ansible Install Nginx') {
            steps {
                sh 'ansible-playbook -i hosts playbook.yml'
                echo "✅ Nginx installed"
            }
        }
        
        stage('Verify') {
            steps {
                script {
                    def ip = sh(script: "head -1 hosts", returnStdout: true).trim()
                    sh """
                        echo "Testing Nginx on ${ip}..."
                        sleep 5
                        curl -s http://${ip} | grep "Hello from Ansible"
                    """
                }
                echo "✅ Nginx verified!"
            }
        }
    }
    
    post {
        success {
            echo "🎉 Pipeline SUCCESS! ${EXPECTED_NODES} nodes with Nginx installed"
        }
        failure {
            echo "❌ Pipeline FAILED!"
        }
    }
}
