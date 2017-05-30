---
layout: page
title: Grail Trip
tagline: Travel planner in Europe
description: To help you book Europe group transportation tickets include DBahn, Italo, Trenitalia and Flixbus
locale: en
---

As official API Consolidator of [Deutsche Bahn](https://www.bahn.com/i/view/index.shtml)(DB)，[Trenitalia](trenitalia.com)，[Italo](italotreno.it/en) and biggest bus company [Flixbus](flixbus.com), Grail provides integrated access to APIs and data of major railway and bus companies in Europe. 

In addition to search and book tickets from our webpage, you can also integrate with Grail API (Search, Book, Confirm and Download ticket) such that you can sell tickets on your own webpage and Apps.

It is not hard to integrate with Grail API. Please refer to the following API documents below.


{% assign locale = page.locale%}
{% assign pages = site.pages | where:"lang", page.locale%}
{% for page in pages %}
  <li>
      <a class="post-link" href="{{ page.url | prepend: site.baseurl }}">{{ page.title }}</a>
  </li>
{% endfor %}

---
If you had any question, contact [us](mailto:oulu@ul-e.com) 

