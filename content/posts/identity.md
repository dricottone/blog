---
title: Identity
date: 2022-10-06T10:13:32-05:00
aliases:
  - "/posts/identity"
draft: false
---

I've been thinking about adding identity verification by way of digital
signatures to my [web chat](https://www.dominic-ricottone.com/chat/).
This has lead to a bit of a deep dive into OpenPGP infrastructure and security
strategy.

A dip into this pond quickly informs a reader that the Web of Trust is flawed
fundamentally. The arguments against it center around a few points:

 1 End users don't hesitate to throw away their PGP keys.
   *(Because who actually knows enough about GnuPG configuration to migrate
   their setup between hosts? Everyone just uses the distro defaults...)*
   And because keys are such cheap things,
   end users don't take proper steps to protect them.
   Altogether, they fail to be trustworthy in the longer term.
 2 End users blindly import a key when a gist tells them to.
 3 End users prefer to verify their identity by password authentication.
   So all commercial and/or ambitious projects eventually outgrow PGP in terms
   of features and functionality.
 4 The infrastructure itself is vulnerable, *a la*
   [certificate poisoning](https://access.redhat.com/articles/4264021).

And on further consideration, there's always a bit of noise on project mail
lists when someone's signing key needs to be revoked.
A toolchain that requires so much maintenance is not a very good toolchain.

But further consideration leads to the question: *if not PGP, then what?*

I remember not too long ago seeing a number of GitHub issues requesting use
of signify for releases.
I didn't think highly of it at the time.
*(Just another BSD trying to force it's philosophy on mere mortals.)*
But in light of the above, maybe a simpler toolchain *is* what we need.

There's currently a public discussion in the
[age community](https://words.filippo.io/dispatches/age-authentication/)
about whether authentication should be supported.
This conversation has highlighted how federated identity is very difficult.

> If you encrypt and then sign, an attacker can strip your signature, replace
> it with their own, and make it look like they encrypted the file even if
> they don't actually know the contents.
>
> If you sign and then encrypt, the recipient can decrypt the file, keep your
> signature, and encrypt it to a different recipient, making it look like you
> intended to send the file to them.

Adding to all the consternation is the fact that I *am* trying to use
signatures in a chat application that is public, i.e. multiple recipients.

----

In the end, I have begun to press ahead with implementing digital signatures.
Signing happens *last*, and does not imply ownership over the content of the
signed message.
Rather, it ensures that *this instance* of the message came from a certain
sender.

At this stage I don't think it's a good idea to put real-world private keys
into the application, so I am just using ephemeral RSA keys and the PKCS #1
scheme for signatures (specifically RSASSA-PKCS1-v1_5).

I am interested in the idea of GPG integration though, so I'm likely to start
looking at a companion client implementation for use on the terminal.

