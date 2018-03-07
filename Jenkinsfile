pipeline {
  agent any
  stages {
    stage('Test') {
      steps {
        sh 'ls'
      }
    }
  }
  post {
      always{
          junit 'build/reports/**/*.xml'
      }
  }
}
