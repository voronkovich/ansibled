#shellcheck shell=sh

declare -r FIXTURES="${SHELLSPEC_PROJECT_ROOT}/spec/fixtures"
declare -r ORIGINAL_PATH="${PATH}"

Describe 'ansibled'
    BeforeEach 'setup'
    setup() {
        PATH="${FIXTURES}/bin:${PATH}"
        HOME="${FIXTURES}"
        unset $(compgen -e ANSIBLED_)
        unset $(compgen -e ANSIBLE_)
    }

    AfterEach 'cleanup'
    cleanup() {
        PATH="${ORIGINAL_PATH}"
    }

    It 'prefers docker over other runtimes'
        When run command ansibled
        The output should start with 'docker run'
        The status should be success
    End

    It 'uses specified container runtime'
        export ANSIBLED_RUNTIME=podman

        When run command ansibled
        The output should start with 'podman run'
        The status should be success
    End

    It 'launches shell by default'
        When run command ansibled
        The output should end with ' sh'
        The status should be success
    End

    It 'uses specified image version'
        export ANSIBLED_IMAGE=test-image
        export ANSIBLED_VERSION=test-version

        When run command ansibled
        The output should include 'test-image:test-version'
        The status should be success
    End

    It 'mounts current working dir to /ansible'
        When run command ansibled
        The output should include "-v ${PWD}:/ansible"
        The status should be success
    End

    It 'mounts specified SSH key'
        export ANSIBLED_PRIVATE_KEY='/home/ansibled/.ssh/secret_key'

        When run command ansibled
        The output should include '-v /home/ansibled/.ssh/secret_key:/root/.ssh/id_rsa:ro'
        The status should be success
    End

    Describe 'shows error when required option is missing'
        Parameters
            ANSIBLED_IMAGE
            ANSIBLED_VERSION
            ANSIBLED_RUNTIME
        End
        It "${1}"
            export "${1}"=''

            When run ansibled
            The status should be failure
            The error should include "ansibled ERROR: ${1} is required."
        End
    End

    It 'shows debug output when enabled'
        export ANSIBLED_DEBUG=1

        When run command ansibled
        The error should include 'Configuration files:'
        The error should include 'Configuration:'
        The error should include 'ANSIBLED_DEBUG=1'
        The status should be success
    End

    It 'passes extra options to container runtime'
        export ANSIBLED_OPTS='--memory=256m --cpus=0.5'

        When run command ansibled
        The output should include '--memory=256m'
        The output should include '--cpus=0.5'
        The status should be success
    End

    It 'passes through ANSIBLE_* environment variables'
        export ANSIBLE_FOO=foo
        export ANSIBLE_BAR=bar

        When run command ansibled
        The output should include '-e ANSIBLE_FOO=foo'
        The output should include '-e ANSIBLE_BAR=bar'
        The status should be success
    End

    It 'mounts configuration files'
        HOME="${FIXTURES}/home"
        cd "${FIXTURES}/project"

        When run command ansibled
        The output should match pattern '*--env-file*home/.config/ansibled*--env-file*project/.ansibled*--env-file*project/.ansibled.local*'
        The status should be success
    End

    It 'loads own configuration from files'
        HOME="${FIXTURES}/home"
        cd "${FIXTURES}/project"

        When run command ansibled
        The output should start with 'nerdctl run'
        The output should include 'voronkovich/ansible:2.10-ubuntu'
        The output should include '-v /home/oleg/.ssh/secret_key:/root/.ssh/id_rsa:ro'
        The status should be success
    End

    It 'gives preference to envs over configuration files'
        export ANSIBLED_IMAGE=test-image
        export ANSIBLED_VERSION=test-version
        HOME="${FIXTURES}/home"
        cd "${FIXTURES}/project"

        When run command ansibled
        The output should include 'test-image:test-version'
        The status should be success
    End
End
