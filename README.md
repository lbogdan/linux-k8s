## Goals / Requirements:

- a minimal[^1] Linux distribution, used exclusively for Kubernetes `kubeadm`-bootstrapped nodes
  - maybe? also for standalone `containerd`, `cri-o` / `podman` servers, same as Flatcar?
  - maybe? also support `k3s` / other Kubernetes distibutions?

- read-only root filesystem, with read-write mounted folders for persistent state, backed by disk partitions (e.g. `/etc/kubernetes` - `kubeadm`-generated Kubernetes configuration, `/var/lib/containers/storage` - `cri-o`'s data folder)
  - maybe? a read-write root overlay, to allow installing packages / tools required for troubleshooting; alternatively, since Kubernetes `1.23`, nodes can be troubleshooted using [`kubectl debug node/node-name`](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#node-shell-session)

- atomic updates using a dual root filesystem (one active, one to write the update to and boot from at next boot, similar to dual BIOS motherboards), and update channels (stable, beta, nightly)
  - upgrading Kubernetes minor versions (e.g. `1.23.7` -> `1.24.1`) on control-plane nodes is non-trivial, as it reqires running `kubeadm`, which usually does more than just upgrading `etcd` and `kube-*` image tags in `/etc/kubernetes/manifests/*.yaml`

- maybe? minimal package support, to be able to install optional system-wide required tools (e.g. `lvm`, `open-iscsi`); alternatively we can bake everything into the root filesystem, but that would go against [^1]

- security - TBD what exactly that means

- an (initial) system configuration tool - [cloud-init](https://cloudinit.readthedocs.io/en/latest/) / [ignition](https://coreos.github.io/ignition/) / other?

- support existing:
  - CRIs: `containerd`, `cri-o`, maybe? `cri-dockerd`
  - maybe? OCI runtimes: `runc`, `crun`, `gvisor`, Kata Containers

## Use cases:

- one or more dedicated[^2] servers in a home-lab

- dedicated servers in a bare-metal hosting provider (e.g. Hetzner)

- one or more dedicated VMs in Vagrant

- one or more dedicated VMs in a hypervisor (e.g. libvirt, VMWare)

[^1]: minimal to the point where **all** files in the root filesystem are required, and removing any one file would render the server unusable; that basically means just required binaries, shared libraries and configuration files

[^2]: "dedicated" in this context means that the server / VM is used **exclusively** as a Kubernetes node
