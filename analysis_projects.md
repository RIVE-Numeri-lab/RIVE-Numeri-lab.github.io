---
layout: default
title: Analysis projects
---
# Analysis projects

<ul>
  {% for post in site.analysis_projects %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>