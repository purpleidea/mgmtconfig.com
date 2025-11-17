---
title: "Getting Started"
---

# Download and installation 

* Installation requires a modern x86_64 (amd64)[^1] Linux distro.
* You'll need to install dependencies for augeas, libvirt, and PackageKit first.
	* On Fedora: `sudo dnf install libvirt-devel augeas-devel PackageKit`
	* On Debian: `sudo apt install libvirt-dev libaugeas-dev packagekit`
* Download the latest version from: https://github.com/purpleidea/mgmt/releases/
* After downloading the binary, give it executable permissions (`chmod +x`) and
either run it from there or move it to a directory contained in your $PATH and
execute as with any other software.
* Alternatively, you can install the `mgmt` package from the appropriate
[rolling release repository](https://dl.fedoraproject.org/pub/alt/purpleidea/mgmt/repo/master/).

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

[^1]: Please [contact us](/contact/) if you are a customer interested in aarch64
(arm64) builds.
