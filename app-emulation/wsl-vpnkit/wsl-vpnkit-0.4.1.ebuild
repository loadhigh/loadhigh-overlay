# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd

DESCRIPTION="Provides network connectivity to WSL 2 when blocked by VPN"
HOMEPAGE="https://github.com/sakai135/wsl-vpnkit"

SRC_URI="https://github.com/sakai135/${PN}/releases/download/v${PV}/${PN}.tar.gz -> ${P}.tar.gz"
KEYWORDS="amd64"

RDEPEND="
	sys-apps/iproute2
	net-firewall/iptables
	net-misc/iputils
	net-dns/bind-tools
	net-misc/wget
"

LICENSE="MIT"
SLOT="0"

S="${WORKDIR}"

src_prepare() {
	default
	mv "${S}/app" "${S}/${PN}"
}

src_install() {
	rm "${S}/${PN}/wsl-vpnkit.service"

	insinto /opt
	doins -r "${S}/${PN}"

	fperms 0755 "/opt/${PN}/wsl-gvproxy.exe" "/opt/${PN}/wsl-vm" "/opt/${PN}/wsl-vpnkit"

	systemd_dounit "${FILESDIR}"/wsl-vpnkit.service
}
