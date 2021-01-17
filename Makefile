TARGET_IP=alpine1.local
TARGET_USER=deploy
TARGET_DIR=/var/public-blog
TARGET_HOST=$(TARGET_USER)@$(TARGET_IP)
DOCKER_URL=ssh://$(TARGET_HOST)

.PHONY: dev
dev:
	hugo server -buildDrafts

.PHONY: build
build: clean
	hugo

.PHONY: sync
sync: build
	rsync --recursive --links --compress --delete \
		--chown=$(TARGET_USER):$(TARGET_USER) \
		public/ $(TARGET_HOST):$(TARGET_DIR)/html/

.PHONY: clean
clean:
	rm -rf public resources themes

