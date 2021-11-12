TARGET_USER=deploy
TARGET_HOST=deploy-aws2

.PHONY: dev
dev:
	hugo server --buildDrafts --bind 127.0.0.1 --port 8080

.PHONY: build
build: clean
	hugo

.PHONY: sync
sync: build
	rsync --recursive --links --compress --delete \
		--chown=$(TARGET_USER):$(TARGET_USER) \
		public/ $(TARGET_HOST):/var/deploy/webroot/

.PHONY: clean
clean:
	rm -rf public resources themes

