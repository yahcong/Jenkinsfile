pipeline {
  agent any
  stages {
    stage('Test') {
      steps {
        sh 'ls'
        sh '''echo aaaa
'''
        sh 'mkdir -p build/reports/test/'
        sh '''touch build/reports/test/post.xml
echo "<?xml version="1.0" encoding="UTF-8"?>
<suite name="Simple HTML-XML Suite">
  
  <test name="Simple HTML-XML test">
    <classes>
      <class name="SampleTest" />
    </classes>
  </test>
</suite>" >post.xml
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