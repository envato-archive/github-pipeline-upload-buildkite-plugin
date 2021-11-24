#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment the following line to debug stub failures
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Uploads the a pipeline file" {
  export BUILDKITE_REPO="git@github.com:myorg/myrepo.git"
  export GITHUB_ACCESS_TOKEN="auth_token"
  
  stub curl "--silent --fail -H \"Authorization: token auth_token\" -H \"Accept: application/vnd.github.v3.raw\" -L https://api.github.com/repos/myorg/myrepo/contents/.buildkite/pipeline.yml : echo pipeline_contents"
  stub buildkite-agent 'pipeline upload : echo "buildkite-agent pipeline upload $(cat -)"'

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "buildkite-agent pipeline upload pipeline_contents"

  unstub buildkite-agent
  unstub curl
}

@test "Uploads a pipeline file param" {
  export BUILDKITE_PLUGIN_GITHUB_PIPELINE_UPLOAD_FILE="my-app/my-pipeline.yml"
  export BUILDKITE_REPO="git@github.com:myorg/myrepo.git"
  export GITHUB_ACCESS_TOKEN="auth_token"
  
  stub curl "--silent --fail -H \"Authorization: token auth_token\" -H \"Accept: application/vnd.github.v3.raw\" -L https://api.github.com/repos/myorg/myrepo/contents/my-app/my-pipeline.yml : echo pipeline_contents"
  stub buildkite-agent 'pipeline upload : echo "buildkite-agent pipeline upload $(cat -)"'

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "buildkite-agent pipeline upload pipeline_contents"

  unstub buildkite-agent
  unstub curl
}


@test "Parsing git repo issue" {
  export BUILDKITE_REPO="bad_git_url"

  run "$PWD/hooks/command"

  assert_failure
  assert_output --partial "Failed to extract repository slug from BUILDKITE_REPO"
}

@test "Missing github token" {
  export BUILDKITE_REPO="git@github.com:myorg/myrepo.git"

  run "$PWD/hooks/command"

  assert_failure
  assert_output --partial "Missing required GITHUB_ACCESS_TOKEN"
}

@test "Github API failure" {
  export BUILDKITE_REPO="git@github.com:myorg/myrepo.git"
  export GITHUB_ACCESS_TOKEN="auth_token"

  stub curl "--silent --fail -H \"Authorization: token auth_token\" -H \"Accept: application/vnd.github.v3.raw\" -L https://api.github.com/repos/myorg/myrepo/contents/.buildkite/pipeline.yml : exit 1"

  run "$PWD/hooks/command"

  assert_failure
  assert_output --partial "Github API Error"
}