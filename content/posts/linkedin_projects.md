---
title: LinkedIn Project URLs
date: "2026-02-05T12:11:32-06:00"
draft: false
---

LinkedIn has removed the ability to associate a 'project' with a URL.
It seems the new flow that they want users to adopt is to associate
'media' with projects.
These media items can have a URL or a static file.

It's hard for me to understand why this change was implemented.
Media items are rendered as a box,
much like a thumbnail on YouTube,
so they're clearly optimized for visual works.
They take up more space on the screen and it's less obvious that they are
click-able.

Luckily, so many projects exist with URLs that LinkedIn cannot simply remove
the feature.
The fields still exist in the backend and they have yet to protect that route
from external API calls.

 1. Open a LinkedIn project in your preferred browser.
    Any browser that supports a 'developer tools' view will work.
 2. Make a minor edit and submit it using the 'Save' button.
 3. A POST request to a route like
    `graphql?action=execute&queryId=voyagerIdentity...`
    should have been captured.
    You can either copy this request into an external REST API client of your
    choice,
    or edit and resend the request within your browser.
    In Firefox you can hit the 'Resend' button.
 4. Edit the request body in the following ways:
    a. Find the `formElementUrn` field and replace the value with `url`.
    b. Find the `textInputValue` field and replace it with the URL you want
       associated with the project.
    c. Find the `trackingId` field and delete it entirely.
       This will simply bypass a backend check.
    d. Find the `queryID` (will probably be the last one) and add a new field
       after it.
       This field should be `"includeWebMetadata":true`.
 5. Submit the edited POST request and reload your browser.

Works like a charm as of February 2026.

