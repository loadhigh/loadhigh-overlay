# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Tool to start systemd in its own namespace with WSL2 Interop fixes"
HOMEPAGE="https://github.com/wslutilities/wslu"

KEYWORDS="amd64"


RDEPEND="
	  sys-apps/systemd
		sys-apps/daemonize
		sys-apps/util-linux
		sys-apps/findutils
		app-admin/sudo
"

LICENSE="GPL-3"
SLOT="0"

S=${WORKDIR}

src_install() {
	# equivalent to "systemctl mask tmp.mount"
	dosym /dev/null /etc/systemd/system/tmp.mount

	exeinto "/usr/bin"
	doexe "${FILESDIR}/wsl-systemd"

	# WSL only supports interop using mount command
	insinto /etc/systemd/system/systemd-binfmt.service.d
	newins "${FILESDIR}/systemd-binfmt.service.conf" wsl-systemd.conf

	# Dummy file because systemd-binfmt.serivce will be skipped otherwise
	insinto /etc/binfmt.d
	newins "${FILESDIR}/wsl-systemd.binfmt" wsl-systemd

	insinto /etc/bash/bashrc.d
	newins "${FILESDIR}/wsl-systemd.bashrc.sh" wsl-systemd.sh

	insinto /etc/sudoers.d
	insopts -m440
	newins "${FILESDIR}/wsl-systemd.sudoers" wsl-systemd
}
