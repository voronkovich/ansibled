#shellcheck shell=sh

declare -r FIXTURES="${PWD}/spec/fixtures"

Describe 'ansibled'
    Before 'setup'
    setup() {
        export PATH="${FIXTURES}/bin:${PATH}"
        export HOME="${PWD}/spec"
    }

    It 'prefers Podman over Docker'
        export PATH="${FIXTURES}/bin-podman:${PATH}"

        When run script ansibled
        The output should start with 'podman run'
        The status should be success
    End

    It 'falls back to Docker when Podman missing'
        When run script ansibled
        The output should start with 'docker run'
        The status should be success
    End

    It 'uses specified container runtime'
        export ANSIBLED_RUNTIME=rkt

        When run script ansibled
        The output should start with 'rkt run'
        The status should be success
    End

    It 'launches shell by default'
        When run script ansibled
        The output should end with ' sh'
        The status should be success
    End

    It 'uses specified image version'
        export ANSIBLED_IMAGE=test-image
        export ANSIBLED_VERSION=test-version

        When run script ansibled
        The output should include 'test-image:test-version'
        The status should be success
    End

    It 'mounts current working dir to /ansible'
        When run script ansibled
        The output should include "-v ${PWD}:/ansible"
        The status should be success
    End

    It 'mounts specified SSH key'
        export ANSIBLED_PRIVATE_KEY='/home/ansibled/.ssh/secret_key'

        When run script ansibled
        The output should include '-v /home/ansibled/.ssh/secret_key:/root/.ssh/id_rsa:ro'
        The status should be success
    End

    It 'shows debug output when enabled'
        export ANSIBLED_DEBUG=1

        When run script ansibled
        The error should include 'Configuration files:'
        The error should include 'Configuration:'
        The error should include 'ANSIBLED_DEBUG=1'
        The status should be success
    End

    It 'passes through ANSIBLE_* environment variables'
        export ANSIBLE_FOO=foo
        export ANSIBLE_BAR=bar

        When run script ansibled
        The output should include '-e ANSIBLE_FOO=foo'
        The output should include '-e ANSIBLE_BAR=bar'
        The status should be success
    End

    It 'mounts configuration files'
        export HOME="${FIXTURES}/home"
        cd "${FIXTURES}/project"

        When run script ansibled
        The output should match pattern '*--env-file*home/.config/ansibled*--env-file*project/.ansibled*--env-file*project/.ansibled.local*'
        The status should be success
    End

    It 'loads own configuration from files'
        export HOME="${FIXTURES}/home"
        cd "${FIXTURES}/project"

        When run script ansibled
        The output should include 'voronkovich/ansible:2.10-ubuntu'
        The output should include '-v /home/oleg/.ssh/secret_key:/root/.ssh/id_rsa:ro'
        The status should be success
    End

    It 'gives preference to envs over configuration files'
        export ANSIBLED_IMAGE=test-image
        export ANSIBLED_VERSION=test-version
        export HOME="${FIXTURES}/home"
        cd "${FIXTURES}/project"

        When run script ansibled
        The output should include 'test-image:test-version'
        The status should be success
    End
End
