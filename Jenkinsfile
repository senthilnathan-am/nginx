pipeline {
    agent any
    stages {
        stage("Clone Git Repository") {
            steps {
                    git(
                        url: "https://github.com/senthilnathan-am/nginx.git",
                        branch: "main",
                        changelog: true,
                        poll: true
                    )
            }
        }

        stage("Building nginx container image") {
            steps {
               sh '''
                 tag=v1.0.0
                 podman build -t senthilnathanam/nginx-realip:$tag .
               '''
            }
        }

        stage("ECR Push") {
            steps {
               sh '''
                 tag=v1.0.0
                 podman push senthilnathanam/nginx-realip:$tag
               '''
            }
        }
    }
}
