# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd

MSV="${PV}.1"

DESCRIPTION="Hyper-V tools"
HOMEPAGE="https://github.com/microsoft/WSL2-Linux-Kernel"
SRC_URI="https://github.com/microsoft/WSL2-Linux-Kernel/archive/refs/tags/rolling-lts/wsl/${MSV}.tar.gz -> linux-msft-${OKV}.tar.gz"
S="${WORKDIR}/WSL2-Linux-Kernel-rolling-lts-wsl-${MSV}/tools/hv"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="amd64"

src_install() {
	emake DESTDIR="${D}" install

	newinitd "${FILESDIR}"/hv_fcopy_daemon.initd hv_fcopy_daemon
	newinitd "${FILESDIR}"/hv_kvp_daemon.initd hv_kvp_daemon
	newinitd "${FILESDIR}"/hv_vss_daemon.initd hv_vss_daemon

	systemd_dounit "${FILESDIR}"/hv_fcopy_daemon.service
	systemd_dounit "${FILESDIR}"/hv_kvp_daemon.service
	systemd_dounit "${FILESDIR}"/hv_vss_daemon.service
}
