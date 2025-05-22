---
title: "Language Features"
---

At this point you should have a rough understanding of how the language works.
Let's dive into a few unique features which we should elaborate on.

# Structure

Every top-level `mgmt` program is a list of `statements`.

## Statements

The available **statements** are `bind`, `func`, `res`, `edge`, `if`, `class`,
`include`, `import`, `comment`, `for`, `forkv`, `collect`, and `panic`. We'll
cover these in detail later. Most of these take one or more **expressions**,
which produces a value.

## Expressions

The available **expressions** are `call`, `var`, `if`, or any literal `value`.
Note that the `if` **expression** differs from the `if` **statement**, in that
the former returns an expression in either scenario, and the latter returns a
list of statements. The `else` branch in an `if` statement is optional.

# Escape Characters

When specifying a string, you may include any number of special escape
characters. The list includes:

* `\\` a backslash
* `\a` a bell
* `\b` a backspace
* `\f` a form feed
* `\n` a newline
* `\r` a carriage return
* `\t` a horizontal tab
* `\v` a vertical tab
* `\"` a quotation mark
* `\$` a dollar sign

# String Interpolation

Strings support interpolation. You may substitute in a variable of type `str`
anywhere you like by adding a dollar sign in front of a pair of curly brackets
with the variable name inside it. Example:

```
$person = "purpleidea"
file "/tmp/foo" {
	content => "hello from ${person}\n",
}
```

Please note that the curly braces are not optional. Furthermore, remember that
for example, if the variable is of type `int`, it will not automatically convert
to `str` and you will have a type unification error.

# Immutability

Variables (and values) are immutable in `mcl`. In other words, the following is
a compile time error:

```
$s = "hello"
$s = "world"
file "/tmp/foo" {
	content => $s,
}
```

This errors with:

```
duplicate assignment to `var:s`, have: bind(s)
```

Immutability is an import safety feature in programming.

# Shadowing

This doesn't mean that variables can't be "shadowed". Shadowing is where you
define a variable in a child (nested) scope, which has the same variable name as
one that exists in the parent scope.

```
$s = "hello"
if true {
	$s = "world" # shadows the parent in this scope
	file "/tmp/bar" {
		state => "exists",
		content => $s,
	}
}
file "/tmp/foo" {
	state => "exists",
	content => $s,
}
```

While the above code is legal, it is not necessarily the recommended best
practice. The `$s` variable is never mutated, rather, a second variable is
created in the `if` statement body, which overwrites what would ordinarily
contain a reference to the outer variable.

# Ordering

Strangely, the "ordering" of statements in an `mcl` program does not matter.
This is not to say that you should write things in an illogical way. For
example:

```mcl
file "/tmp/mgmt/hello" {
	state => "exists",
	content => "${y}\n",
}

file "/tmp/mgmt/" { # this is a directory
	state => "exists",
}
$y = $x
$x = "hello"
```

Note that the language aspects (`$y = $x`) do not need to be in the logical
order, and that the engine aspects (file before it's parent directory) don't
either.

This is because the language forms a **function graph**, which produces a
**resource graph** for the engine, neither of which necessarily have a linear
order when executed in graph format.

We may consider adding a flag or feature which enforces the
["topological sort"](https://en.wikipedia.org/wiki/Topological_sorting) ordering
at some point in the future, so keep your code logically ordered where possible.

# Reactivity

As previously mentioned, all values in `mcl` are actually streams. This enables
`mgmt` to be quite powerful, without compromising too much on safety. Every
stream must produce at least one value. It can decide to produce values forever,
or it can produce some number of values and then shut down the stream. Most
programs start out initially quite large, and then quickly collapse themselves
down after a few moments into smaller, more compact programs. This frees memory
when it happens too!

# Modules

Any imported module may only contain functions, variables, and class definitions
at the top-level. This is because an `import` must not cause any side effects.
This is all about preventing surprises to the programmer. There are some rare
exceptions to this rule. Modules will be explained in a subsequent section.

# Indentation

All `mcl` programs must be indented with tabs, the same as `golang` programs.
Using tabs is faster, more efficient, more accessible, and elegant.
