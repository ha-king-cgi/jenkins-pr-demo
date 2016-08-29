node {
  try {
  
    bitbucketStatusNotify ( buildState: 'INPROGRESS' )
    
    stage 'checkout'
      checkout scm
      println "Bulding branch: ${env.BRANCH_NAME}"
   
    stage 'validate template'
      sh 'aws cloudformation validate-template --template-body file://Jenkins-Demo-PR.json'


    switch(env.BRANCH_NAME) {
      case ['master', 'development', 'staging', 'production']:
        stage "Deploy to ${env.BRANCH_NAME}"
          println "Deploy to ${env.BRANCH_NAME}.."

      case ~/^PR-[0-9]+/:
        def old_environments = []
        stage 'Find Old Stacks'
          println 'TODO: Identify if old environments exist for this branch'
          println "Current Branch: ${env.BRANCH_NAME}"
          def old_stacks = sh (
	          script: "aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE | grep "\-Jenkins\-" | grep "StackName" | cut -d':' -f2 | sed -e 's/\"//g;s/\,//g;s/\ //g'",
              returnStdout: true
          )
          println old_stacks
          

        if (!old_environments?.empty) {
          stage 'Destroy Old Stacks'
            println 'TODO: Tearing down old environments'
            
            //def stack_name = old_environments[0]
            //sh 'aws cloudformation delete-stack --stack-name ${stack_name} '
        }
        
        stage 'Create Ephemeral Environment'
          println 'Deploy Ephemeral Stack'

          def author = sh (
              script: 'git --no-pager show -s --format="%an"',
              returnStdout: true
          ).replaceAll("\\s","")

          def build_time = sh (
              script: 'date +%s',
              returnStdout: true
          )

          def stack_name = "Jenkins-${env.BRANCH_NAME}-${build_time}-${author}"
          def tags = "Key=author,Value=${author}"
          def file = 'Jenkins-Demo-PR.json'
          def create_new_stack = "aws cloudformation create-stack --stack-name ${stack_name} --tags ${tags} --template-body file://${file}"
          println create_new_stack
          
          currentBuild.result = 'SUCCESS'
          
      default:
        stage "Abort build if not PR"
          println "Not a PR"
		  println "Current Branch: ${env.BRANCH_NAME}"
		  currentBuild.result = 'FAILURE'
		  
	  stage "Notify bitbucket"
	    println "Notify bitbucket with build status"
	    println "RESULT: ${currentBuild.result}"
	    
	    switch(currentBuild.result){
	      case ['SUCCESS']:
	        bitbucketStatusNotify ( buildState: 'SUCCESSFUL' )
	      case ['FAILURE']:
	        bitbucketStatusNotify ( buildState: 'FAILURE' )
	      default:
	        bitbucketStatusNotify ( buildState: 'UNSTABLE' )
	    }

    }

  } catch(e) {
      println 'Build failed...'
      throw(e)
   }
}
