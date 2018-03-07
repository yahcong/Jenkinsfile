pipeline {
  agent none
  stages {
    stage('Test') {
      steps {
        sh 'ls'
        sh '''echo aaaa
'''
        sh 'mkdir -p build/reports/test/'
        sh '''touch build/reports/test/post.xml

echo "<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE suite SYSTEM "http://testng.org/testng-1.0.dtd" >
<suite name="Suite1">
    <test name="test12">
        <classes>
            <class name="TankLearn2.Learn.TestNGLearn1" />
        </classes>
    </test>
</suite>" >build/reports/test/post.xml
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