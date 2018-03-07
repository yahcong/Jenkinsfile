pipeline {
  agent any
  stages {
    stage('Test') {
      steps {
        sh 'ls'
        sh '''echo aaaa
'''
        sh '''mkdir -p build/reports/test/
cp /home/ycong/jenkins/port.xml build/reports/test/'''
      }
    }
  }
  post {
    always {
      junit 'build/reports/**/*.xml'
      
    }
    
  }
}