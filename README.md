# Template for running ROS Noetic projects in docker container

Clone the repo with submodules:
```bash
git clone --recursive git@github.com:Lucasmogsan/ros1_template.git


```

Alternatively clone the repo and then get the submodules afterwards:

```bash
git clone git@github.com:Lucasmogsan/ros1_template.git
```

```bash
git submodule update --init --recursive
```


The main repo has references to the submodules. If these submodules are modified, then the main repo may need to update these references in order to pull the latest data.
```bash
git submodule update --remote
```

This modifies the references in the main repo, and these changes needs to be comitted and pushed.


# Files
.devcontainer: vscode setup in container
Docker: Dockerfile and entrypoint
.env: Environment variables to be changed. Particularly important for ROS1 (ros master, nodes IP etc.)
dependencies.repos: Repositories that are used, but not to be modified (e.g. drivers, tools etc)
docker-compose: Compose file

# Using this for the first time:
1. Make a repository based on this template.
1. Add submodules needed to packages.
1. Update the `.env` file.
1. Build the image.
1. Start the container.


Workflow:

1. clone git
1. submodules
1. build image
1. start container
1. if devel: submodules coopied and shared volume
1. if overlay: submodules copied into container