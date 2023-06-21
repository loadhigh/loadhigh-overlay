# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Misc. workarounds for running systemd in WSL2"
HOMEPAGE="https://github.com/wslutilities/wslu"

KEYWORDS="amd64 arm64"


RDEPEND=""

LICENSE="MIT"
SLOT="0"

S=${WORKDIR}

src_install() {
	# equivalent to "systemctl mask tmp.mount"
	dosym /dev/null /etc/systemd/system/tmp.mount

	# equivalent to "systemctl mask systemd-binfmt.service"
	dosym /dev/null /etc/systemd/system/systemd-binfmt.service

	insinto /etc/bash/bashrc.d
	newins "${FILESDIR}/wsl-systemd.bashrc.sh" wsl-systemd.sh

	insinto /etc/sudoers.d
	insopts -m440
	newins "${FILESDIR}/wsl-systemd.sudoers" wsl-systemd
}
