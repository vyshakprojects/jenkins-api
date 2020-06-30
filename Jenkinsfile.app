pipeline {
    agent any
    parameters {
        choice(name: 'app_name', choices: ['engati-portal', 'engati-bot', 'engati-answers'], description: 'Select applicaiton to deploy')
        string(name: 'version', defaultValue: '', description: 'enter your feature-branch Version')
    }
    stages {
        stage('Adding IPs') {
            steps {
            {
                sh "echo deploying ${params.app_name} ${params.version}"
              }
          }
      }
  }
}
