TARGET_USER=deploy
TARGET_HOST=$(TARGET_USER)@ubuntu2.intra.dominic-ricottone.com

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
		public/ $(TARGET_HOST):/var/deploy/resources/webroot/

.PHONY: clean
clean:
	rm -rf public resources themes

