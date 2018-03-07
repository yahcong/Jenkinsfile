pipeline {
  agent any
  stages {
    stage('Test') {
      steps {
        sh 'ls'
        sh '''echo aaaa
'''
        sh '''touch test_port.xml
'''
      }
    }
  }
  post {
    always {
      junit 'build/reports/**/*.xml'
      
    }
    
  }
}