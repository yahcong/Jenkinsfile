pipeline {
  agent any
  stages {
    stage('Test') {
      steps {
        sh 'ls'
        sh '''echo aaaa
'''
      }
    }
  }
  post {
    always {
      junit '*.xml' 
    }
  }
}
