# Makefile
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Hide or not the calls depending of VERBOSE
ifneq ($(VERBOSE),TRUE)
    HIDE = @
else
    HIDE =
endif

CUR_DIR	= $(shell pwd)
DOCKERFILE = "${CUR_DIR}/Dockerfile"
IMAGE_NAME ?= "demo/spring-boot-helloworld-for-k8s"

# check program
EXECUTABLES = git docker
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

# Get Current Branch and TAG
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GIT_HASH := $(shell git rev-parse --short HEAD)
GIT_TAG := $(shell git describe --tags --exact-match $(git rev-parse HEAD) 2>/dev/null)

ifdef DOCKER_REPOSITORY
	NAMESPACE := "${DOCKER_REPOSITORY}/"
endif

ifeq ($(GIT_TAG),)
	VERSION	?= ${GIT_BRANCH}
else
	VERSION	?= ${GIT_TAG}
endif

IMAGE_HASH_SUFIX = $(if $(findstring debug,$*),-debug)
IMAGE_HASH_TAG 		= "${NAMESPACE}${IMAGE_NAME}:${GIT_HASH}$(IMAGE_HASH_SUFIX)"
IMAGE_VERSION_TAG = "${NAMESPACE}${IMAGE_NAME}:${VERSION}$(IMAGE_HASH_SUFIX)"

#DOCKER_BUILD_CMD := "docker buildx build --progress=plain --compress"
DOCKER_BUILD_CMD := docker image build


# TASKS
.PHONY: all
all: image-11 image-11-debug

.PHONY: build
build:
	$(HIDE)${CUR_DIR}/gradlew --console=plain -x test bootJar

image-%: build
	@echo "+ $@"
	$(HIDE)${DOCKER_BUILD_CMD} --build-arg DIST_TAG=$* \
		-t $(IMAGE_HASH_TAG) \
		-t $(IMAGE_VERSION_TAG) \
		-f ${DOCKERFILE} $(ENV_FILE_PARAM) ${CUR_DIR}
	@echo "Done. $@"
	$(HIDE)docker images --format '{{.Repository}}:{{.Tag}}\t\t Built: {{.CreatedSince}}\t\tSize: {{.Size}}' | \
	      grep $(IMAGE_HASH_TAG)

clean-image-%:
	@echo "+ $@"
	$(HIDE)docker rmi $(IMAGE_HASH_TAG) || true
	$(HIDE)docker rmi $(IMAGE_VERSION_TAG)  || true

push-%: image-%
	$(HIDE)docker push $(IMAGE_HASH_TAG)
	$(HIDE)docker push $(IMAGE_VERSION_TAG)

.PHONY: push
push: push-11 push-11-debug
	@echo "+ $@"

.PHONY: clean
clean: clean-image-11 clean-image-11-debug
	$(HIDE)${CUR_DIR}/gradlew --console=plain clean
