pipeline {
    agent any
    environment{
        tag='v1.0.0_'
    }
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
                 podman build -t senthilnathanam/nginx-realip:$tag$BUILD_NUMBER .
               '''
            }
        }

        stage("Docker Registry Push") {
            steps {
               sh '''
                 podman login -u senthilnathan@assistanz.com --password-stdin < /dockerpwd.txt docker.io
                 podman push senthilnathanam/nginx-realip:$tag$BUILD_NUMBER
               '''
            }
        }
    }
}
