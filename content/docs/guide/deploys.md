---
title: "Deploys"
---

You may wish to run `mgmt` on more than one machine. This is its strength. You
want the ability to model, build and manage clustered, distributed systems.
Anything that is single-machine is basically just a fancy `bash` script. That's
why we have `mcl`.

# Topology

There are many different topologies that are possible, including orchestrator
topologies where you only run over `ssh`. For most situations, you want the
recommended "distributed system" topology.

## Etcd

Start first by having a a cluster of `etcd` hosts. The minimum size is (1) one.
You can achieve this by running:

```bash
mgmt etcd
```

This starts up a single `etcd` (server) member. You may instead wish to do
something more complicated like:

```bash
mgmt etcd --listen-client-urls=http://0.0.0.0:2379 --advertise-client-urls=http://0.0.0.0:2379 --auto-compaction-mode=periodic --auto-compaction-retention=10h --quota-backend-bytes=8589934592
```

It is recommended that you run this under `systemd`.

This `mgmt etcd` command is exactly what you would get if you were to download
and build the `etcd` binary yourself. We build it into `mgmt` for ease of use.

Building clusters of `etcd` members is outside the scope of this guide, but you
may wish to undertake this if you want the `etcd` backend to be highly
available.

## Agents

Point every host that you want to run `mgmt` on at that `etcd` cluster. Example:

```bash
mgmt run --seeds=http://127.0.0.1:2379 empty
```

The above URL should point to your `etcd` cluster. In this example, they happen
to be on the same machine, but you'll likely want to have this be networked on
different machines.

It is recommended that you run this under `systemd`.

## Deploy

Finally, run a "deploy". This works exactly as `mgmt run` does, except that it
compiles all of the code and pushes it up to `etcd`. Any connected `mgmt` agents
will notice that there is a new active deploy. They will each download the
"model", and run it individually.

```bash
mgmt deploy --no-git --seeds=http://127.0.0.1:2379 lang ~/code/example/
```

## Git

`Mgmt` has native `git` integration that makes working with git repositories fun
and easy. Please reach out if you'd like training on this feature.

## SSH

`Mgmt` has native `ssh` integration that allows you to connect securely over SSH
protocol instead of over the `etcd` protocols. Please reach out if you'd like
training on this feature.
