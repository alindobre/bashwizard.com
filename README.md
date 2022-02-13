# This is bashwizard.com

<ul>
  {% for post in site.posts %}
    <li>
      <a href="aa{{ site.baseurl }}xx/{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
