pipeline {
    agent any
    stages {
        stage("Clone Git Repository") {
            steps {
                dir("neptune") {
                    git(
                        url: "https://https://github.com/senthilnathan-am/nginx.git",
                        branch: "main",
                        changelog: true,
                        poll: true
                    )
                }
            }
        }
    }
}
