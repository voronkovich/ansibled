# Ansibled

Ansibled is a wrapper tool for [Ansible](https://ansible.com) that ensures a consistent environment by running Ansible commands inside containers.

## Key Features

- **Containerized Execution:** Runs Ansible commands within a containerized environment using [Docker](https://docker.com), [Podman](https://podman.io), or [nerdctl](https://github.com/containerd/nerdctl).
- **Support for Multiple Ansible Versions:** Easily switch between different Ansible versions using container images.
- **Flexible Configuration:** Loads configuration from multiple sources including user and project-level files, and environment variables.
- **Automatic SSH Key Mounting:** Automatically mounts your SSH private key for seamless Ansible operations.
- **Debug Mode:**  Provides detailed output for easy troubleshooting.

## Prerequisites

- Unix-like operating system (Linux, MacOS, etc.)
- A compatible container runtime (Docker, Podman, or nerdctl) must be installed and running on your system.
- Bash shell

## Installation

1. Clone the Ansibled repository to your desired location. It's recommended to install it in `~/.local/share/ansibled`:

   ```sh
   git clone https://github.com/voronkovich/ansibled ~/.local/share/ansibled
   ```

2. Add the `bin` directory to your shell's `PATH` environment variable.  For Bash, you can add the following line to your `.bashrc` or equivalent shell configuration file:

   ```sh
   export PATH="${HOME}/.local/share/ansibled/bin:${PATH}"
   ```

   After modifying your shell configuration, remember to reload it (e.g., `source ~/.bashrc`).

## Usage

Ansibled provides wrapper commands for common Ansible utilities. These wrappers function identically to the standard Ansible commands but execute within the containerized environment.

Available commands:

```bash
ansible           # Runs ansible command
ansible-config    # Runs ansible-config
ansible-galaxy    # Runs ansible-galaxy
ansible-lint      # Runs ansible-lint
ansible-playbook  # Runs ansible-playbook
ansible-vault     # Runs ansible-vault
```

**Example:**

To run the `ping` module against all hosts defined in your inventory:

```sh
ansible all -m ping
```

When you execute an Ansibled command, the following steps occur:

1. A container is started using the configured Ansible image and version.
2. Your current working directory is mounted inside the container at `/ansible`.
3. Your configured SSH private key is mounted into the container, if specified.
4. The Ansible command you invoked is executed within the container.

## Configuration

Ansibled loads its configuration from several sources, in the following order of precedence (later sources override earlier ones):

1. **User Configuration:**  `~/.config/ansibled` or `~/.ansibled`.
2. **Project Local Configuration:** `.ansibled` and `.ansibled.local` files in your project's root directory.
3. **Environment Variables:**  Environment variables prefixed with `ANSIBLED_` or `ANSIBLE_`.

Configuration files are simple `.env` files, using the `KEY=VALUE` format.

The `.ansibled.local` file is intended for local overrides of the `.ansibled` configuration and should typically be excluded from version control.

### Configuration Options

The following options can be configured via the methods described above:

#### `ANSIBLED_VERSION`

Specifies the tag of the container image to use.  This typically corresponds to the Ansible version.

*Example:* `2.11-alpine-3.15`

*Default:* `alpine` (latest stable version available in the image)

#### `ANSIBLED_IMAGE`

The name of the container image to use.

*Default:* `willhallonline/ansible` ([Docker Hub](https://hub.docker.com/r/willhallonline/ansible))

#### `ANSIBLED_RUNTIME`

Selects the container runtime to use. Supported runtimes are `docker`, `podman`, and `nerdctl`.

*Default:* Automatically detects and uses `docker` if available, otherwise falls back to `podman` or `nerdctl`.

#### `ANSIBLED_WORKDIR`

Sets the working directory inside the container. Your current working directory will be mounted to this path.

*Default:* `/ansible`

#### `ANSIBLED_SSH_PRIVATE_KEY`

Path to your SSH private key file. This key will be mounted into the container to enable SSH connections to your managed hosts.

*Default:* `~/.ssh/id_rsa`

#### `ANSIBLED_SSH_KNOWN_HOSTS`

Path to your SSH known_hosts file. This file will be mounted into the container.

*Default:* `~/.ssh/known_hosts`

#### `ANSIBLED_SSH_AUTH_SOCK`

Path to the SSH authentication socket. This socket will be mounted into the container to enable SSH agent forwarding, allowing you to use SSH keys managed by your SSH agent.

*Default:* Automatically detects the SSH agent socket path for Linux (`$SSH_AUTH_SOCK`) and MacOS (`/run/host-services/ssh-auth.sock`).

#### `ANSIBLED_OPTS`

Allows you to pass extra options directly to the container runtime command.  This is useful for customizing container behavior, such as resource limits.

*Example:* `--memory=256m --cpus=0.5`

#### `ANSIBLED_DEBUG`

Enables debug output when set to `1`.  Set to `0` to disable. Debug output provides detailed information about the configuration and executed commands.

*Default:* `0` (disabled)

#### `ANSIBLE_*`

Any standard Ansible configuration option can be set using environment variables prefixed with `ANSIBLE_`.  See the [Ansible Configuration documentation](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#common-options) for available options.

### Example Configuration (`.ansibled` file)

```env
# Ansibled configuration
ANSIBLED_RUNTIME=podman
ANSIBLED_IMAGE=docker://alpine/ansible
ANSIBLED_VERSION=2.18.1
ANSIBLED_SSH_PRIVATE_KEY=/home/user/.ssh/secret_key

# Ansible configuration
ANSIBLE_HOST_KEY_CHECKING=False
ANSIBLE_NOCOWS=True # Disable cowsay output for cleaner output
```

## Debugging

To enable debug output, set the `ANSIBLED_DEBUG` environment variable to `1` when running any Ansibled command:

```sh
ANSIBLED_DEBUG=1 ansible all -m ping
```

This will print detailed debugging information, including the complete configuration and the exact container command being executed.

## Testing

Ansibled uses [ShellSpec](https://shellspec.info) for automated testing. To run the test suite, simply execute:

```sh
shellspec
```

## License

Copyright (c) Voronkovich Oleg. Distributed under the MIT License.
