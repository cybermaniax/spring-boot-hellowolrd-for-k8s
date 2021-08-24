CUR_DIR	= $(shell pwd)
DOCKERFILE = "${CUR_DIR}/Dockerfile"
IMAGE_NAME = "demo/spring-boot-helloworld-for-k8s"

BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
HASH := $(shell git rev-parse --short HEAD)
GIT_TAG := $(shell git describe --tags $(git rev-parse HEAD) 2>/dev/null)

ifeq ($(GIT_TAG),)
	VERSION	?= ${BRANCH}
else
	VERSION	?= ${GIT_TAG}
endif

all: image image-debug

build:
	@${CUR_DIR}/gradlew --console=plain -x test bootJar

image: build
	@echo "+ $@"
	@docker build --compress --build-arg DIST_TAG=11 -t ${IMAGE_NAME}:$(HASH) -f ${DOCKERFILE} ${CUR_DIR}
	@docker tag ${IMAGE_NAME}:$(HASH) ${IMAGE_NAME}:${VERSION}
	@echo 'Done.'
	@docker images --format '{{.Repository}}:{{.Tag}}\t\t Built: {{.CreatedSince}}\t\tSize: {{.Size}}' | \
	      grep ${IMAGE_NAME}:$(HASH)
image-debug: build
	@echo "+ $@"
	@docker build --compress --build-arg DIST_TAG=11-debug -t ${IMAGE_NAME}:$(HASH)-debug -f ${DOCKERFILE} ${CUR_DIR}
	@docker tag ${IMAGE_NAME}:$(HASH)-debug ${IMAGE_NAME}:${VERSION}-debug
	@echo 'Done.'
	@docker images --format '{{.Repository}}:{{.Tag}}\t\t Built: {{.CreatedSince}}\t\tSize: {{.Size}}' | \
	      grep ${IMAGE_NAME}:$(HASH)-debug

clean-image:
	@echo "+ $@"
	@docker rmi ${IMAGE_NAME}:$(HASH)  || true
	@docker rmi ${IMAGE_NAME}:${VERSION}  || true
	@docker rmi ${IMAGE_NAME}:$(HASH)-debug  || true
	@docker rmi ${IMAGE_NAME}:${VERSION}-debug  || true

clean: clean-image
	@${CUR_DIR}/gradlew --console=plain clean