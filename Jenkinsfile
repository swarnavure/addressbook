pipeline{
    agent any
    tools{
        maven 'mymaven'
        jdk 'myjava'
    }
    stages{
        stage("Compile"){
            steps{
              script{
                 echo "Compiling the code"
                 sh 'mvn compile'
              }
            }
        }
        stage("test"){
             steps{
                script{
                  echo "Testing the code"
                  sh 'mvn test'
                  }
             }
             post{
                 always{
                     junit 'target/surefire-reports/*.xml'
                 }
             }
        }
        stage("Package"){
             steps{
                script{
                  echo "Packaging the code"
                  sh 'mvn package'
              }
             }
        }
        stage("Build the docker image"){
            steps{
                script{
                    echo "Building the docker image"
                    sh 'sudo yum install docker -y'
                    sh 'sudo systemctl start docker'
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                  sh 'sudo docker build -t swarnavure/myimage:$BUILD_NUMBER .'
                  sh 'sudo docker login -u $USER -p $PASS'
                  sh 'sudo docker push swarnavure/myimage:$BUILD_NUMBER'
}
                }
            }
        }
        stage("Provision deploy server"){
        environment{
            AWS_ACCESS_KEY_ID =credentials("AKIA45OPVZZFEMQNFAM2")
            AWS_SECRET_ACCESS_KEY=credentials("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")
        }
        steps{
            script{
                dir('terraform'){
                    sh "terraform init"
                    sh "terraform apply --auto-approve"
                     EC2_PUBLIC_IP = sh(
                     script: "terraform output ec2-ip",
                     returnStdout: true
                   ).trim()
                }
          }
        }  
         }

          stage("Deploy on EC2 instance"){
            agent any
            steps{
                script{
                 echo "Waiting for ec2 instance to initialise"
                 sleep(time: 90, unit: "SECONDS")
                 echo "Deploying the app to ec2-instance provisioned bt TF"
                 echo "${EC2_PUBLIC_IP}"
                   sshagent(['deploy-server-ssh-key']) {
                      withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP} 'sudo docker login -u $USERNAME -p $PASSWORD'"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP} 
                   def ShellCmd="sudo docker run -itd -P swarnavure/myimage:$BUILD_NUMBER"
                }
            }
    }
 }
}
