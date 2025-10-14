# AGENTS.md

Ansibled is a shell script wrapper for Ansible that runs Ansible commands inside containers.

## Commands

The primary entry points for the tool are the wrapper scripts in the `bin` directory. These scripts correspond to the standard Ansible commands (e.g., `ansible`, `ansible-playbook`, etc.). All `ansible-*` executables in the `bin` directory are wrappers that call the main `ansibled` script.

To use the `ansibled` wrappers, you can call them as you would the standard Ansible commands. The scripts will pass all arguments to the corresponding Ansible command running inside a container.

For example, to run an ansible playbook, you can use:

```sh
./bin/ansible-playbook my-playbook.yml
```

## Testing

The project uses [ShellSpec](https://shellspec.info) for testing. To run the test suite, execute the following command in the root of the project:

```sh
shellspec
```

The tests are located in the `spec` directory. The main test file is `spec/ansibled_spec.sh`.
