pipeline {
  agent any
  stages {
    stage('test') {
      steps {
        sh 'ls'
        sh '''echo aaaa
'''
        sh 'mkdir -p build/reports/test/'
        sh '''touch build/reports/test/post.xml
'''
      }
    }
    stage('test2') {
      steps {
        echo 'eeee'
      }
    }
    stage('sleep') {
      steps {
        sleep(time: 1, unit: 'SECONDS')
      }
    }
  }
}