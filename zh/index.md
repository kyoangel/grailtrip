---
layout: page
title: Grail Travel
tagline: 欧洲陆路交通向导
description: 帮助您搜索、比较、预定欧洲地面交通（铁路、大巴）车票
locale: zh
---

作为[德国铁路局](https://www.bahn.com/i/view/index.shtml)(DB Deutsche Bahn)，[意铁](trenitalia.com)(Trenitalia)，[法拉利铁路公司](italotreno.it/en)(Italo)以及欧洲最大的长途大巴公司[Flixbus](flixbus.com)的认证API集成商(Consolidator)，Grail集成了欧洲各大铁路公司以及大巴公司的数据以及数据接口，为到欧洲旅游的游客提供集成订票服务。

除了通过网页预定，您的网站或者App也可以通过与Grail的API(Search, Book, Confirm, Download Ticket)集成，通过集成我们的API，您可以在你自己的页面上搜索、预定德铁、意铁、法拉利铁路、欧洲全境通票以及Flixbus大巴车票。

想要了解如何集成Grail API，可以参考下面文档

{% assign locale = page.locale%}
{% assign pages = site.pages | where:"lang", page.locale%}
{% for page in pages %}
  <li>
      <a class="post-link" href="{{ page.url | prepend: site.baseurl }}">{{ page.title }}</a>
  </li>
{% endfor %}

<br>

---
如您有更多问题，请联系[我们](mailto:oulu@ul-e.com) 
