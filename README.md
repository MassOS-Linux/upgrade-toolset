# upgrade-toolset
A set of statically-linked tools for use by massos-upgrade.

Since [massos-upgrade](https://github.com/MassOS-Linux/massos-upgrade)
overwrites core system libraries during the upgrade process, it can cause
problems, especially when Glibc gets updated, as it can crash programs,
including the ones its using for the update process.

To workaround this problem, we have compiled a set of statically linked tools
which can be used by the upgrade process. As they are statically linked, there
will be no runtime issues when dynamic libraries are updated.

The tools here are linked against [musl libc](https://musl.libc.org), as it is
not possible to fully statically link with Glibc. The toolchain used to build
the tools is [here](https://github.com/DanielMYT/musl-cross-make), which is a
fork of [musl-cross-make](https://github.com/richfelker/musl-cross-make).

The included tools are:

- [Bash](https://www.gnu.org/software/bash/)
- [Coreutils](https://www.gnu.org/software/coreutils/)
- [Diffutils](https://www.gnu.org/software/diffutils/)
- [Findutils](https://www.gnu.org/software/findutils/)
- [Grep](https://www.gnu.org/software/grep/)
- [Sed](https://www.gnu.org/software/sed/)

These are the only tools needed by massos-upgrade during the upgrade process.
For example, it doesn't include **tar**, as that is only needed to extract the
update package before the upgrade process actually starts.

Package versions are defined in `versions.conf`, which is sourced by the build
script, `build.sh`. Don't expect new releases frequently.
