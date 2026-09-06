---
title: "Walkthrough"
---
<!--

Greetings, documentation contributors!

Design goals for this document:

* Provide a gradual introduction, with each section building on the previous.
* Use real examples that demonstrate what was just covered.
* Avoid jargon, such as "DAG", until absolutely necessary.

As an example, [Elm](https://guide.elm-lang.org) does a fantastic job of
explaining how to use a functional programming language *without* burdening the
reader in high-level mathematical terms that are unavoidable in language docs
like Haskell.

It's OK to refer to these technical terms, "in mgmt, this is called x" after the
behavior or concepts have been explained.

Example mcl code should be indented with tabs. To check this, you can run the
`mgmt fmt` command to make sure your code is formatted correctly. If it's inline
you can run the following command to print lines that might need to use tabs for
indentation:

	awk '/^\s*```puppet/ { mcl=1; next } /^\s*```\s*$/ { mcl=0 } mcl == 1 && /^[ ]+[A-Za-z0-9#]/ { print NR, $0 }' walkthrough.md
-->

# Welcome to mgmt config!

This guide is designed to teach you the concepts and syntax needed to use mgmt
successfully on your first day. Each section introduces concepts and related
syntax that build on the previous sections, so we recommend following this guide
from start to finish. The runnable examples are intended to be run by you, so
ensure you have [mgmt installed](/docs/guide/getting-started/).

Examples in this document were tested on Fedora 44, so for best results, we
recommend having a fresh Fedora installation available. It is OK if you do not
have one, though, and most of the examples should still be useful.

{{< toc heading="Table of Contents" >}}

## Configuration with Resources

In mgmt, configuration is described using elements called **resources**. Most
resource kinds will be familiar and align with your mental model of your
infrastructure. For example, a resource can ensure that a package is installed,
a service is disabled, or a user exists.

Resources have three parts: a kind, a name, and parameters (mgmt calls these
**params**). The following example shows a single `file` resource written in
mgmt's programming language, _mcl_:

```puppet
file "/tmp/hello.txt" {
	state => "exists",
	content => "Greetings from mgmt!\n",
}
```

This `file` resource is named `/tmp/hello.txt`. It describes a state where you
want the file to exist and contain exactly:

```text
Greetings from mgmt!
```

With this programming model, you express the desired state for each resource,
and mgmt makes it real by observing the current state and making any necessary
changes. The language, _mcl_, is a strongly-typed, reactive, functional
language, and if those terms are unfamiliar to you, do not worry! Each of those
terms will be discussed further in this guide.

### Running mgmt

You can execute _mcl_ code with mgmt. First, place the sample code above in a
file named `hello.mcl`, then run `mgmt run lang hello.mcl`. Mgmt normally writes
its logs to stderr, so the output from our `file` resource will look like this:

```text
$ mgmt run lang hello.mcl

... (other output omitted for brevity) ...

10:28:48 engine: file[/tmp/hello.txt]: copy 21 bytes
```

When you run this, notice the following:

* Mgmt did not exit after converging. More on this in the next section.
* Mgmt can run as any user, but that user will need the correct permissions to
	execute some resources.
* The first part, `10:28:48`, is a timestamp. Your timestamps will be different.

When all resources are in their desired state, mgmt considers the system
**converged**.

Let's verify that our file was created correctly. Run the following in another
terminal to view its contents:

```text
$ cat /tmp/hello.txt
Greetings from mgmt!
```

### Continuous Convergence

In the example above, mgmt stayed running even after converging. This is because
mgmt continuously watches for changes (aka divergence) and will **react**
immediately and as needed.

Let's explore that! While mgmt is still running, we can modify the file in
another terminal and observe mgmt's immediate responses:

```bash-session
# Remove the file.
$ rm /tmp/hello.txt

# mgmt notices and responds:
10:36:34 engine: file[/tmp/hello.txt]: copy 21 bytes

# Change the file's contents.
$ echo "mgmt is fast" > /tmp/hello.txt

# mgmt notices and responds:
10:37:18 engine: file[/tmp/hello.txt]: copy 21 bytes
```

You can terminate mgmt in your terminal by pressing ctrl+c.

Each time we remove or modify the file, mgmt notices that the file has
diverged from its desired state, and it reacts immediately to bring the
resource to the desired state. We will see more examples of this further in the
guide, including a case where the desired state itself changes!

## Resource Syntax

Resource definition syntax in _mcl_ looks like this. This schematic uses
placeholder resource kinds and parameters, so it is not intended to be run:

```puppet
# This is a comment.

# Define a single resource.
kind "name" {
	# All params must end with a comma.
	param1 => "value1",

	# Including the final param.
	param2 => "value2",
}

# Define multiple resources of the same kind with the same params:
kind ["name1", "name2", "name3"] {
	param1 => "value1",
}

# Did you know? Mgmt has some internal resources like
# a web server and it can serve files over HTTP? :)
http:server "127.0.0.1:8080" { }
```

**What's in a name?** Many resources use the *name* as a default value for a
param. The file resource uses name as the default value for the `path` param.
Check out the [resource reference](/docs/resources/) for details on how each
resource may use the _name_.

**Syntax caution:** In a resource, every param must have a trailing comma,
including the last one.

The example above can also be written with a different name and setting the path
explicitly:

```puppet
file "a greeting" {
	path => "/tmp/hello.txt",
	state => "exists",
	content => "Greetings from mgmt!",
}
```

Mgmt has many kinds of resources, such as:

* [pkg](/docs/resources/#pkg) for packages.
* [exec](/docs/resources/#exec) for running other programs.
* [svc](/docs/resources/#svc) for managing services.

Check out [the resources reference for more](/docs/resources/).

Can resources be remote or only local? Mgmt resources do not have a concept of
local or remote. While `file` and `pkg` execute locally on a machine, some
resources will involve remote services, such as an `aws:ec2` instance resource.
You can even export resource definitions from one mgmt to be executed by mgmt on
another machine.

## More Familiar Resources

Mgmt supports a wide variety of resources. For your first day, we'll keep
focusing on familiar and common resources, such as packages and services.

### Packages

Let's dive into the [pkg](/docs/resources/#pkg) resource for managing system
packages with an example that ensures two packages are installed:

```puppet
# Ensure two different packages are installed.
pkg "screen" {
	state => "installed",
}

pkg "cowsay" {
	state => "installed",
}
```

_Note: Package management may require root privileges, so we can invoke mgmt
with `sudo` to run this example._

After saving the example as `first-package.mcl`, we run it:

```text
$ sudo mgmt run lang first-package.mcl
... (other output omitted for brevity) ...
19:00:19 engine: autogroup: pkg[cowsay] into pkg[screen]
19:00:19 engine: pkg[screen]: Check: pkg[autogroup:(screen,cowsay)]
19:00:19 engine: pkg[screen]: Apply: pkg[autogroup:(screen,cowsay)]
19:00:19 engine: pkg[screen]: Set(installed): pkg[autogroup:(screen,cowsay)]...
19:00:25 engine: pkg[screen]: Set(installed) success: pkg[autogroup:(screen,cowsay)]
```

This installed our packages, and mgmt did some extra optimization for us! In
this case, mgmt knows that multiple packages can be installed in a single step,
so it grouped both screen and cowsay together. **mgmt calls this autogrouping.**

You can test mgmt's reflexes by removing the `cowsay` package and watching mgmt
respond to this divergence by reinstalling it.

This example has one last important lesson! You may find yourself configuring
multiple resources of the same kind and all with the same _params_. In cases
like this, you can provide a list of names in the _name_ part of the resource
description:

```puppet
pkg ["screen", "cowsay"] {
	state => "installed",
}
```

Types of values like strings and lists will be covered in a later section.

### Services

To finish introducing resources, here is an example that instructs mgmt to
ensure the SSH service is running and enabled on boot.

```puppet
svc "sshd" {
	state => "running",
	startup => "enabled",
}
```

Running this (as root), we can see mgmt again acting swiftly as it notices that
sshd was not enabled at boot nor was it running:

```text
$ sudo mgmt run lang first-service.mcl
19:08:50 engine: svc[sshd]: service enabled
19:08:50 engine: svc[sshd]: service started
```

## Resource Relationships

We've seen that resources in _mcl_ instruct mgmt on what to observe and
what the desired state is for each resource. In practice, your desired state may
include hundreds or thousands of resources, and it's very likely that one
resource depends on another, such as a service depending on a package that
provides necessary systemd unit files.

A common example manages a service with three resources executed in exactly
this order: install a package, change the configuration file, and ensure the
service is running. Additionally, if the service configuration changes, you
want to notify the service of that change, right?

In mgmt, resources without ordering relationships can execute concurrently.
This allows mgmt to resolve as much as possible in the shortest amount of time.
There is no order unless you define one, and in the absence of order, we might
see mgmt attempt to converge a `svc` before its `pkg`. Here's a real example
that installs the nginx package and starts the nginx system service:

```puppet
svc "nginx" {
	state => "running",
	startup => "enabled",
}

pkg "nginx" {
	state => "installed",
}
```

Without expressing any order, mgmt will execute all resources simultaneously,
and the result will sometimes apply the `svc` before the `pkg` (which provides
the service files) is installed!

```text
17:48:52 engine: svc[nginx]: Error: failed to find svc: nginx.service
17:48:52 engine: pkg[nginx]: Apply: pkg[nginx]
17:48:52 engine: pkg[nginx]: Set(installed): pkg[nginx]...
17:49:01 engine: pkg[nginx]: Set(installed) success: pkg[nginx]
```

You can impose order on resources by defining relationships. Relationships can
be expressed in two ways, shown below. Both ways are equivalent. Use whichever
is most convenient for you.

For the examples below, we will consider two resources and their relationship:
an SSH package and an SSH service. The OS-provided package for SSH includes a
systemd service, which means there's no service to start until the package is
installed. Therefore, we need to establish an order. We can imagine them
visually:

![A diagram showing two boxes with an arrow between them. Each box represents
one resource. A box 'pkg openssh-server' has an arrow from it pointing to the
second box 'svc sshd'](relationship-pkg-svc.svg)

### Relationships using the arrow `->` operator

The following mcl implements the above description:

```puppet
pkg "openssh-server" {
	state => "installed",
}

svc "sshd" {
	state => "running",
	startup => "enabled",
}

# Tell mgmt that the package needs
# to execute before the service.
Pkg["openssh-server"] -> Svc["sshd"]
```

_Note: These examples use Fedora Linux. Other Linux distributions may use
different package and service names._

The syntax for arrow (`->`) relationships is:

`Kind["name"] -> Kind2["name2"]`

The _kind_ is a capitalized version of the resource name, and the `"string"`
inside the `[brackets]` is the resource's name.

### Relationship Params: Depend and Before

If it is more convenient, you may express a relationship inside any resource
definition using the params `Before` or `Depend` (capitalization is important).
To express "openssh-server package must be executed before its service" we can
use either of these:

```puppet
pkg "openssh-server" {
	state => "installed",

	Before => Svc["sshd"],
}
```

Alternatively:

```puppet
svc "sshd" {
	state => "running",
	startup => "enabled",

	Depend => Pkg["openssh-server"],
}
```

Each relationship requires only one definition. That is, you can use an arrow,
one `Before`, or one `Depend` for a single relationship.

### Relationship Params: Listen and Notify

Some relationships need more than just an order.

One example is a pair of resources: a `file` and a `svc`. You will want
mgmt to apply a file before applying a service change, and you also want the
service to be _notified_ any time that file changes. That is, whenever the
service's configuration files change, tell the service about it.

This _notification_ relationship is expressed with either `Notify` or `Listen`
params. When you want to notify a resource, you'll use `Notify` instead of
`Before`, and `Listen` instead of `Depend`.

A resource responds to a _notification_ by **refreshing**. Exactly what a
_refresh_ does depends on the resource. For services, a _refresh_ causes the
service to reload if possible and restart otherwise.

Here's what that looks like in mgmt, building on our previous nginx service and
package example:

```puppet
svc "nginx" {
	state => "running",
	startup => "enabled",
}

file "/etc/nginx/nginx.conf" {
	content => "# this is my nginx config",

	Notify => Svc["nginx"],
	Depend => Pkg["nginx"],
}

pkg "nginx" {
	state => "installed",
}
```

The example above ensures that the package is applied before the config file and
the file before the `svc`. Further, if mgmt changes the file contents in the
future, it notifies the `svc`, which causes nginx to reload or restart.

### Relationship Rejected: Cycles

All relationships have a direction, as in "A before B" or "B after A".

Mgmt will not allow relationships to create a loop, such as A before B, B before
C, and C before A. A relationship loop is called a "cycle", and mgmt reports an
error. Here's a simple example of a cycle:

```puppet
file "/tmp/hello.txt" {}
file "/tmp/world.txt" {}

File["/tmp/hello.txt"] -> File["/tmp/world.txt"]
File["/tmp/world.txt"] -> File["/tmp/hello.txt"]
```

Visually, we can imagine it with two arrows (edges) in each direction between
two resources:

![A diagram showing two boxes with two arrows between, each going a different
direction. Each box represents one
resource](relationship-cycle-example.svg
"two resources with a dependency cycle")

Because both files want to be "before" each other, we have a loop with no
beginning or end, and mgmt will report this error:

```text
16:53:02 gapi exited with error: not a dag
resource graph has cycles
```

### Not a DAG? Does the graph have cycles?

The visuals above are small examples of a structure called a graph, which is how
mgmt represents and executes your infrastructure. Broadly, a graph is a network
of objects. An object is usually called a vertex, while links or relationships
between objects are called edges. Graphs are a
[well-studied structure](https://en.wikipedia.org/wiki/Graph_theory) with a body
of research that provides mgmt with a nice selection of efficient algorithms.

Here's how these graph terms map to what we've learned about mgmt:

* Vertex: A resource, like a file or pkg.
* Edge: A relationship between two resources.
* Direction: The arrow `->` operator and `Before`/`Depend` params.

![the mgmt logo consisting of several blue circles with arrows linking several
of them](/images/logo_default_symbol.svg "the mgmt logo")
{style="width:150px;float:right;border:1px solid #bcc;border-radius:20px" .p-2}

A special kind of graph called a DAG is used inside mgmt. A DAG, or directed
acyclic graph, is a graph where all edges have a single direction and where
edges are not allowed to form a loop, also called a cycle.

You have already seen a DAG before in mgmt's logo :)

## Programming in mgmt

This section introduces built-in functions, variables, and conditionals. We will
use those features to program mgmt to handle differences between Linux
distributions.

So far, we've been describing a single desired state. In essence, the resource
graph has been static, or unchanging, throughout mgmt's life and remains the
same no matter where it runs. Let's do more!

_mcl_ allows decision-making that changes the resource graph. An earlier example
hinted at the need for this: "other Linux distributions may use different names"
for packages and services.

For our SSH service, Fedora calls it `sshd`, and Debian calls it `ssh`.

To solve our problem, we will import and use a built-in function,
[`os.release`](/docs/functions/#os.release), to determine our Linux distribution
and use that information to decide which service name to use.

```puppet
# Tell mgmt to let us use `os` functions.
import "os"

# Store the os release information in the $release variable.
# This information is a "struct" type that has an "id" field.
# The "id" field is a string containing an OS identifier.
$release = os.release()

if $release->id == "fedora" {
	# Fedora calls this service "sshd".
	svc "sshd" {
		state => "running",
		startup => "enabled",
	}
}

# We can handle both Debian and Ubuntu together.
if $release->id == "debian" or $release->id == "ubuntu" {
	# Debian calls this service "ssh".
	svc "ssh" {
		state => "running",
		startup => "enabled",
	}
}
```

Our _mcl_ above will produce a different resource graph depending on what
machine it runs on.

### Variables

We used the variable `$release` to store the result of the `os.release()`
function. Variable bindings are *immutable*, meaning they may only be assigned
once, and they are *block scoped*. A bound expression can still produce new
values over time. Here are some examples that use variables:

* In a bind statement, also known as an assignment: `$name = "James"`.
* In a resource name: `user [$name] { ... }`.
* In a resource param:

	```puppet
	file "/var/cache/james" {
		owner => $name,
	}
	```

* In a string: `"Hello, ${name}"`.
* In a format function: `fmt.printf("Hello, %s", $name)`.

**Syntax caution:** When using a variable for a resource name, we recommend
using a list of strings, as in either of the following:

```puppet
# Bind a variable to a string value.
$ssh_service = "ssh"
# Use a list containing that variable.
svc [$ssh_service] {
	state => "running",
}
```

Alternatively:

```puppet
# Bind a variable to a list of strings.
$ssh_service = ["ssh"]
# Use that variable as the list of resource names.
svc $ssh_service {
	state => "running",
}
```

mcl is a strongly typed language, and it rejects attempts to use a value of the
wrong type. A resource has a string name, while a resource declaration can also
accept a list of strings to create multiple resources. For convenience, a
single string is accepted when the compiler can determine its value statically.
An explanation of this follows further down in this document.

#### Formatting Text with Variables

_mcl_ is a strongly-typed language. All values have a type, and parameters are
typed. You may find that if you assign a number to a variable, it can't be used
where mgmt expects a string. In these cases, you'll want to use the `fmt.printf`
function to format the number in a string:

```puppet
import "fmt"
$port = 8000

file "/etc/nginx/nginx.conf" {
	state => "exists",
	content => fmt.printf("server {\n listen %d;\n}", $port),
}
```

We needed `fmt.printf()` here because `$port` is a number and cannot be used
_as_ a string. For example, trying to use `${port}` inside the content string
causes mgmt to report a type error:
`content => "server {\n listen ${port};\n}"`.

```text
17:44:59 error: cli parse error: could not unify types: type error: str != int
```

Only string values are allowed in `"${variable}"` string interpolation, and
`$port` above is a number. Resource and function params accept specific types.
The documentation for each resource and function describes the required type
for each param.

#### Scope of Variables

Variables are block scoped, meaning they are not accessible outside the block
where they are bound, or assigned. A block is the code between `{` and `}`. Mgmt
reports an error if a variable doesn't exist.

```puppet
import "os"

$release = os.release()
if $release->id == "fedora" {
	$ssh_service = "sshd"
}
if $release->id == "debian" {
	$ssh_service = "ssh"
}

# This will be an error:
# '$ssh_service' variable does not exist in this scope
svc $ssh_service {
	state => "running",
	startup => "enabled",
}
```

Mgmt will report that the variable doesn't exist:

```text
17:54:57 cli: lang: ast: var `$ssh_service` does not exist in this scope: variable-scope-error.mcl @ 13:5-13:17

svc $ssh_service {
	^^^^^^^^^^^^
```

With a small change, we can fix the above example. In _mcl_, an `if` can also be
an expression, and expressions can be assigned to variables:

```puppet
import "os"
$release = os.release()

$ssh_service = if $release->id == "fedora" {
	"sshd"
} else {
	# Assume all other distributions call it "ssh".
	"ssh"
}

svc [$ssh_service] {
	state => "running",
	startup => "enabled",
}
```

Previously, you learned that resource definitions can accept a list of names or,
for convenience, a single string literal. In the above example, we used an `if`
expression to store a string in the `$ssh_service` variable, and because the
_name_ parameter accepts a list of strings, we need to provide a list:
`[$ssh_service]`.

Before we move on, you might wonder, what happens if we use the wrong type?
Let's try that. If we forget the brackets for the resource name and use:

```puppet
svc $ssh_service {}
```

Mgmt reports the following because the single-string shorthand requires a value
that can be determined statically. The value of `$ssh_service` is computed by
the `if` expression, so this form expects a list instead:

```text
18:40:06 cli: lang: unification: type error: str != list: variable-scope-if-expression.mcl @ 12:1-15:2

svc $ssh_service {
^ from here ...
}
^ ... to here
```

This is mgmt explaining that we provided a `str` where a `list` was required.

For system operators, strongly typed languages offer a significant benefit by
moving small errors into the compilation phase rather than encountering them at
runtime, potentially in production. Another way to think of this is that mgmt
rejects all the code when there's a type error. Mgmt rejected our mcl because we
used the wrong value type, and this happens before the mcl is executed!

### Functions

Functions are a way to perform computation and also a way to observe parts of
your system without making changes. If you've done programming in other
languages, mgmt functions may surprise you! In mgmt, functions may produce many
results over time. Think of them more like a stream of data rather than a
one-time computation.

The simplest example is time: mgmt's `datetime` functions observe the clock and
report the time. Ever marching forward, time functions will produce new values
as the clock changes. Let's try a small example using the _print_ resource to
have mgmt log a message with the current time:

```puppet
import "fmt"
import "datetime"

$now = datetime.now()

print "time check" {
	msg => fmt.printf("the current time is %s", datetime.format($now, "2006-01-02 15:04:05")),
}
```

This is the first example where mgmt truly begins to shine and you can see the
"reactive" part of mgmt for yourself:

The variable `$now` is bound to the result of the `datetime.now()` function,
which periodically provides new values. The binding does not change, but its
reactive value does. A new function result causes a chain reaction: a new
`datetime.now()` result transitively changes the `msg` setting for our `print`
resource.

* `$now` receives a new value when `datetime.now()` updates, every second in our
	example.
* That causes the `datetime.format()` result to be re-evaluated with the new
	`$now` value.
* That causes `fmt.printf()` to be re-evaluated.
* That causes the `Print["time check"]` resource to have its `msg` param
	re-evaluated.
* When the `msg` param changes, mgmt prints a new message from this resource.

Try this example yourself using a `file` resource instead of a `print` resource!

```puppet
file "/tmp/clock.txt" {
	state => "exists",
	content => fmt.printf("the current time is %s\n", datetime.format($now, "2006-01-02 15:04:05")),
}
```

## A Complete Demonstration

While the previous example demonstrates how information flows through mgmt's
graph, it isn't exactly a realistic use case. It is unlikely that you will need
a function to change a resource every second, so let's use a more practical
example of applying a desired state with functional reactive programming.

### The Story

The story: You are a kind and collaborative systems operator who would like
users to be able to choose their own shell without needing to file a ticket or
ask for help. To solve this, you would like users to be able to set their own
shells and ensure those shells are available. After talking to your users, you
learn that the users who want a different shell also maintain their own shell
configuration files.

The idea: What if a machine automatically configures a user's shell based on the
presence of the shell's config file? It would be useful if this change were
applied as soon as a user creates their shell config file.

In mgmt, we can do this, and this guide has prepared us for this challenge! What
tools do we need?

We need to:

* Observe: Detect a file's presence in a user's home directory.
* Change: Configure the user's login shell on the machine.
* Change: Ensure the shell package is installed.

Recall that an mgmt resource can apply changes, while functions only observe or
compute and cannot make changes. This means we'll want a function for the file
observation and resources for managing the user and package.

### The Implementation

We can implement our solution completely in mcl and run it with mgmt:

```puppet
# Make the os.file_exists() function available.
import "os"

$home = "/home"
$user = "dev"

# If this user creates a ~/.zshrc, set their shell to zsh.
$shell = if os.file_exists("${home}/${user}/.zshrc") {
	"zsh"
} else {
	"bash"
}

user [$user] {
	state => "exists",
	homedir => "${home}/${user}/",

	# The user's shell now depends on the value of $shell
	# which depends on the presence of a .zshrc file.
	shell => "/bin/${shell}",
}

# Ensure the user's shell is installed.
# This assumes the shell executable is the same as the package name.
pkg [$shell] {
	state => "installed",

	# Ensure the package is applied
	# before we try to modify the user's shell.
	Before => User[$user],
}
```

This example demonstrates two very powerful capabilities of mgmt:

1. Your desired state is dynamic and computed, not static! The actual resource
	graph will be different depending on the presence of that `.zshrc` file. More
	specifically, the user's shell and package installation depend on the value of
	`$shell`, which is based on the presence or absence of a `.zshrc` file in the
	user's home directory.

2. Because mgmt is a reactive programming system, the `os.file_exists()`
	function watches for changes and produces a new value when the file is created
	or deleted. This new value causes mgmt to recompute the desired state!

### The Result

Here's what happens when we run this:

#### First, no changes are needed

For this walkthrough, assume that the `dev` user already exists with a home
directory, uses bash, and has no `.zshrc`. If the user does not exist, the first
convergence creates it and your initial output will differ. With these
prerequisites in place, mgmt computes our desired state, observes that the
current state matches it, and doesn't make any changes.

#### Second, create a `.zshrc`

If this user creates a `.zshrc` file, for example by running
`sudo -u dev touch /home/dev/.zshrc`, mgmt springs into action! Our
`os.file_exists()` function produces a new value, and mgmt computes and applies
a new graph for the new desired state:

```text
16:16:40 gapi: generating new graph...

... (other output omitted for brevity) ...

16:16:40 engine: pkg[zsh]: Check: pkg[zsh]
16:16:40 engine: pkg[zsh]: Apply: pkg[zsh]
16:16:40 engine: pkg[zsh]: Set(installed): pkg[zsh]...
16:16:47 engine: pkg[zsh]: Set(installed) success: pkg[zsh]
16:16:47 engine: pkg[zsh]: Check: pkg[zsh]
16:16:47 engine: user[dev]: modifying user: dev
```

And the user's shell is now zsh:

```bash-session
$ getent passwd dev | awk -F: '{print $NF}'
/bin/zsh
```

#### Third, remove the `.zshrc`

If the user deletes their `.zshrc` with
`sudo -u dev rm /home/dev/.zshrc`, mgmt should set the shell back to bash:

```text
16:40:42 gapi: generating new graph...
...
16:40:44 engine: pkg[bash]: Check: pkg[bash]
16:40:44 engine: user[dev]: modifying user: dev
```

And we can check that bash is now the user's shell:

```text
$ getent passwd dev | awk -F: '{print $NF}'
/bin/bash
```

## Further Reading

Congratulations! You should now be able to apply these lessons when using mgmt
on your own systems. This guide is only the beginning. There are capabilities
and details beyond the scope of this document that you will find useful as your
mgmt expertise grows:

* Reusable code with [classes](/docs/guide/classes/) and modules.
* Sending values from one resource to another.
* Cooperation between many mgmt instances, including exporting resources,
	passing values around, and [deploying mcl to a fleet](/docs/guide/deploys/).
* Internal mgmt resources to handle [DHCP requests](/docs/resources/#dhcpserver)
	or serve content over [HTTP](/docs/resources/#httpserver) and
	[TFTP](/docs/resources/#tftpserver).
* More detail on programming in mgmt:
	* [mcl language syntax and features](/docs/guide/language-features/)
	* [values and types in mcl](/docs/guide/values-and-types/), including
		writing functions in mcl.
