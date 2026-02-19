---
title: "Classes"
---

Classes are a grouping construct that lets you parameterize the contents. A
class has it's own local scope. It can "see" the parent scope. It can also
shadow anything in scope, which means that if you define something in your scope
with the same name as something that already existed in the parent, then the
parent value will not be accessible anymore.

A scope consists of variables, functions, and classes. All resources and edges
from any of the scopes are collected and flattened into a single, global,
resource graph.

## Basic classes

```mcl
import "fmt"
class foo {
	print "foo1" {
		msg => "inside foo",

		Meta:autogroup => false,
	}
}

$wow = "this is wow"	# gets captured

class bar($a, $b) { # a parameterized class
	print ["bar-"+ $a,] {
		msg => fmt.printf("inside bar: %s", $b + "; " + $wow),

		Meta:autogroup => false,
	}
}

include foo
include foo			# duplicate
include bar("b1", "hello")
include bar("b2", "world")
include bar("b2", "world")	# duplicate
```

Here you can see that classes can either have parameters or not. Note how we
include the same classes multiple times. Any identical duplication is allowed.

## Learn more

If you'd like to learn more about all of the intricacies about classes, you can
read the [original publication](https://purpleidea.com/blog/2019/07/26/class-and-include-in-mgmt/).
