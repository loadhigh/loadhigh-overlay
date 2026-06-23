# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-info systemd toolchain-funcs

DESCRIPTION="Microsoft Hyper-V Linux guest userspace daemons (KVP, VSS, fcopy)"
HOMEPAGE="https://www.kernel.org/"
# No SRC_URI: built from tools/hv/ in the already-installed kernel source tree.
S="${WORKDIR}/hv"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="virtual/linux-sources"

pkg_setup() {
	linux-info_pkg_setup
	[[ -d "${KERNEL_DIR}/tools/hv" ]] \
		|| die "${KERNEL_DIR}/tools/hv not found; install a kernel source that includes the Hyper-V tools"
}

src_unpack() {
	mkdir -p "${S}" || die
	# Copy only the files we need; skip the kernel's Makefile because it
	# depends on the rest of tools/ (scripts/, build/, fixdep, ...). The
	# daemons themselves are simple userspace programs.
	local f
	for f in hv_kvp_daemon.c hv_vss_daemon.c \
	         hv_fcopy_daemon.c hv_fcopy_uio_daemon.c \
	         vmbus_bufring.c vmbus_bufring.h \
	         hv_get_dhcp_info.sh hv_get_dns_info.sh hv_set_ifconfig.sh \
	         lsvmbus; do
		if [[ -e "${KERNEL_DIR}/tools/hv/${f}" ]]; then
			cp -L "${KERNEL_DIR}/tools/hv/${f}" "${S}/" || die "failed to copy ${f}"
		fi
	done
	[[ -f "${S}/hv_kvp_daemon.c" ]] || die "hv_kvp_daemon.c missing from ${KERNEL_DIR}/tools/hv"
}

src_compile() {
	local cc=$(tc-getCC)
	local cflags="-O2 -Wall -D_GNU_SOURCE ${CFLAGS}"

	einfo "Building hv_kvp_daemon"
	${cc} ${cflags} ${LDFLAGS} hv_kvp_daemon.c -o hv_kvp_daemon || die

	einfo "Building hv_vss_daemon"
	${cc} ${cflags} ${LDFLAGS} hv_vss_daemon.c -o hv_vss_daemon || die

	# Linux >=6.10 renamed hv_fcopy_daemon to hv_fcopy_uio_daemon and split
	# the bufring helpers into vmbus_bufring.c. Linux >=7.1 additionally
	# restricts the UIO daemon to x86/x86_64 (no aarch64). Older trees ship
	# the original single-file daemon. Build whichever is appropriate.
	case ${ARCH} in
		amd64|x86) local hv_fcopy_uio_ok=1 ;;
		*)         local hv_fcopy_uio_ok=0 ;;
	esac
	if [[ -f hv_fcopy_uio_daemon.c && ${hv_fcopy_uio_ok} -eq 1 ]]; then
		einfo "Building hv_fcopy_uio_daemon"
		${cc} ${cflags} -Wno-address-of-packed-member ${LDFLAGS} \
			hv_fcopy_uio_daemon.c vmbus_bufring.c -o hv_fcopy_uio_daemon || die
	elif [[ -f hv_fcopy_daemon.c ]]; then
		einfo "Building hv_fcopy_daemon"
		${cc} ${cflags} ${LDFLAGS} hv_fcopy_daemon.c -o hv_fcopy_daemon || die
	fi
}

src_install() {
	dosbin hv_kvp_daemon hv_vss_daemon
	[[ -f hv_fcopy_uio_daemon ]] && dosbin hv_fcopy_uio_daemon
	[[ -f hv_fcopy_daemon ]]     && dosbin hv_fcopy_daemon
	[[ -f lsvmbus ]]             && dosbin lsvmbus

	# KVP helper scripts go in /usr/libexec/hypervkvpd/ without the .sh suffix
	# (this is the path hv_kvp_daemon execs by default).
	local s
	for s in hv_get_dhcp_info hv_get_dns_info hv_set_ifconfig; do
		if [[ -f "${s}.sh" ]]; then
			exeinto /usr/libexec/hypervkvpd
			newexe "${s}.sh" "${s}"
		fi
	done

	# OpenRC init scripts
	newinitd "${FILESDIR}"/hv_kvp_daemon.initd hv_kvp_daemon
	newinitd "${FILESDIR}"/hv_vss_daemon.initd hv_vss_daemon

	# systemd units
	systemd_dounit "${FILESDIR}"/hv_kvp_daemon.service
	systemd_dounit "${FILESDIR}"/hv_vss_daemon.service

	# fcopy unit/initd: substitute the renamed binary on >=6.10 kernels
	if [[ -f hv_fcopy_uio_daemon ]]; then
		sed 's|hv_fcopy_daemon|hv_fcopy_uio_daemon|g' \
			"${FILESDIR}"/hv_fcopy_daemon.initd > "${T}"/hv_fcopy_uio_daemon.initd || die
		sed 's|hv_fcopy_daemon|hv_fcopy_uio_daemon|g' \
			"${FILESDIR}"/hv_fcopy_daemon.service > "${T}"/hv_fcopy_uio_daemon.service || die
		newinitd "${T}"/hv_fcopy_uio_daemon.initd hv_fcopy_uio_daemon
		systemd_newunit "${T}"/hv_fcopy_uio_daemon.service hv_fcopy_uio_daemon.service
	elif [[ -f hv_fcopy_daemon ]]; then
		newinitd "${FILESDIR}"/hv_fcopy_daemon.initd hv_fcopy_daemon
		systemd_dounit "${FILESDIR}"/hv_fcopy_daemon.service
	fi
}
