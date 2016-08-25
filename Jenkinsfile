node {
  try {
    stage 'checkout'
      checkout scm
      println "Bulding branch: ${env.BRANCH_NAME}"
   
    stage 'validate template'
      sh 'aws cloudformation validate-template --template-body file://Jenkins-Demo-PR.json'


    switch(env.BRANCH_NAME) {
      case ['master', 'development', 'staging', 'production']:
        stage "Deploy to ${env.BRANCH_NAME}"
          println "Deploy to ${env.BRANCH_NAME}.."

      case ~/PR-*/:
        def old_environments = []
        stage 'Find Old Stacks'
          println 'TODO: Identify if old environments exist for this branch'

        if (!old_environments?.empty) {
          stage 'Destroy Old Stacks'
            println 'TODO: Tearing down old environments'
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

          default:
            stage "Abort build if not PR"
              println "Not a PR"

        stage "Notify bitbucket"
          println "Notify bitbucket with build status"
    }
  } catch(e) {
      println 'Build failed...'
      throw(e)
   }
}
