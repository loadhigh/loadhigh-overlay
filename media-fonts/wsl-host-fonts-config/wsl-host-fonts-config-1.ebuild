# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Fontconfig rules to add WSL host Windows fonts to the search path"
HOMEPAGE="https://learn.microsoft.com/en-us/windows/wsl/"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	media-libs/fontconfig
"

src_install() {
	insinto /etc/fonts/conf.avail
	doins "${FILESDIR}"/99-wsl-host-fonts.conf
	dosym -r /etc/fonts/conf.avail/99-wsl-host-fonts.conf \
		/etc/fonts/conf.d/99-wsl-host-fonts.conf
}
