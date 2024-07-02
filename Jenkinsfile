pipeline {
    agent any
    environment{
        tag='v1.0.0'
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
                 podman rmi --all
                 image_tag=`curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/senthilnathanam/nginx-realip/tags/?page_size=100 | jq -r '.results|.[]|.name+" "+.content_type' | grep image | awk 'NR==1{print $1}' | tr -d "v"`
                 release_type=`grep -i 'release_type' RELEASE | awk '{print $3}' | tr -d "\'"`
                 podman build -t senthilnathanam/nginx-realip .
                 if [ -z "$image_tag" ]; then
                   podman tag senthilnathanam/nginx-realip senthilnathanam/nginx-realip:$tag
                 elif [ "$release_type" = "Major" ]; then
                     i=`echo $image_tag | awk "{print $1}" | cut -d"." -f1`
                     j=`echo $image_tag | awk "{print $1}" | cut -d"." -f2`
                     k=`echo $image_tag | awk "{print $1}" | cut -d"." -f3`
                     i=$(expr $i + 1)
                     new_tag=v$i.$j.$k
                     podman tag senthilnathanam/nginx-realip senthilnathanam/nginx-realip:$new_tag
                 elif [ "$release_type" = "Minor" ]; then
                     i=`echo $image_tag | awk "{print $1}" | cut -d"." -f1`
                     j=`echo $image_tag | awk "{print $1}" | cut -d"." -f2`
                     k=`echo $image_tag | awk "{print $1}" | cut -d"." -f3`
                     if [ "$j" -gt 9 ]; then
                       j=0
                       i=$(expr $i + 1)
                     else
                       j=$(expr $j + 1)
                     fi
                     new_tag=v$i.$j.$k
                     podman tag senthilnathanam/nginx-realip senthilnathanam/nginx-realip:$new_tag
                 elif [ "$release_type" = "Patch" ]; then
                     i=`echo $image_tag | awk "{print $1}" | cut -d "." -f1`
                     j=`echo $image_tag | awk "{print $1}" | cut -d "." -f2`
                     k=`echo $image_tag | awk "{print $1}" | cut -d "." -f3`
                     if [ "$k" -gt 20 ]; then
                       exit;
                     else
                       k=$(expr $k + 1)
                     fi
                     new_tag=v$i.$j.$k
                     podman tag senthilnathanam/nginx-realip senthilnathanam/nginx-realip:$new_tag
                 fi
               '''
            }
        }

        stage("Docker Registry Push") {
            steps {
               sh '''
                 podman login -u senthilnathan@assistanz.com --password-stdin < /dockerpwd.txt docker.io
                 image_tag=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/senthilnathanam/nginx-realip/tags/?page_size=100 | jq -r '.results|.[]|.name+" "+.content_type' | grep image | awk 'NR==1{print $1}' | tr -d "v")
                 release_type=`grep -i 'release_type' RELEASE | awk '{print $3}' | tr -d "\'"`
                 if [ -z $image_tag ]; then
                   podman push senthilnathanam/nginx-realip:$tag
                 elif [ "$release_type" = "Major" ]; then
                     i=`echo $image_tag | awk "{print $1}" | cut -d"." -f1`
                     j=`echo $image_tag | awk "{print $1}" | cut -d"." -f2`
                     k=`echo $image_tag | awk "{print $1}" | cut -d"." -f3`
                     i=$(expr $i + 1)
                     new_tag=v$i.$j.$k
                     podman push senthilnathanam/nginx-realip:$new_tag
                 elif [ "$release_type" = "Minor" ]; then
                     i=`echo $image_tag | awk "{print $1}" | cut -d"." -f1`
                     j=`echo $image_tag | awk "{print $1}" | cut -d"." -f2`
                     k=`echo $image_tag | awk "{print $1}" | cut -d"." -f3`
                     if [ "$j" -gt 9 ]; then
                       j=0
                       i=$(expr $i + 1)
                     else
                       j=$(expr $j + 1)
                     fi
                     new_tag=v$i.$j.$k
                     podman push senthilnathanam/nginx-realip:$new_tag
                 elif [ "$release_type" = "Patch" ]; then
                     i=`echo $image_tag | awk "{print $1}" | cut -d "." -f1`
                     j=`echo $image_tag | awk "{print $1}" | cut -d "." -f2`
                     k=`echo $image_tag | awk "{print $1}" | cut -d "." -f3`
                     if [ "$k" -gt 20 ]; then
                       exit;
                     else
                       k=$(expr $k + 1)
                     fi
                     new_tag=v$i.$j.$k
                     podman push senthilnathanam/nginx-realip:$new_tag
                 fi
               '''
            }
        }

        stage("Helm Chart Preparation") {
            steps {
                  sh '''
                    release_type=`grep -i 'release_type' RELEASE | awk '{print $3}' | tr -d "\'"`
                    cd chart
                    chart_version=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/senthilnathanam/nginx-realip/tags/?page_size=100 | jq -r '.results|.[]|.name+" "+.content_type' | grep helm | awk 'NR==1{print $1}')
                    old_image_tag=`grep tag values.yaml | awk '{print $2}' | tr -d '\"'`
                    new_image_tag=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/senthilnathanam/nginx-realip/tags/?page_size=100 | jq -r '.results|.[]|.name+" "+.content_type' | grep image | awk 'NR==1{print $1}')
                    `sed -i "s/$old_image_tag/$new_image_tag/g" values.yaml`
                    if [ "$chart_version" ]; then
                      if [ "$release_type" = "Major" ]; then
                        i=`echo $chart_version | awk "{print $1}" | cut -d "." -f1`
                        j=`echo $chart_version | awk "{print $1}" | cut -d "." -f2`
                        k=`echo $chart_version | awk "{print $1}" | cut -d "." -f3`
                        i=$(expr $i + 1)
                        new_chart_version=$i.$j.$k
                        `sed -i "s/$chart_version/$new_chart_version/g" Chart.yaml`
                      elif [ "$release_type" = "Minor" ]; then
                        i=`echo $chart_version | awk "{print $1}" | cut -d "." -f1`
                        j=`echo $chart_version | awk "{print $1}" | cut -d "." -f2`
                        k=`echo $chart_version | awk "{print $1}" | cut -d "." -f3`
                        if [ "$j" -gt 9 ]; then
                          j=0
                          i=$(expr $i + 1)
                        else
                          j=$(expr $j + 1)
                        fi
                        new_chart_version=$i.$j.$k
                        `sed -i "s/$chart_version/$new_chart_version/g" Chart.yaml`
                      elif [ "$release_type" = "Patch" ]; then
                        i=`echo $image_tag | awk "{print $1}" | cut -d "." -f1`
                        j=`echo $image_tag | awk "{print $1}" | cut -d "." -f2`
                        k=`echo $image_tag | awk "{print $1}" | cut -d "." -f3`
                        if [ "$k" -gt 20 ]; then
                          exit;
                        else
                          k=$(expr $k + 1)
                        fi
                        new_chart_version=$i.$j.$k
                        `sed -i "s/$chart_version/$new_chart_version/g" Chart.yaml`
                      fi
                    fi
                    helm package . 
                    cat /dockerpwd.txt | helm registry login -u senthilnathan@assistanz.com --password-stdin registry-1.docker.io
                    helm push *.tgz oci://registry-1.docker.io/senthilnathanam
                  '''
            }
        }
    }
}
