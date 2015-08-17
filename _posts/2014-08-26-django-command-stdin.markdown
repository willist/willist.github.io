---
layout: post
title:  "Piping Data into a Custom Django Management Command"
date: 2014-08-26 22:25:00
description: How to create a Django manage.py commmand which takes input from stdin or reads in files.
categories: 
  - python 
  - django 
  - unix
---

For command line administration of a [django][django] site, nothing is better than [manage.py][django-admin].  It provides a single point of access for database management, development tasks, data serialization and deserialization, testing, and more.  Even better, you can write your own [custom commands][custom-commands] and ship them with your app.  In many cases, the expected input for a manage.py command is simple.  It may be an app name or a list of model ids, which can be easily typed for a one off command, i.e.``python manage.py somecommand 1 2 3``.  This is great when you already know the input, but there are cases when you need to run one command to get the information you need for a follow up command. How can we solve that problem?


## Manual Input

One mechanism for passing information between commands is to do so manually.

First, let's run a command that will give us some information from our django site.

{% highlight shell-session %}
$ python manage.py somecommand list
ID      Title       Date
1       Foobar      2014-01-01 12:00
2       Bar-foo     2014-02-10 14:41
3       Baz         2014-05-10 08:19
{% endhighlight %}

Here, there are three items listed from ``somecommand list``, with IDs 1, 2, and 3.

Now, we can pass those IDs into another command.

{% highlight shell-session %}
$ python manage.py somecommand sync 1 2 3
Synced items 1, 2, 3 with master.
{% endhighlight %}

This works well enough, but it's not easily repeatable.  Perhaps we can use tools available in our unix shell to automate that step.

## Piping via Shell Commands

As we saw earlier, we have output from a list command that contains the item ids we need to pass into the sync command.  We just need to remove the last two columns and the header.
We can filter out the extra columns with ``awk``, using ``awk '{ print $1 }'`` to grab only the first column.

{% highlight shell-session %}
$ python manage.py somecommand list | awk '{ print $1 }'
ID
1
2
3
{% endhighlight %}

This is looking better, but "ID" isn't needed.  We can remove it using ``tail`` - specifically ``tail +2``, which will return all lines starting with the 2nd.

{% highlight shell-session %}
$ python manage.py somecommand list | tail +2 | awk '{ print $1 }'
1
2
3
{% endhighlight %}

Now, we're ready to pass this into our ``sync`` command.  We could try to pipe the output of our previous command directly in, but that won't work. The ``sync`` command isn't listening to STDIN; it's only looking for positional arguments. 

{% highlight shell-session %}
$ python manage.py somecommand list | tail +2 | awk '{ print $1 }' | python manage.py sync
Nothing to sync!
{% endhighlight %}

To convert our previous output to positional arguments, we can use ``xargs``.

{% highlight shell-session %}
$ python manage.py somecommand list | tail +2 | awk '{ print $1 }' | xargs python manage.py sync
Synced items 1, 2, 3 with master.
{% endhighlight %}

Excellent! We've piped the results of ``list`` into ``sync`` using a little bit of unix glue. Now, we can include this in a bash script or write an alias that will turn our one liner into a easily repeatable process.

## Expecting STDIN

In the previous example, we ran into trouble trying to pipe data directly into a ``manage.py`` command.  We solved that problem with ``xargs``, but wouldn't it be cool if we could accept STDIN **or** positional arguments?

Reading from stdin in a ``manage.py`` command is fairly simple.  We import ``sys`` and read lines from the stdin file object as we would in any other python program.

{% highlight python %}
from django.core.management.base import BaseCommand, CommandError

class Command(BaseCommand):
    args = '<id ...>'

    def handle(self, *args, **options):
        # If there are no args, use stdin
        if not args:
            args = sys.stdin.readlines()

        for arg in args:
            print arg
{% endhighlight %}

Now, we can skip ``xargs`` and pipe the IDs directly into the ``manage.py`` command. This is interesting, but probably not worth the effort.

## Expecting STDIN with Large Datasets

So far, we've mostly covered commands that deal with small inputs or no input.  What happens when we have a command that expects to operate on files instead of IDs?

Using positional arguments, this probably works about as we'd expect.  The import command will iterate through the positional arguments and import the data contained therein one at a time.

{% highlight console %}
$ python manage.py somecommand import a.txt b.txt c.txt
{% endhighlight %}

How would this work with STDIN, though?  Using the previous ``Command``, we'd have to pass in filenames.
{% highlight console %}
$ echo a.txt b.txt c.txt | python manage.py somecommand import
{% endhighlight %}

That could be useful if we're trying to ``find`` the backups we want to import, but like the previous example, it's not really worth the effort.  What we really want to do is either pass in filenames as positional arguments or pass the files themselves via STDIN.

{% highlight console %}
$ cat a.txt b.txt c.txt | python manage.py somecommand import
{% endhighlight %}

Fortunately, the python standard library has a module called [fileinput][fileinput] which does almost exactly that.  [Fileinput][fileinput] allows us to accept multiple input streams with the same command.  We can pass in a list of files as positional arguments or pipe the files themselves using STDIN.

{% highlight python %}
import fileinput

from django.core.management.base import BaseCommand, CommandError

class Command(BaseCommand):
    def handle(self, *args, **options):
        for line in fileinput.input(args):
            print line
{% endhighlight %}

Now, we can do fun things like exporting production data and importing it into our local dev site.

{% highlight console %}
$ ssh prodserver:/var/www/mysite python manage.py somecommand export | python manage.py somecommand import
{% endhighlight %}

Thanks for stopping by!


[custom-commands]: https://docs.djangoproject.com/en/dev/howto/custom-management-commands/
[django-admin]: https://docs.djangoproject.com/en/dev/ref/django-admin/
[django]: https://docs.djangoproject.com/en/dev/
[fileinput]: https://docs.python.org/2/library/fileinput.html 
