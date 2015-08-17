---
layout: post
title: "Using MITMProxy for Testing and Debugging"
date: 2014-10-07 20:02:00 -0500
comments: true
categories:
  - debugging
  - proxy
---

In web development, you might occasionally get the urge to update a production server directly. **Don’t do that**. It may seem harmless to add some logging to better understand a bug, or make a quick change to test a proposed fix. Whatever the reason, manually updating code in production is risky business. Something will probably break, and undoing the change may not be as simple as a quick revert. At that point users will be impacted, and your boss will not be pleased.

## Introducing mitmproxy

[MITMProxy][mitmproxy] *is an interactive, SSL-capable man-in-the-middle proxy for HTTP with a console interface*. It allows us to *intercept, modify, replay and save HTTP/S traffic*, live or via python scripts. By directing our browser’s traffic through this tool, we can dynamically modify what gets sent to the server and what we get back from the server, without any danger of impacting the rest of our users.

## Why Not Just Use Dev Tools?

The developer tools availble in most modern browsers are great. They allow you to inspect and modify html, css, and javascript with ease. You can set breakpoints, inspect call stacks, experiment in the interactive console, and so much more. Still, there are several tasks that are difficult or impossible with dev tools. It is difficult to persist changes through a refresh or modify request/response metadata. If you want to artifically
delay an ajax call to test a timing issue, good luck.

MITMProxy on the other hand is great at these sort of tasks. You can intercept, delay, cancel, or modify any aspect of the request or response with ease. And since it’s running locally, you don’t need access to the server to see how these changes would impact the client. It is a great tool to use side-by-side with browser dev tools to expand our debugging capabilities.

## A MITMProxy Examples

### A Timing Issue

Let’s say we have a potential timing issue in our webapp. A user action triggers an ajax call, which retrieves some state from the server and sets cookies on the client. Another user action directs the browser to navigate to another page. If the user triggers these actions in quick succession, our the ajax call may not have completed, resulting in the client unexpectedly lacking some state (cookies).

This is difficult to test though, because this ajax call usually completes quickly enough that it is difficult to reliably trigger the second action before the first finishes. Using MITMProxy, we can trigger the first action, intercept the ajax call, and trigger the second action with full confidence that the call has not completed. This allows us to observe how the second action impacts the system.

### Checking a Hotfix

Assuming there was a timing issue that has now been fixed and verified in a dev enviornment, we’re ready for production. But for sanity’s sake, we’d like to do a controlled production test before fully rolling out. Using mitmproxy, we can intercept the production javascript file and replace it with our local copy. Then, running through the steps we used to find the bug, we can verify that the issue no longer exists.

## Using MITMProxy

The [mitmproxy documentation][mitmdocs] covers installation and basic use of mitmproxy far better than I could do here. At some point, I may write a cheat sheet of common commands, but that is outside the scope of this post.

For now, let’s look at how to accomplish specific tasks with mitmproxy.

### Intercepting a Single Request

Goal: Intercept calls to /ajax/something

1. From the interactive list view, hit ``i`` to declare an intercept filter.
1. Enter the filter ``~u /ajax/something``
1. Refresh the page that makes the call to /ajax/something. The request that gets intercepted will be colored orange.
1. When you’re ready to let the intercepted request pass, use ``j`` or ``k`` to navigate to it and hit ``a`` (for accept) to let it pass through.
1. Hit ``a`` again to let the response pass through.

### Replacing a File with a Local Copy

Goal: Intercept calls to google and replace the response content with a local file.

First, let’s create a dummy file. 

1. ``cat > dummy.txt`` 
2. Type whatever you want 
3. Hit ``Ctrl + d`` to write the file.

Now, let’s create the replacment script.

{% highlight python %}
from collections import namedtuple

Replacement = namedtuple('Replacement', ['pattern', 'filepath'])
REPLACEMENTS = map(Replacement._make, [
    # pattern, filepath
    ('~u google', 'dummy.txt'),
])


def request(context, flow):
    flow.request.anticache()
    flow.request.anticomp()


def response(context, flow):
    for replacement in REPLACEMENTS:
        # test for filter patterns with flow.match
        if flow.match(replacement.pattern):
            with open(replacement.filepath) as f:
                flow.response.content = f.read()
{% endhighlight %}

At this point, we can run mitmproxy with this script enabled ``mitmproxy -s replace_content.py``. From the browser, open ``www.google.com``, and observe your dummy.txt file instead.

### Modifying a Specific Value

Goal: Transform all instances of ``the`` to ``teh``

{% highlight python %}
def response(context, flow):
    flow.response.replace('the', 'teh')
{% endhighlight %}

Run ``mitmproxy -s the_teh.py`` and observe.

## Conclusion

MITMProxy is awesome.  [Go use it.][mitmproxy]

[mitmproxy]: http://mitmproxy.org/index.html
[mitmdocs]: http://mitmproxy.org/doc/index.html


