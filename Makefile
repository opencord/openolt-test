#Copyright 2018-present Open Networking Foundation
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

########################################################################

# set default shell options
SHELL = bash -e -o pipefail

## Variables
VERSION           ?= $(shell cat ./VERSION)
GTEST_VER         ?= release-1.8.0
CMOCK_VER         ?= 0207b30
GMOCK_GLOBAL_VER  ?= 1.0.2
GRPC_VER          ?= v1.27.1

# Docker related
DOCKER_LABEL_VCS_DIRTY     = false
ifneq ($(shell git status --porcelain | grep 'docker/Dockerfile.openolt-test' | wc -l | sed -e 's/ //g'),0)
    DOCKER_LABEL_VCS_DIRTY = true
    VERSION                = latest
endif

DOCKER                    ?= docker
DOCKER_REGISTRY           ?=
DOCKER_REPOSITORY         ?=
DOCKER_EXTRA_ARGS         ?=
DOCKER_TAG                ?= ${VERSION}

OPENOLT_TEST_IMAGENAME    := ${DOCKER_REGISTRY}${DOCKER_REPOSITORY}openolt-test:${DOCKER_TAG}

VOLTHA_CI_TOOLS_IMAGENAME := voltha/voltha-ci-tools:1.0.3-hadolint

DOCKER_BUILD_ARGS ?= \
	${DOCKER_EXTRA_ARGS} \
	--build-arg GTEST_VER=${GTEST_VER} \
	--build-arg CMOCK_VER=${CMOCK_VER} \
	--build-arg GMOCK_GLOBAL_VER=${GMOCK_GLOBAL_VER} \
	--build-arg GRPC_VER=${GRPC_VER}

.DEFAULT_GOAL := build

# Builds the docker container with pre-requisite system and test libraries for
# running openolt agent unit test cases.
build: docker-build

docker-build: openolt-test

openolt-test:
	${DOCKER} build ${DOCKER_BUILD_ARGS} \
	-t ${OPENOLT_TEST_IMAGENAME} \
	-f docker/Dockerfile.openolt-test .

docker-push:
ifneq (false,$(DOCKER_LABEL_VCS_DIRTY))
	@echo "Local repo is dirty.  Refusing to push."
	@exit 1
endif
	${DOCKER} push ${OPENOLT_TEST_IMAGENAME}

## runnable tool containers
HADOLINT = ${DOCKER} run --rm --user $$(id -u):$$(id -g) -v $$PWD:/app ${VOLTHA_CI_TOOLS_IMAGENAME} hadolint --ignore DL3003 --ignore DL3015

lint: docker-lint

docker-lint:
	@echo "Linting Dockerfiles..."
	@${HADOLINT} $(shell ls docker/Dockerfile.*)
	@echo "Dockerfiles linted OK"
