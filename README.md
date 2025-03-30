# Ansibled

A wrapper for [Ansible](https://ansible.com) that provides a consistent, containerized execution environment.

## Features

- Runs Ansible commands in a containerized environment ([Docker](https://docker.com) or [Podman](https://podman.io))
- Supports multiple versions of Ansible through container images
- Loads configuration from multiple sources: configuration files and environment variables
- Automatically mounts your SSH private keys
- Debug mode for troubleshooting

## Requirements

- Unix-like OS (e.g. Linux, MacOS)
- Docker or Podman installed on your system
- Bash shell

## Installation

1. Clone this repository to any appropriate location

```bash
git clone https://github.com/voronkovich/ansibled ~/.local/share
```

2. Add the `bin` directory to your `PATH` (`.bashrc`):

```
export PATH="${HOME}/.local/share/ansibled/bin:$PATH"
```

## Usage

The tool provides wrapper commands for common Ansible utilities:

```bash
ansible           # Runs ansible command
ansible-playbook  # Runs ansible-playbook
ansible-galaxy    # Runs ansible-galaxy
ansible-vault     # Runs ansible-vault
ansible-lint      # Runs ansible-lint
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

Available configuration options:

- `ANSIBLED_VERSION`: container image tag e.g `2.11-alpine-3.15` (default: `alpine`)
- `ANSIBLED_IMAGE`: container image name (default: [willhallonline/ansible](https://hub.docker.com/r/willhallonline/ansible))
- `ANSIBLED_RUNTIME`: container runtime (default: `podman` if available, else `docker`)
- `ANSIBLED_SSH_PRIVATE_KEY`: SSH private key (default: `~/.ssh/id_rsa`)
- `ANSIBLED_DEBUG`: enable debug output (0 or 1)
- `ANSIBLE_*`: any Ansible [configuration option](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#common-options)

Example:

```env
# Ansibled configuration
ANSIBLED_VERSION=2.9-alpine-3.17
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

## License

Copyright (c) Voronkovich Oleg. Distributed under the MIT.
