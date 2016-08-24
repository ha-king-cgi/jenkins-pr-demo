def project = 'jenkins-pr-demo'

node {
  try {
    stage 'checkout'
    checkout scm

    stage 'validate template'
    sh 'aws cloudformation validate-template --template-body file://Jenkins-Demo-PR.json


    switch(env.BRANCH_NAME) {
      case ~/(master|development|staging|production)/:
        def build_environment = Matcher.lastMatcher[0][1]
        stage "deploy to ${build_environment}"
        println "Deploy to ${build_environment}.."
      
      default:
        stage 'create ephemeral environment'
        println 'Deploy to development'
        def author = sh('git --no-pager show -s --format="%an"').replaceAll("\\s","")
        def stack_name = "Jenkins-${unix_time}-${author}"
        def tags = "Key=author,Value=${author}"
        def file = 'Jenkins-Demo-PR.json'
        def command = "aws cloudformation create-stack --stack-name ${stack_name} --tags ${tags} --template-body file://${file}"
        sh command
    }
  } catch(e) {
      println 'Build failed...'
      throw(e)
   }
}
