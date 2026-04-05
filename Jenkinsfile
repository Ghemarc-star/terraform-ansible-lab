pipeline {
    agent any
    
    environment {
        DOCKER_HOST = "tcp://docker-dind:2375"
        GOOGLE_APPLICATION_CREDENTIALS = "/var/jenkins_home/gcp-creds.json"
        PROJECT_ID = 'project-f78241dc-4480-4159-8d6'
        REGION = 'us-central1'
        PATH = "/google-cloud-sdk/bin:/usr/local/bin:/usr/bin:/bin:${env.PATH}"
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
                    sh 'echo "var.initial_node_count" | terraform console > node_count.txt'
                    def nodeCount = readFile('node_count.txt').trim()
                    echo "Detected node_count = ${nodeCount}"
                    
                    if (nodeCount != "3") {
                        error("❌ Node count is ${nodeCount}, expected 3")
                    }
                    echo "✅ Node count is correct (3)"
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                sh """
                    terraform apply -auto-approve \
                        -var="project_id=${PROJECT_ID}" \
                        -var="region=${REGION}"
                """
                echo "✅ GKE cluster created"
            }
        }
        
        stage('Get Node IPs') {
            steps {
                script {
                    sh """
                        gcloud container clusters get-credentials main-cluster \
                            --region ${REGION} \
                            --project ${PROJECT_ID}
                        kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}' | tr ' ' '\n' > hosts
                        cat hosts
                    """
                }
                echo "✅ Node IPs saved"
            }
        }
        
        stage('Ansible Install Nginx') {
            steps {
                sh 'ansible-playbook -i hosts playbooks/install-nginx.yml'
                echo "✅ Nginx installed"
            }
        }
        
        stage('Verify') {
            steps {
                script {
                    def ip = sh(script: "head -1 hosts", returnStdout: true).trim()
                    sh """
                        echo "Testing Nginx on ${ip}..."
                        curl -s http://${ip} | grep "Hello from Ansible"
                    """
                }
                echo "✅ Nginx verified!"
            }
        }
    }
    
    post {
        success {
            echo "🎉 Pipeline SUCCESS! 3 nodes with Nginx installed"
        }
        failure {
            echo "❌ Pipeline FAILED!"
        }
    }
}