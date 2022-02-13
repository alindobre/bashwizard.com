---
layout: page
title: home
description: "Teach about bash"
permalink: /bashwizard.com
---

# This is bashwizard.com

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>


