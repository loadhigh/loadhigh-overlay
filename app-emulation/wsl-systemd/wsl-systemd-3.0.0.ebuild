# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Misc. workarounds for running systemd in WSL2"
HOMEPAGE="https://github.com/wslutilities/wslu"
LICENSE="MIT"

SLOT="0"
KEYWORDS="amd64 arm64"

RDEPEND=""

S=${WORKDIR}

src_install() {
	# Mask unwanted systemd units
	local known_bad_units=(
		NetworkManager.service
		systemd-networkd.service
		systemd-networkd.socket
		systemd-resolved.service
		systemd-tmpfiles-clean.service
		systemd-tmpfiles-clean.timer
		systemd-tmpfiles-setup-dev-early.service
		systemd-tmpfiles-setup-dev.service
		systemd-tmpfiles-setup.service
		tmp.mount
	)
	for unit in "${known_bad_units[@]}"; do
		dosym /dev/null /etc/systemd/system/"${unit}"
	done

	insinto /etc/sudoers.d
	insopts -m440
	newins "${FILESDIR}/wsl-systemd.sudoers" wsl-systemd
}
