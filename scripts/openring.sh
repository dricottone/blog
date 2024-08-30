#!/bin/sh

openring \
  -s https://drewdevault.com/blog/index.xml \
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
  -s https://tradediversion.net/feed/ \
  -s https://vincent.bernat.ch/en/blog/atom.xml \
  -s https://blog.cr.yp.to/feed.application=xml \
  -s https://statmodeling.stat.columbia.edu/feed/ \
  -s https://adarshbadri.me/feed/ \
  -s https://imperfectnotes.substack.com/feed/ \
  -s https://danieldrezner.substack.com/feed/ \
  -s https://fuzzynotes.adarshbadri.me/feed/ \
  -s https://justthesocialfacts.blogspot.com/feeds/posts/default?alt=rss \
  < scripts/openring.html

