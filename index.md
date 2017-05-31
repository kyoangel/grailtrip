---
layout: page
title: Grail Trip
tagline: Ground Travel planner in Europe
description: To help you book europe trip tickets include DBahn, Italo, and Trenitalia
locale: en
---

As the first licensed API Consolidator of Deutsche Bahn (DB, German Railway), Trenitalia (Italy Railway), Italo and Flixbus, Grail provides unified and simplified APIs to search (compare), book railway and bus tickets in Europe. 


{% assign locale = page.locale%}
{% assign pages = site.pages | where:"lang", page.locale%}
{% for page in pages %}
  <li>
      <a class="post-link" href="{{ page.url | prepend: site.baseurl }}">{{ page.title }}</a>
  </li>
{% endfor %}

<br>


---

For further information, please contact [us](mailto: oulu@ul-e.com). 

