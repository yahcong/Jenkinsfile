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
    stage('Print Message') {
      steps {
        echo 'eeee'
      }
    }
    stage('sleep') {
      parallel {
        stage('sleep') {
          steps {
            sleep(time: 1, unit: 'SECONDS')
          }
        }
        stage('Mail') {
          steps {
            mail(subject: 'test Jenkisn Mail', body: 'check Jenkisn Mail', from: 'Jenkisn@ebupt.com', to: 'congyahuan@ebupt.com')
          }
        }
      }
    }
    stage('post_result') {
      steps {
        junit(testResults: '*.xml', allowEmptyResults: true)
      }
    }
  }
}