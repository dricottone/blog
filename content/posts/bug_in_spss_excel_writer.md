---
title: Bug in SPSS's Excel Writer
date: "2024-01-08T05:39:23+00:00"
draft: false
---

I was unpleasantly surprised to discover a corrupted Excel data file this week.
Luckily I was fully prepared to rebuild it with my pipeline in SPSS, but rather
puzzlingly, rebuilding did *not* cure the problem.
I was returned the exact same corruption error in the new file.

The first, and typically only, investigation for such issues is into the input
data files.
*Surely the corruption came from elsewhere.*
But after a few minutes of poking and prodding, I found nothing wrong there.
(No ASCII control characters, no embedded case delimiters, no unescaped value
delimiters, etc., etc.)

My next step was the excessive insertion of debug commands in my pipeline,
trying to determine where and when the issue first appears.
(Sadly SPSS lacks useful debug commands; LIST and some personal macros are the
best available tools.)
But the frustration continued, as everything seemed perfect up to the very end.

I tried to re-import the corrupted spreadsheet and, strangely, I had no issues
doing so.
Whatever issue Excel identified in the file, SPSS was content to work with.
This prompted me to do some comparisons, to see if any differences existed
before and after the Excel round-trip.
And finally I had a culprit:
my data was magically mutating when written to an Excel file.
Before, a string read like "Phase 2B: \_x0001\_".
After, it was "Phase 2B: □".

Now I export the mutated data into a text file for closer inspection of the
byte literals.
I found the ASCII control character for start of header.
Surely it isn't a coincidence that SOH corresponds to `01`, which I suppose
you can creatively write as `0001`?
But I've never heard of an escape scheme like "\_xHHHH\_".
Googling "\_x0001\_" gave me nothing of value.

I used a simple data list to test all of the first 10 codepoints (`00`-`09`).
These were all exported to an Excel file, read back into SPSS, and written to a
text file.
Interestingly the null byte turned into a space character.
Aside from that, I got exactly what I expected; a series of ASCII control
characters.
So "\_x0001\_" clearly isn't a special case.

The next thing I tested is whether the leading and trailing underscores were
important.
Indeed they are.
Now I am convinced this is a scheme for encoding data.

Finally I try "\_x0030\_", to be sure that this was a hexadecimal encoding.
The decimal `30` codepoint refers to another control character, while the hex
`30` codepoint refers to the zero character.
And yes, when I saw the "0" upon re-importing, this confirmed that I was
dealing with some sort of hexadecimal escape scheme.

----

The issue can perhaps best be demonstrated by trying to reconstruct the issue
within a first-party, fully supported, WYSIWYG editor.
I of course mean Microsoft Excel.

I create a new Excel file containing just "foo \_x0001\_ bar" in the first cell,
save, and exit.
I can immediately re-open the file, so clearly Excel has not written a corrupt
file.
What did Excel do with that value?

It requires some further digging, because modern Excel writes string values to
a separate `sharedStrings.xml` file in an effort to be more efficient.
But because I kept the reconstruction short and simple, it's a quick detour.
Excel took "foo \_x0001\_ bar" and actually wrote "foo \_x005F\_x0001\_ bar".
In case you don't have your handy ASCII codepage available, `5F` represents
the underscore character.

This is the neat parallel for the escaping strategy used on the web,
e.g. `&amp;lt;`.
`&lt;` wants to be read as "<" by any browser.
That behavior is effectively 'deferred' by encoding the leading character
instead,
so that the first pass of the interpreter renders the intended result.

----

It occurred to me much later that SOH is a very rare and unhelpful control
character.
`09`, the tab character, was far more likely to give me a useful Google search.
And in fact "\_x0009\_" was a much more informative search page.
I was lead down a rabbit hole of the XML 1.0 spec, Microsoft's documentation
for `DocumentFormat.OpenXml.Spreadsheet.CellValue` of the OpenXml API, and the
`ST\_Xstring` type from ECMA-376.

ASCII control characters must be escaped in an XML document like "\_xHHHH\_".
In other words, when SPSS wrote an unencoded "\_x0001\_" into an XML file,
it was inevitable that any spec-compliant XML parser would substitute that
literal with SOH.
SPSS should have written "\_x005F\_x0001\_" instead.

----

I had to jump through a variety of hoops to report this bug.
I wasn't surprised by this;
I certainly didn't expect any more from IBM.
But I decided it was worthwhile anyway.
This seems like a highly technical bug that could net me some 'internet cred'.

