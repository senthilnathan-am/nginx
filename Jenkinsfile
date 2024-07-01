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
                 release_type=`grep -i 'release_type' RELEASE | awk '{print $3}' | tr -d "\'"`
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

        stage("Helm Chart Preparation") {
            steps {
                sh '''
                  cd chart
                  chart_version=`grep appVersion Chart.yaml | awk '{print $2}' | tr -d '\"'`
                  value_tag=`grep tag values.yaml | awk '{print $2}' | tr -d '\"'`
                  `sed -i "'"s/"""${value_tag}"""/"""${tag}${BUILD_NUMBER}"""/g"'" values.yaml`
                  if [ $release_type == "Major" ]; then
                      i=$(echo $chart_version | awk '{print $1}' | cut -d'.' -f1
                      j=$(echo $chart_version | awk '{print $1}' | cut -d'.' -f2
                      k=$(echo $chart_version | awk '{print $1}' | cut -d'.' -f3
                      i=$(expr $i + 1)
                  new_chat_version=$i.$j.$k
                  sed -i "'"s/$chart_version/$new_chat_version/g"'" Chart.yaml
                  helm package .
                '''
            }
        }
    }
}
