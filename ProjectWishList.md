# Introduction #

Fairly often, people contact me and say they'd like to contribute to the OWASP iGoat project. That's great! The next question is always, "What can I do?". Well, to address that question, I'll be maintaining a list of things here that need to be done.

So, to you volunteers (prospective and actual), **any** or all of these things would be appreciated


# Details #

OWASP iGoat Wish List (last updated: 2013-02-26 by KRvW):

  * Docs. The page here on how to write iGoat exercises is in need of updating.

  * Docs. Every exercise in iGoat needs to have its Solution docs verified and (if needed) edited.

  * Exercises. We always want to see new exercises. Thanks to the modular platform we've built, writing an exercise can be relatively easy. At least, the heavy lifting is largely done for you; what you need to do is to write the logic layer behind the view. The hardest part is coming up with good ideas and then coming up with a viable way to "story board" them into an iGoat exercise. Some ideas for new exercises follow, but you're really only limited by your own imagination:
> > - Certificate pinning. We have someone who's been working on this, but we're having a tough time coming up with a scenario that'll work best. Ideas and suggestions are appreciated.


> - Authentication. We have a very simple authentication exercise that really just turns on SSL encryption for the POST to the server. We'd like to see an exercise that involves implementing a modern authentication and session management component (e.g., OAuth + SAML, others...).

> - Geolocation. We don't have an exercise that addresses privacy exposures from logging geolocation data, but that would be great to include.

> - Web views. We don't have an exercise that illustrates the dangers of using UIWebView without any controls for filtering potential malicious content.

> - Key management. Our local data storage (SQLcipher) app uses a stupid, hard-coded encryption key. How about an exercise that demonstrates sound crypto practices by generating a strong key, safely sending a backup of the key to a server, and then encrypting the data using that key?

> - Local data storage. Our local data storage app uses AES-256 via SQLcipher, but what about encrypted data storage that isn't SQL? How about an exercise that implements the CCCrypt library to encrypt some other (non-SQL) data locally? Same comments as above re key management...

  * Exercise. Our current solution to safely backgrounding an app involves protecting (hiding) any sensitive data on a screen prior to handing off control to the OS. We'd like to see a more general solution that instead does something like put an iGoat logo on the user's screen on backgrounding, and then re-draws the user's screen once the app becomes active again.

  * Ideas. We always appreciate ideas and suggestions for improving iGoat -- especially from people who are willing to help implement their cool ideas.


If any of these appeal to you and you want to contribute to iGoat, we'd love to hear from you. Please email me and let's chat.

Cheers,

Ken van Wyk
ken (at) krvw.com