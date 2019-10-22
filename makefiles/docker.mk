IMAGE_TAG       := latest
BASE_IMAGE_NAME := $(or $(BASE_IMAGE_NAME),jonathonf/manjaro)
IMAGE_NAME      := $(BASE_IMAGE_NAME):$(IMAGE_TAG)
CONTAINER_NAME  := pro_shunsuke-provisioning-develop
HOST            := pro_shunsuke-docker-01

DOCKER_CMD      := docker
CMD             := /bin/bash --login
CACHE_DIR       := /tmp/docker-cache

.PHONY: $(shell echo docker/{login,pull,setup,run,graceful-stop,rm,clean,save,load})

docker/pull:
	$(DOCKER_CMD) pull $(IMAGE_NAME)

docker/setup: docker/pull ## 初期設定

docker/run: docker/rm ## (docker) CMD を指定して走らせる
	$(DOCKER_CMD) run -it --privileged --name $(CONTAINER_NAME) \
	-p 127.0.0.1:8080:8080 \
	-v ${PWD}:/root/provisioning \
	-h $(HOST) -w /root/provisioning $(IMAGE_NAME) $(CMD)
	$(MAKE) docker/rm

docker/graceful-stop: ## (docker) コンテナを停止する。通常使わない。
	[ ! `$(DOCKER_CMD) ps -q --filter name=$(CONTAINER_NAME)` ] || $(DOCKER_CMD) stop `$(DOCKER_CMD) ps -q --filter name=$(CONTAINER_NAME)`

docker/rm: ## (docker) コンテナを強制削除する。
	[ ! `$(DOCKER_CMD) ps -q -a --filter name=$(CONTAINER_NAME)` ] || $(DOCKER_CMD) rm --force `$(DOCKER_CMD) ps -q -a --filter name=$(CONTAINER_NAME)`

docker/clean: ## (docker) イメージを削除する(local)
	$(DOCKER_CMD) rmi $(IMAGE_NAME)

docker/save: ## (docker) イメージをローカルに保存 (Circle CI 用)
	mkdir -p $(CACHE_DIR)
	$(DOCKER_CMD) save -o $(CACHE_DIR)/$(CONTAINER_NAME).tar $(IMAGE_NAME)

docker/load: ## (docker) イメージをローカルから復元 (Circle CI 用)
	$(DOCKER_CMD) load -i $(CACHE_DIR)/$(CONTAINER_NAME).tar || true
