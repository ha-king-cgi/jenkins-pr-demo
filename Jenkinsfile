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
          sh 'for stacks in $(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE --query "StackSummaries[].StackId" | grep "Jenkins-[A-Z]*-[0-9]*-[0-9]*"  | sed s/\"//g | sed s/\,//g); do $time=$(echo $stacks | cut -d'/' -f2 | cut -d'-' -f4);$thirty_minutes_ago=$(date -d "30 min ago" +%s);if [ "$time" -lt "$thirty_minutes_ago" ]; then aws cloudformation delete-stack --stackId ${stacks};fi;done'

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
          ).replaceAll("\\s","").trim()

          def build_time = sh (
              script: 'date +%s',
              returnStdout: true
          ).trim()

          def stack_name = "Jenkins-${env.BRANCH_NAME}-${build_time}-${author}"
          def tags = "Key=author,Value=${author}"
          def file = 'Jenkins-Demo-PR.json'
          def create_new_stack = "aws cloudformation create-stack --stack-name '${stack_name}' --tags '${tags}' --template-body file://${file}"

          println create_new_stack
          
          sh create_new_stack
          
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
