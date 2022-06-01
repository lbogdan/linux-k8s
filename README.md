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

- an (initial) system configuration and Kubernetes bootstrap tool - [cloud-init](https://cloudinit.readthedocs.io/en/latest/) / [ignition](https://coreos.github.io/ignition/) / other?

- support existing:
  - CRIs: `containerd`, `cri-o`, maybe? `cri-dockerd`
  - maybe? OCI runtimes: `runc`, `crun`, `gvisor`, Kata Containers

- allow users to build everything from scratch, maybe? even inside air gapped environments

- comprehensive documentation, especially around the "getting started" story, various use-cases etc.

## Use cases:

- one or more dedicated[^2] servers in a home-lab

- dedicated servers in a bare-metal hosting provider (e.g. Hetzner)

- one or more dedicated VMs in Vagrant

- one or more dedicated VMs in a hypervisor (e.g. libvirt, VMWare)

- maybe? one or more dedicated VPSes / instances in cloud providers: GCP, AWS, Azure, Digital Ocean etc.

## Previous Art

- [Talos Linux](https://www.talos.dev/)

- [Flatcar Container Linux](https://flatcar-linux.org/)

- Google's [Container-Optimized OS](https://cloud.google.com/container-optimized-os/docs)

- Rancher's [k3OS](https://k3os.io/)

- AWS' [Bottlerocket OS](https://aws.amazon.com/bottlerocket/)

- VMware's [Photon OS](https://vmware.github.io/photon/assets/files/html/3.0/Introduction.html)

Other experiments:

- [CLIP OS](https://clip-os.org/en/clipos5/)

- [webootkube](https://github.com/webootkube/proposals) ([tweet](https://twitter.com/fntlnz/status/1264214108007784448))

Related:

- [COSI - The Common Operating System Interface](https://docs.google.com/document/d/1OuwTSsSsIPefDViheK-nzaF9xSOg1Mn62mwR2FmGPu8/edit#)

## Base Linux Distribution

This is a very important decision, but more from a development point of view, and less from an end user one, which shouldn't necessarily care what's running under the hood, as long as the operations experience is good. The extreme approach would be to start from something like [LFS - Linux From Scratch](https://www.linuxfromscratch.org/). The conservative one would be to start from a general purpose disto like Ubuntu, which I'm most familiar with. The middle road (more towards LFS, I guess), which I'm strongly considering, is to start from Gentoo - I was a fan 10 or so years ago, but I eventually ditched it, because it wasn't really suitable for my use-cases back then. Incidentally Flatcar, which was forked from CoreOS, also uses Gentoo for its base. I think it's a perfect fix for this - you still compile everything from source, but you already have all build recipes and dependencies carved out for you.

## Project Phases

1. Create a minimal, stripped down Gentoo install, with just the userspace binaries needed to run a Kubernetes node. In the process, document exactly why each binary, library and configuration file is required, and the runtime dependencies between them (e.g. `systemd` / `systemd-networkd` depends on `dhcpcd` if there is a DHCP-enabled network interface).

2. Adapt Gentoo's [ebuilds](https://wiki.gentoo.org/wiki/Ebuild) for CRIs and Kubernetes tools needed to bootstrap a node into a portage overlay. Iterate on 1. while incorporating them into the install. Bootstrap a multi-node Kubernetes cluster using `kubeadm`.

3. Create scripts to automate building the install obtained in 1. and 2 from scratch.

4. Lock down things a bit: read-only root filesystem, maybe? firewall etc.

5. Test various CNIs, CSIs, service meshes etc. - things that usually need some userspace support on the Kubernetes nodes.

6. Write integration tests.

7. Figure out the initial system configuration and Kubernetes bootstrap story. Test various storage and network configurations. Maybe? create an install scripts, create a `cloud-init` enabled image to use with Vagrant / libvirt.

8. Figure out the upgrade story (hopefully by the time `1.25` is out).

[^1]: minimal to the point where **all** files in the root filesystem are required, and removing any one file would render the server unusable; that basically means just required binaries, shared libraries and configuration files

[^2]: "dedicated" in this context means that the server / VM is used **exclusively** as a Kubernetes node
