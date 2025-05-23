---
title: "First Steps"
---

# Simple Example

Let's begin by writing and running some **mcl**, _mgmt_'s unique language, to
witness the software in action and to learn the key concepts behind it.

## Resources:

A `resource` is an element which makes changes to the world. It can modify the
local system or remote network resources. Instead of working `imperatively` the
way many common programming languages do, it lets you express the "desired
state" of what you'd like that world element to look like, and the resource
works out internally what it needs to do to get you there. Deciding that you'd
like a certain file to exist with specific contents, is the canonical example of
a resource.

### Example:

Put the following into a `hello0.mcl` file:

```
file "/tmp/mgmt-hello-world" {
	content => "hello world from @purpleidea\n",
	state => "exists",
}
```

Run: `mgmt run --tmp-prefix lang hello0.mcl` to try out this simple example!
Amidst the output generated by the engine, you should see a pertinent line that
resembles: `18:39:00 engine: file[/tmp/mgmt-hello-world]: copy 29 bytes`. This
line tells you that the `file` resource copied some bytes in so that the desired
state was what you requested.

### More details:

Note that the resource has a unique identifier (`"/tmp/mgmt-hello-world"`) and
some number of parameters, in this case `content` and `state` are used. All
three of these accept values, in this case each is a string. Parameters may
have different types, but the name is always a string. It may be a useful
property which is used in the execution of the resource, or it may solely be a
unique identifier for this particular resource element. Another unique aspect of
resources in `mgmt` is that they are "live". While `mgmt` is running, if the
state of a managed part of the world changes, then `mgmt` will detect this and
attempt to correct this divergence. You can try running the
`rm /tmp/mgmt-hello-world` command to see this in action.

## Functions:

A `function` is an element which brings data in from the world. It can
optionally consume input arguments. It then performs some operation and returns
the output. Functions are unique in that instead of returning a single value,
they can actually return streams of values. In other words, a function will
start up, and produce one, many, or an infinite number of values over time. They
may also re-evaluate their output when any of their inputs change. Those inputs
are also streams. In fact, even the number `4` is a stream, it just happens to
be a stream that produces a single value and then shuts down.

### Example:

Put the following into a `datetime0.mcl` file:

```
import "datetime"
import "fmt"

$unix_epoch_in_seconds = datetime.now()
file "/tmp/mgmt-datetime" {
	content => fmt.printf("datetime: %d\n", $unix_epoch_in_seconds),
	state => "exists",
}
```

Run: `mgmt run --tmp-prefix lang datetime0.mcl` to try out this simple example!
Amidst the output generated by the engine, you should see a pertinent line that
resembles: `18:55:43 engine: file[/tmp/mgmt-datetime]: copy 21 bytes`. This line
tells you that the `file` resource copied some bytes in so that the desired
state was what you requested. You should see this repeat every second. This is
because the requested "desired state" is constantly changing every second. The
`datetime.now()` function produces a stream of integers corresponding to the
current system clock time, expressed as the
[unix epoch](https://en.wikipedia.org/wiki/Unix_time).

### More details:

You'll notice that we "imported" the `datetime` and `fmt` packages. These are
system imports that provide useful functions. All of the values which are
produced are ultimately used to decide the number of `resources` and their
parameters. The set of resources produced is collected in what's called a
resource dependency graph, or **"resource graph"** which is a type of
[directed acyclic graph](https://en.wikipedia.org/wiki/Directed_acyclic_graph)
or `DAG`. This lets you describe that you want to ensure the desired state of
one resource is changed before another. (We'll show you how to express these
dependencies later on...)

The flow of data into and out of functions is also a `DAG`. When anything
"upstream" in the graph changes, it flows downstream until it finally is
consumed by a resource. This graph is called the reactive function graph, or
**"function graph"**. As a result, a running `mgmt` program produces a `stream`
of `resource graphs`.

## Documentation:

Documentation on the available
[resources](https://mgmtconfig.com/docs/resources/) and
[functions](https://mgmtconfig.com/docs/functions/) is
[available](https://mgmtconfig.com/docs/). It's easy to write more if you find
something that you're missing!

Congratulations on writing your first `mcl` code!
