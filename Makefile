# Makefile
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

CUR_DIR	= $(shell pwd)
DOCKERFILE = "${CUR_DIR}/Dockerfile"
IMAGE_NAME ?= "demo/spring-boot-helloworld-for-k8s"

# check program
EXECUTABLES = git docker
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
HASH := $(shell git rev-parse --short HEAD)
GIT_TAG := $(shell git describe --tags --exact-match $(git rev-parse HEAD) 2>/dev/null)

ifdef DOCKER_REPOSITORY
	NAMESPACE := "${DOCKER_REPOSITORY}/"
endif

ifeq ($(GIT_TAG),)
	VERSION	?= ${BRANCH}
else
	VERSION	?= ${GIT_TAG}
endif

# TASKS
.PHONY: all
all: image image-debug

.PHONY: build
build:
	@${CUR_DIR}/gradlew --console=plain -x test bootJar

.PHONY: image
image: build
	@echo "+ $@"
	@docker buildx build --progress=plain --compress --build-arg DIST_TAG=11 -t ${NAMESPACE}${IMAGE_NAME}:$(HASH) -f ${DOCKERFILE} \
		$(ENV_FILE_PARAM) ${CUR_DIR}
	@docker tag ${NAMESPACE}${IMAGE_NAME}:$(HASH) ${NAMESPACE}${IMAGE_NAME}:${VERSION}
	@echo 'Done.'
	@docker images --format '{{.Repository}}:{{.Tag}}\t\t Built: {{.CreatedSince}}\t\tSize: {{.Size}}' | \
	      grep ${NAMESPACE}${IMAGE_NAME}:$(HASH)

.PHONY: image-debug
image-debug: build
	@echo "+ $@"
	@docker buildx build --progress=plain --compress --build-arg DIST_TAG=11-debug \
		-t ${NAMESPACE}${IMAGE_NAME}:$(HASH)-debug -f ${DOCKERFILE} $(ENV_FILE_PARAM)  ${CUR_DIR}
	@docker tag ${NAMESPACE}${IMAGE_NAME}:$(HASH)-debug ${NAMESPACE}${IMAGE_NAME}:${VERSION}-debug
	@echo 'Done.'
	@docker images --format '{{.Repository}}:{{.Tag}}\t\t Built: {{.CreatedSince}}\t\tSize: {{.Size}}' | \
	      grep ${NAMESPACE}${IMAGE_NAME}:$(HASH)-debug

.PHONY: clean-image
clean-image:
	@echo "+ $@"
	@docker rmi ${NAMESPACE}${IMAGE_NAME}:$(HASH)  || true
	@docker rmi ${NAMESPACE}${IMAGE_NAME}:${VERSION}  || true
	@docker rmi ${NAMESPACE}${IMAGE_NAME}:$(HASH)-debug  || true
	@docker rmi ${NAMESPACE}${IMAGE_NAME}:${VERSION}-debug  || true

.PHONY: push
push: all
	@echo "+ $@"
	@docker push ${NAMESPACE}${IMAGE_NAME}:$(HASH)
	@docker push ${NAMESPACE}${IMAGE_NAME}:${VERSION}
	@docker push ${NAMESPACE}${IMAGE_NAME}:$(HASH)-debug
	@docker push ${NAMESPACE}${IMAGE_NAME}:${VERSION}-debug

.PHONY: clean-image
clean: clean-image
	@${CUR_DIR}/gradlew --console=plain clean