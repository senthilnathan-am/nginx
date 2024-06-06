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
    }
}
