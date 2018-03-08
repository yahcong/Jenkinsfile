pipeline {
  agent any
  stages {
    stage('test') {
      steps {
        sh 'ls'
        sh '''echo aaaa
'''
        sh '''touch post.xml
'''
      }
    }
    stage('test2') {
      steps {
        echo 'eeee'
        junit(allowEmptyResults: true, testResults: '*.xml')
      }
    }
    stage('sleep') {
      steps {
        sleep(time: 1, unit: 'SECONDS')
      }
    }
    stage('post_result') {
      steps {
        junit(testResults: '*.xml', allowEmptyResults: true)
      }
    }
  }
}