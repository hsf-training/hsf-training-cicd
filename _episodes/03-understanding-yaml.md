---
title: "Understanding Yet Another Markup Language"
teaching: 5
exercises: 0
objectives:
  - Learn about YAML
questions:
  - What is YAML?
hidden: false
keypoints:
  - YAML is a plain-text format, similar to JSON, useful for configuration
  - YAML is a superset of JSON, so it contains additional features like comments and anchors, while still supporting JSON.
---

<iframe width="420" height="263" src="https://www.youtube.com/embed/c2sUhK3pDGo?list=PLKZ9c4ONm-VmmTObyNWpz4hB3Hgx8ZWSb" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
# YAML

YAML is Yet Another Markup Language is a human-readable data-serialization language. It is commonly used for configuration files and in applications where data is being stored or transmitted. CI systems' modus operandi typically rely on YAML for configuration. We'll cover, briefly, some of the native types involved and what the structure looks like.

> ## Tabs or Spaces?
>
> We strongly suggest you use spaces for a YAML document. Indentation is done
> with one or more spaces, however **two spaces** is the unofficial standard
> commonly used.
{: .callout}


## Scalars

~~~
number-value: 42
floating-point-value: 3.141592
boolean-value: true # on, yes -- also work
# strings can be both 'single-quoted` and "double-quoted"
string-value: 'Bonjour'
unquoted-string: Hello World
hexadecimal: 0x12d4
scientific: 12.3015e+05
infinity: .inf
not-a-number: .NAN
null: ~
another-null: null
key with spaces: value
datetime: 2001-12-15T02:59:43.1Z
datetime_with_spaces: 2001-12-14 21:59:43.10 -5
date: 2002-12-14
~~~
{: .language-yaml}

> ## Give your colons some breathing room
>
> Notice that in the above list, all colons have a space afterwards, `: `. This is important for YAML parsing and is a common mistake.
{: .callout}

## Lists and Dictionaries

~~~
jedis:
  - Yoda
  - Qui-Gon Jinn
  - Obi-Wan Kenobi
  - Luke Skywalker

jedi:
  name: Obi-Wan Kenobi
  home-planet: Stewjon
  species: human
  master: Qui-Gon Jinn
  height: 1.82m
~~~
{: .language-yaml}

### Inline-Syntax

Since YAML is a superset of JSON, you can also write JSON-style maps and sequences.

~~~
episodes: [1, 2, 3, 4, 5, 6, 7]
best-jedi: {name: Obi-Wan, side: light}
~~~
{: .language-yaml}

### Multiline Strings

In YAML, there are two different ways to handle multiline strings. This is useful, for example, when you have a long code block that you want to format in a pretty way, but don't want to impact the functionality of the underlying CI script. In these cases, multiline strings can help. For an interactive demonstration, you can visit [https://yaml-multiline.info/](https://yaml-multiline.info/).

Put simply, you have two operators you can use to determine whether to keep newlines (`|`, exactly how you wrote it) or to remove newlines (`>`, fold them in). Similarly, you can also choose whether you want a single newline at the end of the multiline string, multiple newlines at the end (`+`), or no newlines at the end (`-`). The below is a summary of some variations:

~~~
folded_no_ending_newline:
  script:
    - >-
      echo "foo" &&
      echo "bar" &&
      echo "baz"


    - echo "do something else"

unfolded_ending_single_newline:
  script:
    - |
      echo "foo" && \
      echo "bar" && \
      echo "baz"


    - echo "do something else"
~~~
{: .language-yaml}

### Nested

~~~
requests:
  # first item of `requests` list is just a string
  - http://example.com/

  # second item of `requests` list is a dictionary
  - url: http://example.com/
    method: GET
~~~
{: .language-yaml}

## Comments

Comments begin with a pound sign (`#`) and continue for the rest of the line:

~~~
# This is a full line comment
foo: bar # this is a comment, too
~~~
{: .language-yaml}

> ## Anchors
>
> YAML also has a handy feature called 'anchors', which let you easily duplicate content across your document. Anchors look like references `&` in C/C++ and named anchors can be dereferenced using `*`.
>
> ~~~
> anchored_content: &anchor_name This string will appear as the value of two keys.
> other_anchor: *anchor_name
>
> base: &base
>   name: Everyone has same name
>
> foo: &foo
>   <<: *base
>   age: 10
>
> bar: &bar
>   <<: *base
>   age: 20
> ~~~
> {: .language-yaml}
>
> The `<<` allows you to merge the items in a dereferenced anchor. Both `bar` and `foo` will have a `name` key.
{: .callout}

{% include links.md %}
