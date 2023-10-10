#!/usr/bin/gawk -f

function end_introduction() {
  print "\\end{minipage}";
  in_introduction=0;
}

function end_subsubsection() {
  print "\\end{minipage}";
  in_subsubsection=0;
}

function end_paragraph() {
  in_paragraph=0;
}

function end_description() {
  #print "\\vspace{.1in}\\hfill\\begin{minipage}{\\dimexpr\\textwidth-.25in}";
  in_description=0;
}

function invalid_end_description() {
  print "%WARNING: this description was not properly terminated";
  print "}";
  #print "\\vspace{.1in}\\hfill\\begin{minipage}{\\dimexpr\\textwidth-.25in}";
  in_description=0;
}

function end_bullets() {
  print "\\end{itemize}";
  in_bullets=0;
}

function end_subbullets() {
  print "\t\\end{itemize}";
  in_subbullets=0;
}

BEGIN {
  ignore=1;
  in_introduction=0;
  in_subsection=0;
  in_subsubsection=0;
  in_paragraph=0;
  in_bullets=0;
  in_subbullets=0;

  print "\\documentclass[12pt]{article}";
  print "\\usepackage[letterpaper, total={7.5in,10in}, centering]{geometry}";
  print "\\usepackage[compact]{titlesec} % compact headers";
  print "\\pagenumbering{gobble} % suppresses pagination";
  print "\\setlength{\\parindent}{0pt} % suppressed paragraph indent";
  print "\\usepackage{enumitem} % exports macros for below";
  print "\\setitemize{topsep=0pt,parsep=0pt,partopsep=0pt} % compact itemize";
  print "\\usepackage{CJKutf8}";
  print "\\usepackage{hyperref} % embedded hyperlinks";
  print "\\urlstyle{same}";
  print "\\begin{document}";
  print "\\section*{Dominic Ricottone}";
  print "\\vspace{.05in}";
}
{
  if (ignore==0) {

    gsub("&","\\\\&");
    $0 = gensub(/\[([^\]]+)\]\(([^\)]+)\)/, "\\\\href{\\2}{\\1}", "g");

    # start of a subsection
    if ($0 ~ /^## /) {
      if (in_subbullets==1) end_subbullets();
      if (in_bullets==1) end_bullets();
      if (in_description==1) invalid_end_description();
      if (in_paragraph==1) end_paragraph();
      if (in_subsubsection==1) end_subsubsection();

      print "\\subsection*{" substr($0,4) "}";
      in_subsection=1;
    }

    # start of a subsubsection
    else if ($0 ~ /^### /) {
      if (in_subbullets==1) end_subbullets();
      if (in_bullets==1) end_bullets();
      if (in_description==1) invalid_end_description();
      if (in_paragraph==1) end_paragraph();

      # only for 2nd+ subsubsection
      if (in_subsubsection==1) {
        end_subsubsection();
        print "\\vspace{.05in}";
      }

      print "\\subsubsection*{" substr($0,5) "}";
      in_subsubsection=1;
    }

    # start of a paragraph
    else if ($0 ~ /^ \+ #### /) {
      if (in_subbullets==1) end_subbullets();
      if (in_bullets==1) end_bullets();
      if (in_description==1) invalid_end_description();
      if (in_paragraph==1) end_paragraph();
      else print "\\vspace{.1in}\\hfill\\begin{minipage}{\\dimexpr\\textwidth-.25in}";

      print "\\paragraph*{" substr($0,9) "}";
      in_paragraph=1;
    }

    # start of a description
    else if ($0 ~ /^\*/) {
      # if description is a one-liner
      if ($0 ~ /\*$/) {
        gsub(/\*/,"");
        print "\\textit{" $0 "}";
        end_description();
      }
      else {
        sub(/\*/,"");
        print "\\textit{" $0;
        in_description=1;
      }
    }

    # end of a multi-line description
    else if (in_description==1 && $0 ~ /\*$/) {
      sub(/\*/,"");
      print $0 "}";
      end_description();
    }

    # date range (always a one-liner)
    else if ($0 ~ /^ +\*.+\*/) {
      gsub(/ *\*/,"");
      sub(/to/,"---");
      print "\\textit{" $0 "}";
      print "\\vspace{.05in}";
    }

    # bullets (may be start of or a member of)
    else if ($0 ~ /^   \+ /) {
      if (in_subbullets==1) end_subbullets();

      if (in_bullets==0) print "\\begin{itemize}";
      sub(/ +\+ /,"");
      print "\t\\item " $0;
      in_bullets=1;
    }

    # subbullets (may be start of or a member of)
    else if ($0 ~ /^     \+ /) {
      if (in_subbullets==0) print "\t\\begin{itemize}";
      sub(/ +\+ /,"");
      print "\t\t\\item " $0;
      in_subbullets=1;
    }

    # blank line (can be an end of certain sections)
    else if ($0 ~ /^$/) {
      if (in_introduction==1) end_introduction();
      if (in_description==1) invalid_end_description();
      if (in_bullets==1) end_bullets();
      if (in_subbullets==1) end_subbullets();

      print $0;
    }

    else if ($0 !~ /^-----+$/) {
      if (in_subsection==0 && in_introduction==0) {
        print "\\hfill\\begin{minipage}{\\dimexpr\\textwidth-.25in}";
        in_introduction=1;
      }

      print $0;
    }
  }
  else if ($0 ~ /Ignore above content for PDF and HTML versions/) ignore=0;
}

END {
  if (in_description==1) invalid_end_description();
  if (in_bullets==1) end_bullets();
  if (in_subsubsection==1) end_subsubsection();
  print "\\end{document}";
}
