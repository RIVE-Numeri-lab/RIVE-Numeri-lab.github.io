---
layout: default
title: Workshops
---
Contenu de la page Workshops : 

<ul>
  {% for post in site.workshops %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>