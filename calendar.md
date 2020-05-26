---
layout: default
title: Calendar
---
Contenu de la page Calendar : 
## Upcoming events
<ul>
  {% for event in site.data.events %}
    <li>
      {{ event.date }} {{ event.title }}
    </li>
  {% endfor %}
</ul>
## Past events
<ul>
  {% for event in site.data.events %}
    <li>
      {{ event.date }} {{ event.title }}
    </li>
  {% endfor %}
</ul>
