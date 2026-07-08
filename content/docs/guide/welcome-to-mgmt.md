
<!--

Greetings, documentation contributors!

📚 Design of this document:

- A gradual introduction with each section building on the previous.
- Using real examples demonstrating what was just covered.
- And avoiding jargon, such as “DAG”, until absolutely necessary. 

As an example, [Elm](https://guide.elm-lang.org) does a fantastic job of explaining how to use a functional programming language *without* burdening the reader in high-level mathematical terms that are unavoidable in language docs like Haskell. 

It’s OK to refer to these technical terms, “in mgmt, this is called x” after the behavior or concepts have been explained.

Example mcl code should be indented with tabs. To check this, you can try this command to print lines that might need to use tabs for indentation:

  awk '/^\s*```puppet/ { mcl=1; next } /^\s*```\s*$/ { mcl=0 } mcl == 1 && /^[ ]+[A-Za-z0-9#]/ { print NR, $0 }' welcome-to-mgmt.md

-->

# Welcome to mgmt config

This guide is designed to teach you the concepts and syntax necessary to find success with mgmt on your first day. Towards this goal, each section of this guide introduces both concepts and related syntax that builds upon the previous sections. Therefore, we recommend that you follow this guide start to finish. Finally, the examples used in this guide are intended to be run by you, so ensure you have [mgmt installed](../getting-started/).

Examples in this document were tested on Fedora 44, so for best results, we recommend having a fresh install of Fedora available to you. It is OK if you do not have this, though, and most of the examples should still useful.

# Table of Contents 

{{< toc >}}


## Configuration with Resources

Configuration is described with an element called a **resource**.
Most kinds of resources in mgmt will be familiar to you and are intended to align with your mental model of your infrastructure - for example, ensuring that a package is installed, a service is disabled, or a user exists.

Resources have three parts: a kind, a name, and parameters (mgmt calls these **params**). The following example code shows a single file _resource_ written in mgmt's programming language, _mcl_:

```puppet { .m-2 }

file "/tmp/hello.txt" {
	content => "Greetings from mgmt!\n",
	state => "exists",
}
```

This is a file resource with a name “/tmp/hello.txt” and describes a state where you want the file to exist and contain exactly: 

```text {.m-2}
Greetings from mgmt!
```

With this programming model, you express the desired state for each resource, and mgmt makes it real by observing the current state and making any necessary changes. The language, _mcl_, is a strongly-typed, reactive, functional language, and if those terms are unfamiliar to you, do not worry! Each of those terms (reactive, etc) will be discussed further in this guide.

### Running mgmt

Our _mcl_ code can be executed in mgmt. First, place the sample code above in a file named "hello.mcl", then run `mgmt run lang hello.mcl`. Mgmt will normally write its logs to stdout, so the execution of our file resource will appear like this:

```text { .m-2 }
$ mgmt run lang hello.mcl

... ( other output omitted for brevity ) ...

10:28:48 engine: file[/tmp/hello.txt]: copy 21 bytes
```

When you run this, notice the following:
* mgmt did not exit after converging (more on this in the next section)
* mgmt can run as any user, but that user will correct permissions in order to execute some resources.
* The first part '10:28:48' is a timestamp, and your timestamps will be different.

When all resources are in the desired state, mgmt calls this outcome **converged**.

Let's verify that our file was created correctly, and run the following in another terminal to view the contents of our file:

```text { .m-2 }
$ cat /tmp/hello.txt
Greetings from mgmt!
```

### Continuous Convergence

In the example above, mgmt stayed running even after converging. This is because mgmt continuously watches for changes (aka divergence) and will **react** immediately and as needed.

Let's explore that! While mgmt is still running, we can modify the file in another terminal and observe mgmt's immediate responses:

```bash-session { .m-2 }
# Remove the file
$ rm /tmp/hello.txt

# mgmt notices and responds:
10:36:34 engine: file[/tmp/hello.txt]: copy 21 bytes

# Change the file's contents
$ echo "mgmt is fast" > /tmp/hello.txt

# mgmt notices and responds:
10:37:18 engine: file[/tmp/hello.txt]: copy 21 bytes
```

You can terminate mgmt in your terminal by pressing ctrl+c.

Each time we removed or modified the file, mgmt notices that the file has diverged from its desired state, and it reacts immediately to bring the resources to the desired state. We will see more examples of this further in the guide, including a case where the desired state itself changes!

## Resource Syntax

Resource definition syntax in _mcl_ looks like this:

```puppet { .m-2 }
# This is a comment

# Define a single resource
kind "name" {
	# All params must end with a comma
	param1 => "value1",
	
	# Including the final param
	param2 => "value2",
}

# Define multiple resources of the same kind 
# with the same params:
kind ["name1", "name2", "name3"] {
	param1 => "value1",
}

# Did you know? mgmt has some internal resources 
# like a web server and it can serve files over http? :)
http:server "127.0.0.1:8080" { }
```

💡 _What’s in a name?_  Many resources use the *name* as a default value for a param. The file resource uses name as the default value for the `path` param. Check out the [resource reference](../../resources/) for details on how each resource may use the _name_.

⚠️Syntax Caution: In a resource, every param must have a trailing comma, including the last one.

The example above can also be written with a different name and setting the path explicitly:

```puppet { .m-2 }
file "a greeting" {
	content => "Greetings from mgmt!",
	path => "/tmp/hello.txt",
	state => "exists",
}
```

mgmt has many kinds of resources, such as 
[pkg](/docs/resources/#pkg) for packages, 
[exec](/docs/resources/#exec) for running other programs, 
[svc](/docs/resources/#svc) for managing service. Check out [the resources reference for more](/docs/resources/).

Can resources be remote or only local? mgmt resources do not have a concept of local or remote. While _file_ and _pkg_ will execute locally on a machine, some resources will involve remote services, such as an ec2 instance resource. You can even export resource definitions from one mgmt to be executed by mgmt on another machine.

## More Familiar Resources

mgmt supports a wide variety of resources. For your first day, we'll keep focusing on familiar and common resources, such as packages and services.

### Packages

Let's dive into the [pkg](/docs/resources/#pkg) resource for managing system packages with an example that ensures two packages are installed:

```puppet { .m-2 }
# Ensure two different packages are installed
pkg "tmux" {
	state => "installed",
}

pkg "cowsay" {
	state => "installed",
}
```

_Note: Package management may require root, so we can invoke mgmt with sudo to run this example._

After writing the above example file "first-package.mcl", we run it:

```text { .m-2 }
$ sudo mgmt run lang first-package.mcl
... ( other output omitted for brevity ) ...
19:00:19 engine: autogroup: pkg[cowsay] into pkg[tmux]
19:00:19 engine: pkg[tmux]: Check: pkg[autogroup:(tmux,cowsay)]
19:00:19 engine: pkg[tmux]: Apply: pkg[autogroup:(tmux,cowsay)]
19:00:19 engine: pkg[tmux]: Set(installed): pkg[autogroup:(tmux,cowsay)]...
19:00:25 engine: pkg[tmux]: Set(installed) success: pkg[autogroup:(tmux,cowsay)]
```

This installed our packages, and mgmt did some extra optimization for us! In this case, mgmt knows that multiple packages can be installed in a single step, so it grouped both tmux and cowsay together. **mgmt calls this autogrouping**

You can test mgmt's reflexes by removing the `cowsay` package and watching mgmt respond to this divergence by reinstalling it.

This example has one last important lesson! You may find yourself configuring multiple resources of the same kind and all with the same _params_. In cases like this, you can provide a list of names in the _name_ part of the resource description:

```puppet { .m-2 }
pkg ["tmux", "cowsay"] {
	state => "installed",
}
```

Types of values like strings and lists will be covered in a later section.

### Services

To finish introducing resources, here is an example that instructs mgmt to ensure the sshd service is running and also enabled on boot.

```puppet { .m-2 }
svc "sshd" {
	startup => "enabled",
	state => "running",
}
```

Running this (as root), we can see mgmt again acting swiftly as it notices that sshd was not enabled at boot nor was it running:

```text { .m-2 }
$ sudo mgmt run lang first-service.mcl
19:08:50 engine: svc[sshd]: service enabled
19:08:50 engine: svc[sshd]: service started
```

## Resource Relationships

We've seen that resources in _mcl_ will instruct mgmt on what to observe and what the desired state is for each resource. In practice, your desired state may include hundreds or thousands of resources, and it's very likely that one resource depends on another, such as a service depending on a package that provides necessary systemd unit files.

A common example manages a service with three resources executed in exactly this order: install a package, change the configuration file, and ensuring the service is running! Additionally, if the service configuration changes, you want to notify the service of that change, right?

In mgmt, **all resources are executed in concurrently**. This allows mgmt to resolve as much as possible in the shortest amount of time. There is no order unless you define order, and in the absence of order, we might see mgmt attempt to converge a _svc_ before its _pkg_. Here's a real example that installs the nginx package and starts the nginx system service:

```puppet {.m-2}
svc "nginx" {
  state => "running",
  startup => "enabled",
} 

pkg "nginx" {
  state => "installed",
}
```

Without expressing any order, mgmt will execute all resources simultaneously, and the result will sometimes apply the _svc_ before the _pkg_ (which provides the service files) is installed!

```text {.m-2}
17:48:52 engine: svc[nginx]: Error: failed to find svc: nginx.service
17:48:52 engine: pkg[nginx]: Apply: pkg[nginx]
17:48:52 engine: pkg[nginx]: Set(installed): pkg[nginx]...
17:49:01 engine: pkg[nginx]: Set(installed) success: pkg[nginx]
```


You can impose order on resources by defining relationships. Relationships can be expressed two different ways, shown below, Both ways are equivalent. Use whichever is most convenient for you.

For the examples below, we will consider two resources and their relationship: An sshd package and sshd service. The OS-provided package for sshd includes a systemd service, which means there's no service to start until the package is installed, so we need to establish an order. We can imagine them visually:

![A diagram showing two boxes with an arrow between them. Each box represents one resource. A box 'pkg openssh-server' has an arrow from it pointing to the second box 'svc sshd'](relationship-pkg-svc.svg)

### Relationships using arrow `->` operator

The following mcl implements the above description:

```puppet { .m-2 }
pkg "openssh-server" {
	state => "installed",
}

svc "sshd" {
	startup => "enabled",
	state => "running",
}

# Tell mgmt that the package needs to execute
# before the service
Pkg["openssh-server"] -> Svc["sshd"]
```

_Note: these examples use Fedora Linux. Other linux distros may use different names for their equivalent package and services._

The syntax for arrow (`->`) relationships is: 

`Kind["name"] -> Kind2["name2"]`

The _kind_ is a capitalized version of the resource name, and the `"string"` inside the `[brackets]` is the resource's name. 

### Relationship Params: Depend and Before

If it is more convenient, you may express a relationship inside any resource definition using the params `Before` or `Depend` (capitalization is important). To express "openssh-server package must be executed before its service" we can use either of these:

```puppet { .m-2 }
pkg "openssh-server" {
	state => "installed",
	Before => Svc["sshd"],
}
```

Alternately:

```puppet { .m-2 }
svc "sshd" {
	startup => "enabled",
	state => "running",
	Depend => Pkg["openssh-server"],
}
```

Each relationship requires only one definition. That is, you can use an arrow, or one _Before_, or one _Depend_, for a single relationship.

### Relationship Params: Listen and Notify

Some relationships need more than just an order. 

One example is with a pair of resources: a _file_ and a _svc_. You will want mgmt to apply a file before applying a service change, and you also want the service to be _notified_ any time that file changes, that is, whenever the service's configuration file(s) change, tell the service about it.

This _notification_ relationship is expressed with either `Notify` and `Listen` params. When you want to notify a resource, you'll use `Notify` instead of `Before`, and `Listen` instead of `Depend`. 

A resource responds to a _notification_ by **refreshing**. What exactly a _refresh_ does will depend on the resource, and for services, a _refresh_ causes the service to reload its configuration file.

Here's what that looks like in mgmt, building on our previous nginx service and package example:

```puppet {.m-2}
svc "nginx" {
  state => "running",
  startup => "enabled",
} 

file "/etc/nginx/nginx.conf" {
  content => "# this is my nginx config",
  Depend => Pkg["nginx"]
  Notify => Svc["nginx"],
}

pkg "nginx" {
  state => "installed",
}
```

The example above will ensure that the package is applied before the config file and the file before the svc. Further, if mgmt changes the file contents in the future, it will notify the svc which will cause nginx to reload its config file.


### Relationship Rejected: Cycles

All relationships have a direction, as in "A before B" or "B after A". 

Mgmt will not allow a relationship to create a loop, such as (A before B, B before C, C before A). A relationship loop is called a "cycle", and mgmt will report an error. Here's a simple example of a cycle:

```puppet { .m-2 }
file "/tmp/hello.txt" { }
file "/tmp/world.txt" { }

File["/tmp/hello.txt"] -> File["/tmp/world.txt"]
File["/tmp/world.txt"] -> File["/tmp/hello.txt"]
```

Visually, we can imagine it with two arrows (edges) in each direction between two resources:

![A diagram showing two boxes with two arrows between, each going a different direction. Each box represents one resource](relationship-cycle-example.svg "two resources with a dependency cycle")

Because both files want to be "before" each other, we have a loop with no beginning or end, and mgmt will report this error:

```text { .m-2 }
16:53:02 gapi exited with error: not a dag
resource graph has cycles
```

### Not a dag? Graph has cycles?

The visuals above are small examples of a structure called a graph, and it is how mgmt represents and executes your infrastructure. A graph, broadly, is a network of objects, where an object is usually called a vertex and links or relationships between objects are called edges. Graphs are a [well-studied structure](https://en.wikipedia.org/wiki/Graph_theory) with a body of research that provides mgmt with a nice selection of efficient algorithms.

Here's how these graph terms map to what we've learned about mgmt:

* Vertex: A resource, like a file or pkg.
* Edge: A relationship between two resources.
* Direction: The arrow `->` operator and Before/Depend params

![the mgmt logo consisting of several blue circles with arrows linking several of them](../../../images/logo_default_symbol.svg "the mgmt logo")
{style="width: 150px; float: right; border: 1px solid #bcc; border-radius: 20px" .p-2}

A special kind of graph called a dag is used inside mgmt. A dag, or directed acyclic graph, is a graph where all edges have a single direction and where  edges are not allowed to form a loop, also called a cycle.


You have already seen a dag before in mgmt's logo :)

## Programming in mgmt

This section introduces built-in functions, variables, and conditionals. We will use those features to program mgmt to handle differences between Linux distributions.

So far, we've been describing a single desired state - in essence, the resource graph has been static, or unchanging, throughout mgmt's life and remains the same no matter where it runs. Let's do more!

_mcl_ allows decision-making that changes the resource graph. An example above even hinted at the need for this, "other linux distros may use different names" for packages and services.

For our ssh service, Fedora calls it "sshd", and Debian calls it "ssh".

To solve our problem, we will import and use a built-in function, [`os.release`](../../../docs/functions/#os.release), to determine our Linux distribution and use that information to decide which service name to use. 


```puppet { .m-2 }
# Tell mgmt to let us use 'os' functions
import "os"

# Store the os release information in the $release variable
# This information is a 'struct' type that has an "id" field
# The "id" field is a string containing an OS identifier
$release = os.release()

if $release->id == "fedora" {
	# Fedora calls this service "sshd"
	svc "sshd" {
		startup => "enabled",
		state => "running",
	}
} 

# We can handle both Debian and Ubuntu together
if $release->id == "debian" or $release->id == "ubuntu" {
	# Debian calls this service "ssh"
	svc "ssh" {
		startup => "enabled",
		state => "running",
	}
}
```

Our _mcl_ above will produce a different resource graph depending on what machine it runs on.

### Variables

We used the variable, `$release`, to store the result of `os.release()` function. Variables *immutable* meaning they may only be assigned once, and they are *block scoped*. Here are some examples that use variables:

* Bind statement, aka assignment: `$name = "James"`
* In a resource name: `user [$name] { ... }`
* In a resource param: 
  ```puppet { .m-2 }
  file "/var/cache/james" {
  	owner => $name,
  }
  ```
* In a string: `"Hello, ${name}"`
* In a format function: `fmt.printf("Hello, %s", $name)`

⚠️ Syntax Caution: When using a variable for a resource name, it is recommended to use list of strings, as in either of the following:


```puppet { .m-2 }
# Binding a variable to a string value
$ssh_service = "ssh"
# And using a list containing that variable
svc [$ssh_service] { ... }
```

Alternately,

```puppet { .m-2 }
# Binding a variable to a list of strings 
$ssh_service = ["ssh"]
# And using that variable (a list) as the resource names
svc $ssh_service { ... }
```

mcl is a strongly-typed language, and it will reject attempts to use a value of the wrong type, but there's a small exception added for convenience. A resource's _name_ is a list of strings, but a special case of a single string literal is allowed. An explanation of this follows further down in this document.

#### Formatting Text with Variables

_mcl_ is a strongly-typed language. All values have a type, and parameters are typed. You may find that if you assign a number to a variable, it can't be used where mgmt expects a string. In these cases, you'll want to use the `fmt.printf` function to format the number in a string:

```puppet { .m-2 }
import "fmt"
$port = 8000

file "/etc/nginx/nginx.conf" {
	state => "exists",
	content => fmt.printf("server {\n  listen %d;\n}", $port),
}
```

We needed `fmt.printf()` here because `$port` is a number and cannot be used _as_ a string. For example, if we set the content and try to use `${port}` in inside the content string, we'll get a type error - the following uses will cause mgmt to show an error - `content => "server {\n listen ${port};\n}"`

```text { .m-2 }
17:44:59 error: cli parse error: could not unify types: type error: str != int
```

Only string values are allowed in `"${variable}"` string interpolation, and `$port`, above, is a number. Most params, such as resource params, function params, etc, accept only a specific type. The documentation for each resource and function will tell you what types are required for each param.

#### Scope of Variables

Variables are block scoped, meaning they are not accessible outside of the block where they are bound (aka assigned). A block is the stuff between `{` and `}`. mgmt will write an error message if a variable doesn't exist.

```puppet { .m-2 }
import "os"

$release = os.release()
if $release->id == "fedora" {
	$ssh_service = "sshd"
if $release->id == "debian" {
	$ssh_service = "ssh"
}

# This will be an error: 
# '$ssh_service' variable does not exist in this scope
svc $ssh_service {
	startup => "enabled",
	state => "running",
}
```

mgmt will report that the variable doesn't exist:

```text { .m-2 }
17:54:57 cli: lang: ast: var `$ssh_service` does not exist in this scope: variable-scope-error.mcl @ 11:5-11:17

svc $ssh_service {
    ^^^^^^^^^^^^
```

With a small change, we can fix the above example. In _mcl_, an `if` can also be an expression, and expressions can be assigned to variables:

```puppet { .m-2 }
import "os"
$release = os.release()

$ssh_service = if $release->id == "fedora" {
	"sshd"
} else {
	# assume all other distros call it "ssh"
	"ssh"
}

svc [$ssh_service] {
	startup => "enabled",
	state => "running",
}
```

Previously, you learned that resource definitions can accept a list of names or, for convenience, a single string literal. In the above example, we used an `if` expression to store a string in the `$ssh_service` variable, and because the _name_ parameter accepts a list of strings, we need provide a list: `[$ssh_service]`.

Before we move on, you might wonder, what happens if we use the wrong type? Let's try that. If we forget the brackets for the resource name and use:

```puppet { .m-2 }
svc $ssh_service {
```

mgmt will report the following because it cannot statically determine that `$ssh_service` is a string:

```text {.m-2}
18:40:06 cli: lang: unification: type error: str != list: variable-scope-if-expression.mcl @ 12:1-15:2

svc $ssh_service {
^ from here ...
}
^ ... to here
```

This is mgmt explaining that we provided a _str_ where a _list_ was required.

For system operators, strongly-typed languages offer a significant benefit by moving small errors into the compilation phase instead of at runtime and in production. Another way to think of this is that mgmt rejects code, in full, when there's a type error. Mgmt rejected our mcl because we used the wrong value type, and this happens before the mcl is executed!

### Functions

Functions are a way to perform computation and also a way observe parts of your system without making changes. If you've done programming in other languages, mgmt functions may surprise you! In mgmt, functions may produce many results over time. Think of them more like a stream of data rather than a one-time computation.

The simplest example is time: mgmt's _datetime_ functions observe the clock and report the time. Ever marching forward, time functions will produce new values as the clock changes. Let's try a small example using the _print_ resource to have mgmt log a message with the current time:


```puppet { .m-2 }
import "fmt"
import "datetime"

$now = datetime.now()

print "time check" {
	msg => fmt.printf("The current time is %s", datetime.format($now, "2006-01-02 15:04:05")),
}
```

This is the first example where mgmt truly begins to shine and you can begin to see the "reactive" part of mgmt for yourself:

The variable `$now` stores the result of the `datetime.now()` function, and, periodically, this function provides new results. A new function result causes a chain reaction: A new `datetime.now()` result transitively changes the `msg` setting for our _print_ resource!

* `$now`'s value is updated when datetime.now() updates (every second, in our example)
* causing `datetime.format()` result to be re-evaluated with the new `$now` value
* causing `fmt.printf` to be re-evaluated
* causing our *Print\["time check"\]* resource have its `msg` param re-evaluated.
* when the `msg` param changes, mgmt prints a new message from this resource.

Try this example yourself using a _file_ resource instead of a _print_ resource!

```puppet { .m-2 }
file "/tmp/clock.txt" {
	msg => fmt.printf("The current time is %s\n", datetime.format($now, "2006-01-02 15:04:05")),
}
```

## A Complete Demonstration

While the previous example does demonstrate how information flows through mgmt's graph, it isn't exactly a realistic use case - it is unlikely that you will need a function changing a resource every second, so let's use a more practical and useful example that demonstrates mgmt's functional reactive programming to apply a desired state.

### The Story

The story: You are a kind and collaborative systems operator who would like to users to be able to choose their own shell without needing to file a ticket or ask for help. To solve this, you would like a user to be able to set their own shell and also  ensure that shell is actually available. After talking to your users, you learn that the users who want a different shell also maintain their own shell configuration files.

The idea: What if a machine automatically configures a user's shell based on the presence of a shell's config file? It would be nice if this change gets executed immediately upon a user creating their shell config file.

In mgmt, we can do this, and this guide has prepared us for this challenge! What tools do we need?

We need to:
* Observe: detect a file's presence in a user's home directory
* Change: configure the user's login shell on the machine
* Change: ensure the shell package is installed

Recall that an mgmt resource can apply changes and that functions only observe or compute and cannot make changes. This means we'll want a function for the file observation and a resources for managing the user and package.

### The Implementation

We can implement our solution completely in mcl and run it with mgmt:

```puppet { .m-2 }
# Make the os.file_exists() function available
import "os"

$home = "/home"
$user = "dev"

# If this user creates a ~/.zshrc, then
# go ahead and set their shell to zsh
$shell = if os.file_exists("${home}/${user}/.zshrc") {
	"zsh"
} else {
	"bash"
}

user [$user] {
	state => "exists",
	homedir => "${home}/${user}/",
	
	# The user's shell now depends on the value of $shell
	# which depends on the presence of a .zshrc file
	shell => "/bin/${shell}",
}

# Ensure the user's shell is installed
# This assumes the shell executable is the same as the package name.
pkg [$shell] {
	state => "installed",
	
	# Ensure the package is applied 
	# before we try to modify the user's shell.
	Before => User[$user],
}
```

This example demonstrates two very powerful capabilities of mgmt:

1. Your desired state is a dynamic and computed, not static! The actual resource graph will be different depending on the presence of that `.zshrc` file. More specifically, the user's shell and a package install depends on the value of `$shell` which itself is based on the presence (or not) of a `.zshrc` file in the user's home directory.

2. Because mgmt is a reactive programming system, the `os.file_exists()` function watches for changes and produces a new value when the file is created or deleted. This new value causes mgmt to recompute the desired state!

### The Result

Here's what happens when we run this:

#### First, nothing to change

At first, this user's home directory contains no `.zshrc` and the default shell is bash. Mgmt computes our desired state, observes that the current state matches our desired state, and doesn't make any changes because the user's shell should be bash and it already is.

#### Second, create a .zshrc

If this user create a .zshrc file, for example by running `touch ~/.zshrc`, mgmt springs into action! Our `os.file_exists()` function produces a new value, and mgmt computes, and applies, a new graph for the new desired state:

```text { .m-2 }
16:16:40 gapi: generating new graph...

... < logs cropped for brevity > ...

16:16:40 engine: pkg[zsh]: Check: pkg[zsh]
16:16:40 engine: pkg[zsh]: Apply: pkg[zsh]
16:16:40 engine: pkg[zsh]: Set(installed): pkg[zsh]...
16:16:47 engine: pkg[zsh]: Set(installed) success: pkg[zsh]
16:16:47 engine: pkg[zsh]: Check: pkg[zsh]
16:16:47 engine: user[dev]: modifying user: dev
```

And the user's shell is now zsh:

```bash-session { .m-2 }
$ getent passwd dev  | awk -F: '{print $NF}'
/bin/zsh
```

#### Third, remove the .zshrc

If the user deletes their .zshrc with `rm ~/.zshrc`, mgmt should set the shell back to bash:

```text { .m-2 }
16:40:42 gapi: generating new graph...
... 
16:40:44 engine: pkg[bash]: Check: pkg[bash]
16:40:44 engine: user[dev]: modifying user: dev
```

And we can check that bash is now the user's shell:

```text {.m-2}
$ getent passwd dev  | awk -F: '{print $NF}'
/bin/bash
```

## Further Reading

Congratulations! You should now be able to apply these lessons towards mgmt on your own systems. This guide's introduction is only your beginning. There are capabilities and details beyond the scope of this document that you will find useful as your mgmt expertise grows:

* Reusable code with [classes](../classes) and modules.
* Sending values from one resource to another.
* Cooperation between many mgmt instances, including exporting resources, passing values around, and [deploying mcl to a fleet](../deploys).
* Internal mgmt resources to handle [dhcp requests](../../resources/#dhcpserver) or serve content over [http](../../resources/#httpserver) and [tftp](../../resources/#tftpserver).
* More detail on programming in mgmt:
  * [mcl language syntax and features](../language-features/)
  * [values and types in mcl](../values-and-types/), including writing functions in mcl.
