---
layout: default
title: News
---
# News
Contenu de la page News : 

<ul>
  {% for post in site.news %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>