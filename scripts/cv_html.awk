#!/usr/bin/gawk -f

function end_section() {
  print "</ul>";
  in_section=0;
}

function end_subsection() {
  print "</li>";
  in_subsection=0;
}

function end_paragraph() {
  print "</p>";
  in_paragraph=0;
}

function end_bullets() {
  print "</ul>";
  in_bullets=0;
}

function end_subbullets() {
  print "</ul>";
  in_subbullets=0;
}

BEGIN {
  ignore=1;
  in_section=0;
  in_subsection=0;
  in_bullets=0;
  in_subbullets=0;
  in_paragraph=0;

  print "<!doctype html>";
  print "<html lang=\"en\">";
  print "<head>";
  print "<meta charset=\"utf-8\" name=\"viewport\" content=\"width=device-width, initial-scale=1\">";
  print "<title>CV | Dominic Ricottone</title>";
  print "</head>";
  print "<body>";
  print "<main>";
  print "<h1>Dominic Ricottone</h1>";
}

{
  if (ignore==0) {

    gsub("&","\\&amp;");
    gsub("'","\\&rsquo;");
    $0 = gensub(/\[([^\]]+)\]\(([^\)]+)\)/, "<a href=\"\\2\">\\1</a>", "g");

    if ($0 ~ /^## /) {
      if (in_paragraph==1) end_paragraph();
      if (in_subbullets==1) end_subbullets();
      if (in_bullets==1) end_bullets();
      if (in_subsection==1) end_subsection();
      if (in_section==1) end_section();

      print "<h2>" substr($0,4) "</h2>";
    }

    # start of a section (which is a pair of a paragraph and an unordered list)
    else if ($0 ~ /^### /) {
      if (in_paragraph==1) end_paragraph();
      if (in_subbullets==1) end_subbullets();
      if (in_bullets==1) end_bullets();
      if (in_subsection==1) end_subsection();
      if (in_section==1) end_section();

      print "<h3>" substr($0,5) "</h3>";
      in_section=1;
    }

    # start of a subsection (which is a list item)
    else if ($0 ~ /^ \+ #### /) {
      if (in_paragraph==1) end_paragraph();
      if (in_subbullets==1) end_subbullets();
      if (in_bullets==1) end_bullets();
      if (in_subsection==1) end_subsection();
      else print "<ul>";

      print "<li>";
      print "<h4>" substr($0,9) "</h4>";
      in_subsection=1;
    }

    # bullets (may be start of or a member of)
    else if ($0 ~ /^   \+ /) {
      if (in_paragraph==1) end_paragraph();
      if (in_subbullets==1) end_subbullets();

      if (in_bullets==0) print "<ul>";
      sub(/ +\+ /,"");
      print "<li>" $0 "</li>";
      in_bullets=1;
    }

    # subbullets (may be start of or a member of)
    else if ($0 ~ /^     \+ /) {
      if (in_paragraph==1) end_paragraph();

      if (in_subbullets==0) print "<ul>";
      sub(/ +\+ /,"");
      print "<li>" $0 "</li>";
      in_subbullets=1;
    }

    # blank line (end of paragraphs)
    else if ($0 ~ /^$/) {
      if (in_paragraph==1) end_paragraph();
      if (in_subbullets==1) end_subbullets();
      if (in_bullets==1) end_bullets();
    }

    # horizontal rules (also end of paragraphs)
    else if ($0 ~ /^-----+$/) {
      if (in_paragraph==1) end_paragraph();
      if (in_subbullets==1) end_subbullets();
      if (in_bullets==1) end_bullets();
      if (in_subsection==1) end_subsection();
      if (in_section==1) end_section();

      print "<hr />";
    }

    # paragraphs
    else {
      sub(/^ *\*/,"<em>");
      sub(/\*$/,"</em>");
      if (in_paragraph==0) print "<p>" $0;
      else print $0;
      in_paragraph=1;
    }
  }
  else if ($0 ~ /Ignore above content for PDF and HTML versions/) ignore=0;
}

END {
  if (in_paragraph==1) end_paragraph();
  if (in_subbullets==1) end_subbullets();
  if (in_bullets==1) end_bullets();
  if (in_subsection==1) end_subsection();
  if (in_section==1) end_section();

  print "</main>";
  print "</html>";
}

