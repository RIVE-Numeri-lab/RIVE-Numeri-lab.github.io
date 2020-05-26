---
layout: default
title: Home
---

<div class="jumbotron">
    <div class="container">
      <h1 class="display-3">Welcome to the RIVE's Numerilab</h1>
      <p>Numeracy, noun<br />
the ability to understand and work with numbers.
</p>
      <p><a class="btn btn-primary btn-lg" href="/about" role="button">Learn more &raquo;</a></p>
    </div>
  </div>

  <div class="container">
    <!-- Example row of columns -->
    <div class="row">
      <div class="col-md-4">
        <h2>Latest workshop</h2>
        <p>{{ site.workshops.last.title }}</p>
        <p><a class="btn btn-secondary" href="{{ site.workshops.last.url }}" role="button">View details &raquo;</a></p>
      </div>
      <div class="col-md-4">
        <h2>Latest news</h2>
        <p>{{ site.news.last.title }}</p>
        <p><a class="btn btn-secondary" href="{{ site.news.last.url }}" role="button">View details &raquo;</a></p>
      </div>
      <div class="col-md-4">
        <h2>Latest analysis project</h2>
        <p>{{ site.analysis_projects.last.title }}</p>
        <p><a class="btn btn-secondary" href="{{ site.analysis_projects.last.url }}" role="button">View details &raquo;</a></p>
      </div>
    </div>

    <hr>

  </div> <!-- /container -->