---
layout: page
title: Grail Trip
tagline: Your Trip Solution Across Europe
description: To help you book europe trip tickets include DBahn, Italo, and Trenitalia
locale: en
---

{% assign locale = page.locale%}
{% assign pages = site.pages | where:"lang", page.locale%}
{% for page in pages %}
  <li>
      <a class="post-link" href="{{ page.url | prepend: site.baseurl }}">{{ page.title }}</a>
  </li>
{% endfor %}

<br>

If anything here is confusing (or _wrong_!), or if I've missed
important details, please
[submit an issue](https://github.com/kbroman/simple_site/issues), or (even
better) fork [the GitHub repository for this website](https://github.com/kbroman/simple_site),
make modifications, and submit a pull request.

---

The source for this minimal tutorial is [on github](https://github.com/kbroman/simple_site).

Also see my [tutorials](http://kbroman.org/pages/tutorials) on
[git/github](http://kbroman.org/github_tutorial),
[GNU make](http://kbroman.org/minimal_make),
[knitr](http://kbroman.org/knitr_knutshell),
[R packages](http://kbroman.org/pkg_primer),
[data organization](http://kbroman.org/dataorg),
and [reproducible research](http://kbroman.org/steps2rr).
