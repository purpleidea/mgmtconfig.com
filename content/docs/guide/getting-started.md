---
title: "Getting Started"
---

# Download and installation

- Download the latest version from: https://github.com/purpleidea/mgmt/releases/
- Installation requires a modern x86_64 (amd64) Linux distro. Aarch64 (arm64) is
  available but unsupported at this time.
- After downloading the binary, give it executable permissions (`chmod +x`) and
  either run it from there or move it to a directory contained in your $PATH and
  execute as with any other software.

# Running `mgmt`

This demo showcases mgmt's **real-time** configuration management. Unlike
traditional tools that run periodically, mgmt continuously monitors and
maintains your desired state instantly when changes occur.

We are going to use mgmt to create and manage a simple file in the `/tmp`
directory to display the reaction time of mgmt.

To do this using mgmt put the following into a hello0.mcl file:

```
file "/tmp/mgmt-hello-world" {
	content => "hello world from @purpleidea\n",
	state => $const.res.file.state.exists,
}
```

Run: `mgmt run --tmp-prefix lang hello0.mcl` to try out this simple example!

Let's break down the file you just created: - `file "/tmp/mgmt-hello-world"` -
declares a file resource at the specified path - `content =>` - sets the file's
contents - `state => $const.res.file.state.exists` - ensures the file exists
(this will be further explained at.... link to guide/link to docs)

> **Note: what is .mcl?**  
> `.mcl` files contain mgmt's configuration language code. MCL (mgmt
> Configuration Language) is mgmt's domain-specific language for declaring
> desired system states.

# Playing with `mgmt`

While `mgmt` is running, you can test out one of its cool side effects: Run
`rm /tmp/mgmt-hello-world` in a second terminal, and watch the file come back!
You can type `^C` to shutdown `mgmt`.

While mgmt is running, you can test out one of its cool side effects: Run rm
/tmp/mgmt-hello-world in a second terminal, and watch the file come back! (Note
how fast this is done) You can type ^C to shutdown mgmt.

> **Why is `mgmt` different?** This demo showcases mgmt's **real-time**
> configuration management. Unlike traditional tools that run periodically, mgmt
> continuously monitors and maintains your desired state instantly when changes
> occur.
