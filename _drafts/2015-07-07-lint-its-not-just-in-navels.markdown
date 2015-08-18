---
layout: post
title: "Lint: It's Not Just In Navels!"
date: 2015-07-07 16:26:40 -0500
comments: true
categories:
  - python
  - javascript
  - workflow
---

Lint has been around for a long time. For much of that history, it was primarily found on sheep and in navels. Then, at some point in the mid to late 20th century, a new [lint][lint] was created. This new lint was a tool that identified suspicious constructs in C code. Since then, the term "lint" has grown to mean any potential bug or style issue in a codebase[^1]. It could be a misplaced``{`` in a C-like language[^2], a mix of spaces and tabs in Python[^3], or a variable without a ``var`` in Javascript[^4]. Any common mistake that can be identified through static analysis[^5] can generally be referred to as lint.  

## Lint Checkers

A lint checker is a tool designed to identify these issues and raise a warning before they become a problem. There are many different lint checkers available for many different languages[^6].

### Style Checkers

A style checker is a lint checker that focuses on how the code is formatted.  They do not necessarily have an impact on how well the code runs, but they are important for a few reasons. Style guides help to cut down on unecessary arguments.

Onboarding new developersThese are useful because they help developers produce code with a consistent look and feel, which in turn reduces the [cognitive load][cog_load] in understanding and contributing to a code base. 

### Error Checkers



### Python Checkers

There are a number of useful Python checkers that can help developers avoid common mistakes and write cleaner code. 




#### List of Python Checkers

|---
Checker | Style | Errors | Description
|-|:-:|:-:|:-|
[pep8][pep8] | x | x | Finds discrepencies between a codebase and the [official Python style guide][pep8_pep].
|---
[pep257][pep257] | x | | Focuses on [docstring conventions][pep257_pep]. 
|---


Let's look at a snippet with some style errors:

`` include_code lang:python lint/snippet1.py % ``

We can run the pep8 checker on this file and it will report several issues.

`` include_code lang:shell-session lint/sh1 % ``

Here is the same snippet, reformatted.

`` include_code lang:python lint/snippet2.py % ``

And now, pep8 has nothing to report.

`` include_code lang:shell-session lint/sh2 % ``

Next, let's try the pep257 checker

`` include_code lang:shell-session lint/sh3 % ``

Oops, we're missing some docstrings.

`` include_code lang:python lint/snippet3.py % ``

And one more try

`` include_code lang:shell-session lint/sh4 % ``

Excellent!  We've cleaned up our snippet so that it complies with pep8 and pep257.

Of course, style issues aren't the only things we're concerned with when linting.


## TODO

- Talk about tooling
  - be a good citizen
  - python (flake8, pylint)
  - js (eslint, jslint, jshint)
- Plugins
- Editor integration
- Closing


[^1]: https://en.wikipedia.org/wiki/Lint_(software)
[^2]: https://en.wikipedia.org/wiki/Indent_style
[^3]: https://en.wikipedia.org/wiki/Python_syntax_and_semantics#Indentation
[^4]: https://en.wikipedia.org/wiki/JavaScript_syntax#Scoping_and_hoisting
[^5]: https://en.wikipedia.org/wiki/Static_program_analysis
[^6]: https://en.wikipedia.org/wiki/List_of_tools_for_static_code_analysis

[pep8]: https://github.com/jcrocholl/pep8
[pep8_pep]: https://www.python.org/dev/peps/pep-0008/
[pep257]: https://github.com/GreenSteam/pep257
[pep257_pep]: https://www.python.org/dev/peps/pep-0257/
[pylint]: http://www.pylint.org/
[pyflakes]: https://pypi.python.org/pypi/pyflakes
[flake8]: https://flake8.readthedocs.org/
[mccabe]: https://en.wikipedia.org/wiki/Cyclomatic_complexity
[pylama]: https://pylama.readthedocs.org/

[cog_load]: https://en.wikipedia.org/wiki/Cognitive_load
[lint]: http://www.unix.com/man-page/FreeBSD/1/lint
