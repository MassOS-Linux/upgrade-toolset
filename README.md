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
- [File](https://darwinsys.com/file/)
- [Findutils](https://www.gnu.org/software/findutils/)
- [Gawk](https://www.gnu.org/software/gawk/)
- [Gettext-Tools](https://www.gnu.org/software/gettext/)
- [Grep](https://www.gnu.org/software/grep/)
- [Gzip](https://www.gnu.org/software/gzip/)
- [M4](https://www.gnu.org/software/m4/)
- [Make](https://www.gnu.org/software/make/)
- [Patch](https://savannah.gnu.org/projects/patch/)
- [Sed](https://www.gnu.org/software/sed/)
- [Tar](https://www.gnu.org/software/tar/)
- [Xz](https://tukaani.org/xz/)

These are the tools needed by massos-upgrade during the upgrade process, plus
(as of 2022-10-15) some additional ones which may also be necessary/useful.

Package versions are defined in `versions.conf`, which is sourced by the build
script, `build.sh`. The software will only be updated on an as-needed basis.
