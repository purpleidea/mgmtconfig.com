---
title: "Values and Types"
---

All of the expressions in `mgmt` must have a specific, concrete type. These are
determined at compile time. This is an important design principle of safe code.
There is no `nil`, `null`, or `undefined` value. This helps prevent another
[billion dollar mistake](https://en.wikipedia.org/wiki/Null_pointer).

The basic types are: `bool`, `str`, `int`, and `float`. The composite types are
`list`, `map` and `struct`. Finally we also have a `func` type.

For example, a composite type, such as a list of strings (`[]str`), differs from
a list of integers (`[]int`). Let's first go over how we express each type of
value.

# Values

Values are not mutable. You can express them quite simply.

**bool**

A `true` or `false` value.

**str**

A string, which we call an `str` is `"something"` enclosed in quotes.

**int**

A number, such as `42` or `-13`. Make sure it does not overflow or you will
error.

**float**

A floating point value, for instance: `3.1415926`. Make sure it does not
overflow or you will error.

**list**

Separate the values with commas and wrap the ends with square brackets, eg:

`[6, 7, 8, 9,]`.

(At the moment, lists always require a trailing comma after the last element.
This will soon change depending on if there's a newline or not.)

**map**

Each key and value is separated with the "rocket" operator, and the pairs are
separated by commas. The whole thing gets wrapped in curly brackets, eg:

```
{
	"boiling" => 100,
	"freezing" => 0,
	"room" => 25,
	"house" => 22,
	"canada" => -30,
}
```

(At the moment, maps always require a trailing comma after the last element.
This will soon change depending on if there's a newline or not.)

**struct**

Similar to a map, except it starts with the keyword `struct`, eg:

```
struct{
	answer => "42",
	james => "awesome",
	is_mgmt_awesome => true,
}
```

* Note the syntactical difference between **map** and **struct**. Whereas the
_keys_ in **map**'s have types and therefore are enclosed in quotes if they are
strings, the _fields_ in **struct** 'sare never string values and therefore are
specified without quotes.

**func**

When defining a function, it is often common to omit the types unless you want
to strictly ensure a specific type. The body of the function is the return
value.

```
func($d) {
	42 + $d
}
```

or:

```
func($a bool, $some []str, $m map{str: float}) struct{foo str; bar int} {
	# function contents here
}
```

Functions defined in this way are used as values, that is, they are usually
passed to other functions and applied, often to some number of arguments. When
used in this way, we sometimes call them lambdas.

Lambda functions may only have a single type, even if they are used in more than
one place where it might seem plausible to allow it to be polymorphic. If you
don't know what this means, don't worry about it right now, just know that later
on we will learn to define a function as a statement, where it can be reused
with multiple different signatures.

# Types

You rarely need to explicitly express a type, but when you do here's how it
would look:

**bool, str, int, float**

The basic types can be referred to with their keyword: `bool`, `str`, `int`, and
`float`. These wrap the golang `bool`, `string`, `int64` and `float64` types
respectively. We may represent the `int` type as a platform specific golang
`int` in the future.

**list**

Lists are ordered collections of values of the same type. They can be expressed
as:

`[]type`, for example `[]str` or `[][]bool` and so on.

Even empty lists have a type, although without type hints it may be impossible
to infer the type.

**map**

Maps are unordered set of pairs of unique keys of the same type and the
corresponding values of another type, eg:

`map{type_key: type_val}`, for example `map{str: int}` or
`map{map{str: int}: map{int: bool}}` and so on.

Just as all keys must be of the same type, all values must be of the same type.
You can use any type for the values. The type of the keys must be one which is
comparable.

**struct**

A struct usefully combines multiple types into the same container. It is a set
of field names with a corresponding type for each. To express one, you may
write:

```
struct{a type1; b type2; c type3}
```

For example:

```
struct{a bool; bb int}
```

or:

```
struct{a bool; bb int; ccc []str; dddd struct{a int; z bool}}
```

**func**

A function is an ordered set of optionally named, differently typed input
arguments, and a return type, eg:

```
func(arg_zero bool, arg_one str) int
```

or:

```
func(bool, []str, {str: float}) struct{foo str; bar int}
```

Functions may only have a single return type, and it must not be omitted. Only
the arg names may be omitted when defining the type. Two function types with the
same signature, but different arg names are compatible types.

* Note the syntactical difference between **func** `value` and the **func**
`type`. The arg names in the `value` contain a `$` prefix and are required.
Specifying types is optional. Where as in the `type` syntax specifying the arg
names is optional and there are no `$` prefixes. Naturally you must specify all
of the types.

# Specifying a type

Most of the time, the **type unification** algorithm will automatically figure
out what types are correct for each of your expressions. Occasionally, or for
policy, you will want to explicitly specify some of them. There are two methods
for doing so.

## Bind Statement

When using the bind statement, an optional type is allowed. It looks like this:

```
$foo int = 42
```

The expression (in this case `42`) is seen on the right hand side. The variable
we're binding this to is seen on the left. Immediately to the left of the equals
assignment operator you may specify an optional type in the type format seen
above.

## Function Definitions

In any function definition the types may be specified. For example:

```
func foo($a int, $b) str {
	if $a > $b {
		"a is bigger than b"
	} else {
		"a is not bigger than b"
	}
}
```

Note that the return type of `str` can be safeloy omitted here, where as this
function would also work with `float` if the `int` wasn't specified. The second
argument does not specify that it must be an `int` but that will be inferred
during type unification.

# Type Unification

The golden rule of working with types in _mgmt_ is that each expression must
have a known type at compile time. Some languages require that every type
be annotated. Others look at types during runtime. With _mgmt_, we do something
called **type unification**, which is an elegant mechanism for letting the
compiler figure out the correct types during compile time. This gives you the
benefit of not needing to constantly annotate your code, while still gaining the
safety benefits of a statically typed language.

## Success:

Type unification is mandatory and automatic, but if you'd like to solely type
check your code, run the following:

`mgmt run --tmp-prefix lang --only-unify hello0.mcl`

You will likely see the engine print something along the lines of:

`09:41:23 cli: lang: type unification succeeded in 365.892µs`.

## Failure:

Similarly, examine what will happen if you attempt to write some invalid code:

```
file "/tmp/foo" {
	content => 42 + "hello",
}
```

This program will not type check or compile, and instead you will see:

```
23:22:24 cli: lang: running type unification...
23:22:24 cli: lang: unification: type error: int != str: failure.mcl @ 2:13-2:18

	content => 42 + "hello",
	           ^^^^^^
```

This is because it is illegal to use the `+` operator to combine an `int` with
an `str`.
