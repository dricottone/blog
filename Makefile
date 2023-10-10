TARGET_USER=admin
TARGET_HOST=admin-aws3
RSYNC_OPTS=--recursive --links --compress --delete --chown=$(TARGET_USER):$(TARGET_USER)

.PHONY: clean
clean:
	rm -rf public resources themes
	rm -rf scripts/cv.aux scripts/cv.log scripts/cv.out scripts/cv.tex
	rm -rf content/posts/*.bak

scripts/cv.tex:
	sed content/cv.md \
		-e 's/南山大学/\\begin{CJK}{UTF8}{min}&\\end{CJK}/' \
		| scripts/cv_tex.awk > scripts/cv.tex

static/files:
	mkdir -p static/files

static/files/dominic-ricottone.pdf: static/files content/cv.md scripts/cv.tex
	cd scripts && pdflatex cv.tex
	pwd
	mv scripts/cv.pdf static/files/dominic-ricottone.pdf
	rm -rf scripts/cv.aux scripts/cv.log scripts/cv.out scripts/cv.tex

static/files/dominic-ricottone.html: static/files content/cv.md
	cat content/cv.md \
		| scripts/cv_html.awk > static/files/dominic-ricottone.html

layouts/partials/bsky.html:
	scripts/bsky.bash > layouts/partials/bsky.html

layouts/partials/lastfm.html:
	scripts/lastfm.sh > layouts/partials/lastfm.html

layouts/partials/openring.html:
	scripts/openring.sh > layouts/partials/openring.html

PREGEN_HTML=static/files/dominic-ricottone.pdf static/files/dominic-ricottone.html layouts/partials/bsky.html layouts/partials/lastfm.html layouts/partials/openring.html
.PHONY: $(PREGEN_HTML)

.PHONY: dev
dev: $(PREGEN_HTML)
	hugo server --buildDrafts --bind 127.0.0.1 --port 8080

.PHONY: build
build: clean $(PREGEN_HTML)
	hugo

.PHONY: check
check:
	for f in content/posts/*.md; do aspell --check $$f; done

.PHONY: sync
sync: build
	rsync $(RSYNC_OPTS) public/ $(TARGET_HOST):/var/deploy/build/blog/public/

