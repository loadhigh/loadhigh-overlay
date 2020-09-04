# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd

DESCRIPTION="Hyper-V tools"
HOMEPAGE="https://github.com/microsoft/WSL2-Linux-Kernel"
SRC_URI="https://github.com/microsoft/WSL2-Linux-Kernel/archive/linux-msft-${PV}.tar.gz"
S="${WORKDIR}/WSL2-Linux-Kernel-linux-msft-${PV}/tools/hv"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm64"

src_install() {
	emake DESTDIR="${D}" install

	systemd_dounit "${FILESDIR}"/hv_fcopy_daemon.service
	systemd_dounit "${FILESDIR}"/hv_kvp_daemon.service
	systemd_dounit "${FILESDIR}"/hv_vss_daemon.service
}
