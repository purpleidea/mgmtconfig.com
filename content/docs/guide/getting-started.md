---
title: "Getting Started"
---

# Download and installation 

* Download the latest version from: https://github.com/purpleidea/mgmt/releases/
* Installation requires a modern x86_64 (amd64) Linux distro. Aarch64 (arm64) is available but unsupported at this time.
* After downloading the binary, give it executable permissions (`chmod +x`) and either run it from there or move it to a directory contained in your $PATH and execute as with any other software.

# Running `mgmt`

Put the following into a `hello0.mcl` file:

```
file "/tmp/mgmt-hello-world" {
	content => "hello world from @purpleidea\n",
	state => $const.res.file.state.exists,
}
```

Run: `mgmt run --tmp-prefix lang hello0.mcl` to try out this simple example!

# Playing with `mgmt`

While `mgmt` is running, you can test out one of its cool side effects: Run
`rm /tmp/mgmt-hello-world` in a second terminal, and watch the file come back!
You can type `^C` to shutdown `mgmt`.
