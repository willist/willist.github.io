---
layout: post
title: "Breaking an iterable into chunks"
date: 2014-08-22 11:42:00
categories: 
  - python 
  - snippet 
---

The [itertools][itertools] library is one of my favorites in the python stdlib.  It allows you to operate on an iterable in all kinds of fun and iteresting ways.  For example, if you have a series of iterables and you'd like to loop over one after the other performing the same operation, you might normally do something like this:


{% highlight python %}
def operate(item):
    #perform some operation

x = range(10)
y = range(100, 110)
z = range(200, 210)

for item in x:
    operate(item)

for item in y:
    operate(item)

for item in z:
    operate(item)

{% endhighlight %}

With [itertools][itertools], you can do this instead:

{% highlight python %}
from itertools import chain

for item in chain(x, y, z):
    operate(item)
{% endhighlight %}

For a more interesting example, let's play FizzBuzz. The rules are as follows:

* Count up from 1 saying each number
* If a number is divisible by 3, say Fizz instead of the number
* If a number is divisible by 5, say Buzz instead of the number
* If a number is divisible by 3 and 5, say FizzBuzz instead of the number

{% highlight python %}
# Define our tests
def divisible_by(divisor):
    def inner(num):
        try:
            num = int(num)
        except (ValueError, TypeError):
            return False
        return num % divisor == 0
    return inner

by_3 = divisible_by(3)
by_5 = divisible_by(5)
by_15 = divisible_by(15)

def replace(test, word):
    """ Replace `item` with `word` if `item` passes the `test`.
    """
    def inner(item):
        return word if test(item) else item
    return inner

fizz = replace(by_3, "Fizz")
buzz = replace(by_5, "Buzz")
fizzbuzz = replace(by_15, "FizzBuzz")

# Now, we can use itertools to solve the problem
from itertools import count, imap

numbers = count(1) # this will count up forever, starting at 1

numbers = imap(fizzbuzz, numbers)
numbers = imap(fizz, numbers)
numbers = imap(buzz, numbers)

for number in numbers:
    print number

{% endhighlight %}

In additional to all the useful built in functions that [itertools][itertools] provides, there are a number of very useful [recipes][itertools-recipes] for creating your own tools.

One such tool is the grouper function.

{% highlight python %}
def grouper(iterable, n, fillvalue=None):
    "Collect data into fixed-length chunks or blocks"
    # grouper('ABCDEFG', 3, 'x') --> ABC DEF Gxx
    args = [iter(iterable)] * n
    return izip_longest(fillvalue=fillvalue, *args)
{% endhighlight %}

This is great, right up until you need the last chunk to not have any filler.

For this, you can use `chunky`:

{% highlight python %}
"""
Take an iterable and split it into N sized chunks. If the iterable is not
evenly divisable by N, the final chunk will be the size of the remainder.
"""
from itertools import islice

def chunky(sequence, n=None):
    """ Collect data into fixed-length chunks or blocks
    with final block truncated if the sequence is not evenly
    divisible by N.
    """
    # chunky('ABCDEFG', 3) --> ABC DEF G
    iterable = iter(sequence)
    next_group = tuple(islice(iterable, n))
    while next_group:
        yield next_group
        next_group = tuple(islice(iterable, n))
{% endhighlight %}

This is useful if we have a backlog of tasks to perform, but we don't have
the resources to perform them all at once.  We can chunk the task list and
do the work in smaller units.

How it looks in practice:

{% highlight pycon %}
>>> ten_items = range(10)
>>> list(chunky(ten_items, 5))
[(0, 1, 2, 3, 4), (5, 6, 7, 8, 9)]

>>> list(chunky(ten_items, 10))
[(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)]

>>> list(chunky(ten_items, 1))
[(0,), (1,), (2,), (3,), (4,), (5,), (6,), (7,), (8,), (9,)]

>>> list(chunky(ten_items))
[(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)]

>>> list(chunky(ten_items, 3))
[(0, 1, 2), (3, 4, 5), (6, 7, 8), (9,)]
{% endhighlight %}

That's it for now.  Thanks for stopping by!

[itertools]: https://docs.python.org/2/library/itertools.html
[itertools-recipes]: https://docs.python.org/2/library/itertools.html#recipes
