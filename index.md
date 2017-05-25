---
layout: page
title: Grail Trip
tagline: Your Trip Solution Across Europe
description: To help you book europe trip tickets include DBahn, Italo, and Trenitalia
locale: en
---

This website provides a series of documents for you on how to consume the Grail Trip API, in order to search and reserve tickets from DB, Italo and Trenitalia. 

{% assign locale = page.locale%}
{% assign pages = site.pages | where:"lang", page.locale%}
{% for page in pages %}
  <li>
      <a class="post-link" href="{{ page.url | prepend: site.baseurl }}">{{ page.title }}</a>
  </li>
{% endfor %}

<br>


---

For further information, please contact us at this [Email](mailto: oulu@ul-e.com).

