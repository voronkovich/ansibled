# Ansibled

A wrapper for [Ansible](https://ansible.com) that provides a consistent, containerized execution environment.

## Features

- Runs Ansible commands in a containerized environment ([Docker](https://docker.com), [Podman](https://podman.io), [nerdctl](https://github.com/containerd/nerdctl))
- Supports multiple versions of Ansible through container images
- Loads configuration from multiple sources: configuration files and environment variables
- Automatically mounts your SSH private keys
- Debug mode for troubleshooting

## Requirements

- Unix-like OS (e.g. Linux, MacOS)
- Docker compatible container runtime installed on your system
- Bash shell

## Installation

1. Clone this repository to your preferred directory:

   ```sh
   git clone https://github.com/voronkovich/ansibled ~/.local/share/ansibled
   ```

2. Add the `bin` directory to your `PATH` (in your `.bashrc` or equivalent):

   ```sh
   export PATH="${HOME}/.local/share/ansibled/bin:${PATH}"
   ```

## Usage

The tool provides wrapper commands for common Ansible utilities:

```bash
ansible           # Runs ansible command
ansible-config    # Runs ansible-config
ansible-galaxy    # Runs ansible-galaxy
ansible-lint      # Runs ansible-lint
ansible-playbook  # Runs ansible-playbook
ansible-vault     # Runs ansible-vault
```

All commands work similarly to their native Ansible counterparts but run within the containerized environment.

Example:

```sh
ansible all -m ping
```

This will:

1. Start a container with the configured Ansible version
2. Mount your current directory as `/ansible`
3. Mount your SSH private key (if configured)
4. Run the Ansible command within the container


## Configuration

The tool loads configuration from these sources:

1. User config: `~/.config/ansibled` or `~/.ansibled`
2. Local config: `.ansibled` and `.ansibled.local` in your project's root directory
3. Environment variables (`ANSIBLED_*`, `ANSIBLE_*`)

All config values are merged and imported into the container as environment variables.

The config files are just simple `.env` files.

The `.ansibled.local` file is used to override values from the `.ansibled` file and should not be committed to version control.

### Available options

#### ANSIBLED_VERSION

Container image tag e.g. `2.11-alpine-3.15`.

Default: `alpine`.

#### ANSIBLED_IMAGE

Container image name.

Default: [willhallonline/ansible](https://hub.docker.com/r/willhallonline/ansible).

#### ANSIBLED_RUNTIME

Container runtime: `docker`, `podman`, `nerdctl` and etc.

Default: `docker` if available, else `podman` or `nerdctl`.

#### ANSIBLED_SSH_PRIVATE_KEY

SSH private key.

Default: `~/.ssh/id_rsa`.

#### ANSIBLED_OPTS

Extra options passed directly to container runtime command.

Example: `--memory=256m --cpus=0.5`

#### ANSIBLED_DEBUG

Enable debug output (`0` or `1`).

Default: `0`.

#### ANSIBLE_*

Any Ansible [configuration option](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#common-options).

### Example:

```env
# Ansibled configuration
ANSIBLED_RUNTIME=podman
ANSIBLED_IMAGE=docker://alpine/ansible
ANSIBLED_VERSION=2.18.1
ANSIBLED_SSH_PRIVATE_KEY=/home/user/.ssh/secret_key

# Ansible configuration
ANSIBLE_HOST_KEY_CHECKING=False
ANSIBLE_NOCOWS=True
```

## Debugging

Run with debug output:

```sh
ANSIBLED_DEBUG=1 ansible all -m ping
```

This will show the complete configuration and command that will be executed.

## Testing

This project uses [ShellSpec](https://shellspec.info) for testing. To run the tests:

```sh
shellspec
```

## License

Copyright (c) Voronkovich Oleg. Distributed under the MIT.
