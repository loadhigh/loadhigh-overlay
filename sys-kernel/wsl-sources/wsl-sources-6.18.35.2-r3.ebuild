# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"

# wsl-sources = gentoo-sources (at ${CKV}) + Microsoft's WSL delta.
#
# K_GENPATCHES_VER is chosen so that genpatches "base" includes stable patches
# up to and including patch-${CKV} but no further.  Verify with:
#   tar tf genpatches-${KV_MAJOR}.${KV_MINOR}-${K_GENPATCHES_VER}.base.tar.xz \
#     | grep -Eo '10[0-9][0-9]_linux-[^.]+\.[0-9]+\.[0-9]+\.patch' | sort | tail -1
# For 6.18.35 the answer is genpatches-6.18-41 (last stable = 1034_linux-6.18.35).
K_WANT_GENPATCHES="base extras experimental"
K_GENPATCHES_VER="41"
K_NOSETEXTRAVERSION=1
K_SECURITY_UNSUPPORTED="1"

# Microsoft's linux-msft-wsl-${PV} tag equals kernel.org v${CKV} + a small
# WSL delta.  We reconstruct it from Gentoo/kernel.org mirror pieces:
#
#   linux-${KV_MAJOR}.${KV_MINOR}.tar.xz          (kernel.org mainline base, ~150 MB)
# + genpatches-${KV_MAJOR}.${KV_MINOR}-${K_GENPATCHES_VER}.base.tar.xz
#                                                 (Gentoo stable + baseline, ~2 MB)
# + genpatches ...extras / ...experimental        (Gentoo patchset, small)
# + linux-msft-wsl-${MSV}.diff                    (v${CKV}..linux-msft-wsl-${MSV},
#                                                  ~1 MB, served by GitHub compare)
#
# Every distfile above is a Gentoo/kernel.org mirror-friendly file except
# the WSL delta, which is served by GitHub's compare API and is immutable
# per (base commit, head commit) pair.
MSV="${PV}"
CKV="${PV%.*}"

inherit kernel-2
detect_version
detect_arch

# Commit SHA of tag v${CKV} in kernel.org's linux-stable tree.
# Reproduce with:
#   git ls-remote https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git \
#     "refs/tags/v${CKV}^{}" | awk '{print $1}'
UPSTREAM_SHA="acb7cf4c1184e27622be0faf89244d5001ed1e87"

WSL_DIFF="linux-msft-wsl-${MSV}.diff"

DESCRIPTION="Linux kernel for WSL2 (gentoo-sources at v${CKV} + Microsoft WSL delta)"
HOMEPAGE="https://github.com/microsoft/WSL2-Linux-Kernel"

# ${KERNEL_URI} provides linux-${KV_MAJOR}.${KV_MINOR}.tar.xz.
# ${GENPATCHES_URI} provides base + extras + experimental (base carries the
# stable patch series 1000..1034 which brings the tree to v${CKV}).
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}
	https://github.com/microsoft/WSL2-Linux-Kernel/compare/${UPSTREAM_SHA}...linux-msft-wsl-${MSV}.diff -> ${WSL_DIFF}"

# detect_version derives KV_FULL from CKV, and we set CKV=${PV%.*}=${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}
# so that ${KERNEL_URI}/${GENPATCHES_URI} resolve to real mirror files. That
# drops the Microsoft trailing revision (the ".2" in 6.18.35.2), which we want
# to keep so /usr/src/linux-${KV_FULL} makes the Microsoft revision visible.
KV_FULL="${PV}-${PN/-*}"
[[ -n ${PR//r0} ]] && KV_FULL="${KV_FULL}-${PR}"
KV="${KV_FULL}"
S="${WORKDIR}/linux-${KV_FULL}"

KEYWORDS="~amd64 ~arm64"
IUSE="experimental"

# Only the WSL delta URL (github.com compare API) is off-mirror; the
# kernel.org and distfiles.gentoo.org URIs are already served by the Gentoo /
# kernel.org mirror hosts.  RESTRICT="mirror" tells Gentoo's mirror robots not
# to try to archive our distfiles (the github one cannot be archived anyway).
RESTRICT="mirror"

# Application order (via kernel-2's unipatch phase; see line 1455 of the eclass):
#   1. UNIPATCH_LIST_DEFAULT     -> (unused)
#   2. UNIPATCH_LIST_GENPATCHES  -> base (v${KV_MAJOR}.${KV_MINOR} -> v${CKV},
#                                        then Gentoo baseline patches)
#                                -> extras
#                                -> experimental (with USE=experimental)
#   3. UNIPATCH_LIST             -> WSL delta  (v${CKV} -> linux-msft-wsl-${MSV})
#
# The WSL delta only touches WSL-specific files (drivers/hv/dxgkrnl/*, hv,
# hyperv, fuse virtio_fs, etc.) which don't overlap with any genpatches
# baseline/extras/experimental patch, so ordering the WSL delta last is safe.
UNIPATCH_LIST="${DISTDIR}/${WSL_DIFF}"

pkg_postinst() {
	kernel-2_pkg_postinst
	# elog (not einfo): einfo is not captured by PORTAGE_ELOG_SYSTEM, so it
	# would scroll off the terminal during the merge and never make it into
	# /var/log/portage/elog/summary.log or the end-of-emerge summary block.
	elog ""
	elog "wsl-sources-${PV} = gentoo-sources at v${CKV} + Microsoft's WSL delta"
	elog "  WSL upstream: https://github.com/microsoft/WSL2-Linux-Kernel/tree/linux-msft-wsl-${MSV}"
	elog "  Reproduce:    linux-${KV_MAJOR}.${KV_MINOR}.tar.xz"
	elog "              + genpatches-${KV_MAJOR}.${KV_MINOR}-${K_GENPATCHES_VER}.{base,extras,experimental}.tar.xz"
	elog "              + ${WSL_DIFF}"
	elog ""
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
