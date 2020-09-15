# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop

DESCRIPTION="A collection of utilities for Windows 10 Linux Subsystems"
HOMEPAGE="https://github.com/wslutilities/wslu"

if [[ "${PV}" == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/wslutilities/wslu.git"
	EGIT_BRANCH="dev/master"
else
	SRC_URI="https://github.com/wslutilities/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 arm64"
fi

PATCHES=(
	"${FILESDIR}/${P}-gentoo.patch"
)

RDEPEND="
	sys-devel/bc
	media-gfx/imagemagick
"

LICENSE="GPL-3"
SLOT="0"

src_install() {
	docompress -x /usr/share/man
	default
	domenu ${D}/usr/share/wslu/wslview.desktop
}
