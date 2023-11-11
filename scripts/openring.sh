#!/bin/sh

openring \
  -s https://drewdevault.com/feed.xml \
  -s https://emersion.fr/blog/rss.xml \
  -s https://gregoryszorc.com/blog/feed/ \
  -s https://words.filippo.io/rss/ \
  -s https://www.supergoodcode.com/feed.xml \
  -s https://bitfehler.srht.site/index.xml \
  -s https://research.swtch.com/feed.atom \
  -s https://andrewkelley.me/rss.xml \
  -s https://christianbrickhouse.com/feed.xml \
  -s https://andreabergia.com/post/index.xml \
  -s https://ludic.mataroa.blog/rss/ \
  < scripts/openring.html

