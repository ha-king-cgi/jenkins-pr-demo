#!/usr/bin/env groovy
node {
  try {
  
    bitbucketStatusNotify ( buildState: 'INPROGRESS' )
    
    stage 'checkout'
      checkout scm
      println "Bulding branch: ${env.BRANCH_NAME}"
   
    stage 'validate template'
      sh 'aws cloudformation validate-template --template-body file://cfnTemplate.json'


    switch(env.BRANCH_NAME) {
      case ['master', 'development', 'staging', 'production']:
        stage "Deploy to ${env.BRANCH_NAME}"
          println "Deploy to ${env.BRANCH_NAME}.."

      case ~/^PR-[0-9]+/:

        stage 'Find Old Stacks'
          def stacks = sh (
           script: "aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE --query 'StackSummaries[].StackName' --output text",
           returnStdout: true
          ).trim()
          
          String stacksList = stacks
          String delims = "[	]";
          String[] result = stacksList.split(delims);

        stage 'Destroy Old Stacks'
          for (int x=0; x<result.length; x++) {
            println result[x]
            if ( result[x] =~ /Jenkins-${env.BRANCH_NAME}-[0-9]*-\w/ ) {
              println "Found old stack: ${result[x]}"
                def destroy_stacks = "aws cloudformation delete-stack --stack-name '${result[x]}'"
                println destroy_stacks
                sh destroy_stacks
                println "DESTROYED_STACK: '${result[x]}'"
            }
          }
                  
        stage 'Create Ephemeral Environment'
          println 'Deploy Ephemeral Stack'

          def author = sh (
              script: 'git --no-pager show -s --format="%an"',
              returnStdout: true
          ).replaceAll("\\s","").trim()

          def build_time = sh (
              script: 'date +%s',
              returnStdout: true
          ).trim()

          def stack_name = "Jenkins-${env.BRANCH_NAME}-${build_time}-${author}"
          def tags = "Key=author,Value=${author}"
          def file = 'cfnTemplate.json'
          def create_new_stack = "aws cloudformation create-stack --stack-name '${stack_name}' --tags '${tags}' --template-body file://${file}"

          println create_new_stack
          sh create_new_stack
          
          currentBuild.result = 'SUCCESS'
          
      default:
        stage "Abort build if not PR"
          println "NOT A PULL REQUEST"
		  println "CURRENT_BRANCH: ${env.BRANCH_NAME}"
		  
		  currentBuild.result = 'SUCCESS'

    }
    stage 'Notify bitbucket'
	    println "Notify bitbucket with build status"
	    println "RESULT: ${currentBuild.result}"
	    
	    switch(currentBuild.result){
	      case ['SUCCESS']:
	        bitbucketStatusNotify ( buildState: 'SUCCESSFUL' )
	        break
	      case ['FAILURE']:
	        bitbucketStatusNotify ( buildState: 'FAILURE' )
	        break
	      default:
	        bitbucketStatusNotify ( buildState: 'UNSTABLE' )
	        break
	    }
	    println "CURRENT_BUILD: ${currentBuild.result}"

  } catch(e) {
      println 'BUILD FAILED...'
      throw(e)
      bitbucketStatusNotify ( buildState: 'FAILURE' )
   }
}
