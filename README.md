# openolt-test : Docker container with prereqs for running openolt agent unit tests

This repo contains Dockerfile used to generate docker container with prerequisite software for running openolt agent unit tests.

## Versioning

Final docker images are tagged with the image version from the VERSION file.

The VERSION file should be changed using these rules:

* Bump Patch version if:
  * Patch version of a tool has changed.
  * This repo's supporting files have changed (Makefile, readme, etc.)  This rule assumes that the containers generated are backwards-compatible; if they are not, bump the major version instead.
* Bump Minor version if:
  * Minor version of a tool has changed.
  * A new tool has been added.
* Bump Major version if:
  * Major version of a tool has changed.
* Bump patch/minor/major version according to semver rules if a Dockerfile is changed.
* Reset lesser versions if greater versions change.
* Do not use -dev versions.

## Tool Usage

Only use containers tagged with `<VERSION>`.

Once you are the root folder of the openolt agent repo, execute the below command to build and run the unit tests. Replace `VERSION` to use a specific version of the container.

```shell
docker run --rm -v $PWD:/app voltha/openolt-test:<VERSION> make test
```

Details:

* `-v` bind-mounts the local folder into the container.

## Key Commands

* `make build` to build container
* `make docker-push` to push built container to a registry
* `make lint` to lint the Dockerfiles
