# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Fontconfig rules for Nerd Font Symbols fallback"
HOMEPAGE="https://www.nerdfonts.com/ https://github.com/ryanoasis/nerd-fonts"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	media-fonts/symbols-nerd-font
	media-libs/fontconfig
"

src_install() {
	insinto /etc/fonts/conf.avail
	doins "${FILESDIR}"/99-nerd-fonts-symbols.conf
	dosym -r /etc/fonts/conf.avail/99-nerd-fonts-symbols.conf \
		/etc/fonts/conf.d/99-nerd-fonts-symbols.conf
}
