#shellcheck shell=sh

Describe 'ansibled'
    Mock docker
        echo docker "$@"
    End

    It 'prefers Podman over Docker'
        Mock podman
            echo podman "$@"
        End

        When run script ansibled
        The output should start with 'podman run'
        The status should be success
    End

    It 'falls back to Docker when Podman missing'
        When run script ansibled
        The output should start with 'docker run'
        The status should be success
    End

    It 'uses spcecified container runtime'
        Mock podman
            echo podman "$@"
        End

        export ANSIBLED_RUNTIME=podman
        When run script ansibled
        The output should start with 'podman run'
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
        cd 'spec/fixtures'

        When run script ansibled
        The output should match pattern '*--env-file*.ansibled*--env-file*.ansibled.local*'
        The status should be success
    End

    It 'loads configuration from files'
        cd 'spec/fixtures'

        When run script ansibled
        The output should include '2.9-ubuntu-3.17'
        The output should include '-v /home/ansibled/.ssh/secret_key:/root/.ssh/id_rsa:ro'
        The status should be success
    End
End
