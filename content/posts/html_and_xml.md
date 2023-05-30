---
title: HTML and XML
date: "2022-10-27T11:08:41-05:00"
draft: false
---

I'm confident that many new and self-taught programmers have *at least once*
entered into a Google or StackOverflow search something along the lines of
'minidom parse html' or 'parse html to xml'.
Web scrapers are an excellent self-teaching project.
And angle-bracketed markup languages look the same.
So what would be *unusual* about using Python's highly-popular minidom parser
to scrape a web page?

Searching those phrases will land you on a page enumerating all the reasons of
*why* it's not just unusual, but *bad*.
A sample:

 1. Real world HTML documents are poorly formed, with unclosed elements.
 2. The HTML spec includes a variety of self-closing elements, like `<br>`.
    HTML5 has only made this more pervasive.
 3. Element attributes aren't always specified with quotes around the value

And these are all perfectly valid points (if you aren't using a SAX parser).
I don't want to take away from the sound advice that HTML documents should be
fed into an HTML parser.

But let's consider the alternative: *doing it anyway.*

----

There are some bumps on this inadvisable road.

While many HTML documents could technically validate as XHTML, there is almost
always going to be one sticking point: the first line[^1].
There are options.
I've always taken the brute force approach of *scan past the first line before
parsing.*
Inelegant? Yes. But it works.

And as mentioned above, some HTML elements are self-closing.
While an XML parser *should* be able to handle `<br />`, it will be confused by
`<br>`.
But there's two important counter-points.

 1. *Will it though?*
    A SAX parser can just skip over the token.
 2. *Does it matter?*
    Visual cues like line breaks are uninteresting outside of rendering a
    complete web page.

In summary, parsing a complete DOM from an HTML document using an XML parser is
not possible.
But rarely do you need the *complete* DOM.
Figure out what data is actually necessary and ignore the rest.

----

On the other side of things, why might one *want* to use an XML parser on
HTML documents?

For one, I have yet to see an HTML parser expose a SAX-like API.

In many circumstances, you *already* need an XML parser.
Configuring and testing an HTML parser on top of that can only add challenges.
Even if the runtime overhead is negligible, the source code is made more
complex with another API.
Code gets duplicated between the two.
Function and class names get bikeshedded, and usually elongated with a prefix,
just to indicate which format they work with.
Code churn for the sake of code churn is not a great idea.

----

At the end of the day, most of the HTML scraping I do is supervised ingestion.
My advise for designing an automated pipeline would be vastly different.
But for my personal projects, a hack job is just as good.


[^1]: Compare the XML declaration, document type declaration, and root
      element for XHTML:

      ```xml
      <?xml version="1.0" encoding="UTF-8" ?>
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
      <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
      ```

      To the document type declaration, root element, and charset declaration for
      HTML4:

      ```html
      <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
      <html lang="en">
      <head><meta charset="utf-8">
      ```

      To that for HTML5:

      ```html
      <!DOCTYPE html>
      <html lang="en">
      <head><meta charset="utf-8">
      ```

      While all of this is fine and dandy for specifying the behavior of web browsers
      must have comparable visual renderings of web pages across the specification...
      *absolutely none of this is useful for a script.*


