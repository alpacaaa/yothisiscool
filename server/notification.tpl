
<h1>Hi, {{user.name}}!</h1>

<p>You have some shit to check out</p>

{{#comments}}
<p>
  <strong>@{{#author}}{{username}}{{/author}}</strong> – {{body}}
</p>
{{/comments}}

<p>
  Change when receiving notifications:
  <ul>
    <li><a href="{{daily}}">Daily</a></li>
    <li><a href="{{weekly}}">Weekly</a></li>
    <li><a href="{{monthly}}">Monthly</a></li>
  </ul>

  You'll get notified only if there's something new, no spam!
</p>


<p>
  <a href="{{unsuscribe}}">Unsuscribe</a>
</p>
