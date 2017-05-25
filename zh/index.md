---
layout: page
title: Grail Trip
tagline: Your Trip Solution Across Europe
description: To help you book europe trip tickets include DBahn, Italo, and Trenitalia
locale: zh
---

本站提供了调用Grail Trip API的文档。通过Grail Trip的API您可以预定德铁、意铁、法拉利铁路以及欧洲全境通票。

{% assign locale = page.locale%}
{% assign pages = site.pages | where:"lang", page.locale%}
{% for page in pages %}
  <li>
      <a class="post-link" href="{{ page.url | prepend: site.baseurl }}">{{ page.title }}</a>
  </li>
{% endfor %}

<br>

---
如您有更多问题，请联系 [邮箱](mailto:oulu@ul-e.com) 
