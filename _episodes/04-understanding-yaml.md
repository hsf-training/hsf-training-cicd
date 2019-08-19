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

# YAML

YAML is Yet Another Markup Language that is usually the modus operandi for CI systems. We'll cover, briefly, some of the native types involved and what the structure looks like.

> ## Tabs or Spaces?
>
> We strongly suggest you use spaces for a YAML document. Indentation is done
> with one or more spaces, howver **two spaces** is the unofficial standard
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

## Anchors

YAML also has a handy feature called 'anchors', which let you easily duplicate content across your document. Anchors look like references `&` in C/C++ and named anchors can be dereferenced using `*`.

~~~
anchored_content: &anchor_name This string will appear as the value of two keys.
other_anchor: *anchor_name

base: &base
  name: Everyone has same name

foo: &foo
  <<: *base
  age: 10

bar: &bar
  <<: *base
  age: 20
~~~
{: .language-yaml}

The `<<` allows you to merge the items in a dereferenced anchor. Both `bar` and `foo` will have a `name` key.

{% include links.md %}
