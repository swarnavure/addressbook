pipeline{
    agent any
    tools{
        maven 'mymaven'
        jdk 'myjava'
    }
     environment{
        IMAGE_NAME = 'swarnavure/myimage:$BUILD_NUMBER'
        DEV_SERVER_IP = 'ec2-user@3.110.114.84'
        APP_NAME = 'java-mvn-app'
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
        stage("Build the docker image on build server"){
            steps{
                script{

                    echo "Building the docker image"
                    sh 'sudo yum install docker -y'
                    sh 'sudo systemctl start docker'
                    sshagent(['ssh-key']) {
                     withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                     sh "ssh -o StrictHostKeyChecking=no server-script.sh ${DEV_SERVER_IP}:/home/ec2-user"
                     sh "ssh -o StrictHostKeyChecking=no ${DEV_SERVER_IP} 'bash ~/server.script.sh'"
                                   
                     sh "ssh ${DEV_SERVER_IP} sudo docker build -t ${IMAGE_NAME} /home/ec2-user/addressbook"
                     sh "ssh ${DEV_SERVER_IP} sudo docker login -u $USER -p $PASS"
                     sh "ssh ${DEV_SERVER_IP} sudo docker push ${IMAGE_NAME}"
              }
            }
           }
         } 
        } 
        stage("Provision deploy server"){
        environment{
            AWS_ACCESS_KEY_ID =credentials("AWS_ACCESS_KEY_ID")
            AWS_SECRET_ACCESS_KEY=credentials("AWS_SECRET_ACCESS_KEY")
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
            echo "deploying the app"
            sshagent(['ssh-key']) {
                      withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP} 'sudo docker login -u $USERNAME -p $PASSWORD'"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP}  ${ShellCmd}"
            def ShellCmd=sh "sudo docker run -itd -P swarnavure/myimage:$BUILD_NUMBER"
           }
            }
     }
    }
   }
 } 
}