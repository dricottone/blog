clean:
	rm -rf public resources themes
	rm -rf scripts/cv.aux scripts/cv.log scripts/cv.out
	rm -rf content/posts/*.bak
	rm -rf layouts/partials/bsky.html
	rm -rf layouts/partials/lastfm.html
	rm -rf layouts/partials/openring.html

scripts/cv.tex: content/cv.md
	sed content/cv.md \
		-e 's/南山大学/\\begin{CJK}{UTF8}{min}&\\end{CJK}/' \
		| scripts/cv_tex.awk > scripts/cv.tex

static/files/dominic-ricottone.pdf: scripts/cv.tex
	mkdir -p static/files
	cd scripts && pdflatex cv.tex
	mv scripts/cv.pdf static/files/dominic-ricottone.pdf
	rm -rf scripts/cv.aux scripts/cv.log scripts/cv.out

static/files/dominic-ricottone.html: content/cv.md
	mkdir -p static/files
	cat content/cv.md \
		| scripts/cv_html.awk > static/files/dominic-ricottone.html

layouts/partials/bsky.html:
	scripts/bsky.bash > layouts/partials/bsky.html

layouts/partials/lastfm.html:
	scripts/lastfm.sh > layouts/partials/lastfm.html

layouts/partials/openring.html:
	scripts/openring.sh > layouts/partials/openring.html

PREGEN_HTML=static/files/dominic-ricottone.pdf static/files/dominic-ricottone.html layouts/partials/bsky.html layouts/partials/lastfm.html layouts/partials/openring.html

build: $(PREGEN_HTML) clean
	hugo

check:
	for f in content/posts/*.md; do aspell --check $$f; done

dev: $(PREGEN_HTML)
	hugo --buildDrafts --baseURL https://dev.intra.dominic-ricottone.com
	rsync --recursive --links --compress --delete public/ alarm@arch3.intra.dominic-ricottone.com:/var/deploy/web/

publish: build
	rsync --recursive --links --compress --delete --chown=admin:admin public/ admin-aws3:/var/deploy/build/blog/public/

.PHONY: clean build check dev publish
