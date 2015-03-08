
<h1>Hi, {{user.name}}!</h1>

<p>You have some shit to check out</p>

{{#comments}}
<p>
  <strong>@{{#author}}{{username}}{{/author}}</strong> – {{body}}
</p>
{{/comments}}


<p>
  <a href="{{unsuscribe}}">Unsuscribe</a>
</p>
