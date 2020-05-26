---
layout: default
title: Workshops
---
Contenu de la page Workshops : 

<ul>
  {% for post in site.categories.workshop %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>