---
layout: default
title: Calendar
---
# Calendar
## Upcoming events
<ul>
  {% for event in site.data.events %}
    {% assign today = 'now' | date: '%s' %}
    {% assign event_date = event.date | date: '%s' %}
    {% if today <= event_date %}
    <li>
      {{ event.date }} {{ event.title }}
    </li>
    {% endif %}
  {% endfor %}
</ul>
## Past events
<ul>
  {% for event in site.data.events %}
    {% assign today = 'now' | date: '%s' %}
    {% assign event_date = event.date | date: '%s' %}
    {% if today > event_date %}  
    <li>
      {{ event.date }} {{ event.title }}
    </li>
    {% endif %}
  {% endfor %}
</ul>
