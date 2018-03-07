pipeline {
  agent any
  stages {
    stage('Test') {
      steps {
        sh 'ls'
        sh '''echo aaaa
'''
        sh '''mkdir -p build/reports/test/port.xml
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