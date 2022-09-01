TARGET_USER=admin
TARGET_HOST=admin-aws3

.PHONY: clean dev build sync

clean:
	rm -rf public resources themes
	rm -rf scripts/cv.aux scripts/cv.log scripts/cv.out scripts/cv.tex

static/files/dominic-ricottone.pdf: content/cv.md
	sed content/cv.md \
		-e 's/南山大学/\\begin{CJK}{UTF8}{min}&\\end{CJK}/' \
		| scripts/cv_tex.awk > scripts/cv.tex
	cd scripts && pdflatex cv.tex
	mv scripts/cv.pdf static/files/dominic-ricottone.pdf

static/files/dominic-ricottone.html: content/cv.md
	cat content/cv.md \
		| scripts/cv_html.awk > static/files/dominic-ricottone.html

dev: static/files/dominic-ricottone.pdf static/files/dominic-ricottone.html
	hugo server --buildDrafts --bind 127.0.0.1 --port 8080

build: clean static/files/dominic-ricottone.pdf static/files/dominic-ricottone.html
	hugo

sync: build
	rsync --recursive --links --compress --delete \
		--chown=$(TARGET_USER):$(TARGET_USER) \
		public/ $(TARGET_HOST):/var/deploy/build/blog/public/

