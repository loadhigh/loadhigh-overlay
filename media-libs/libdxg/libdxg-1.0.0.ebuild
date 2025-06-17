EAPI=8

inherit meson

DESCRIPTION="Microsoft's libdxg: DirectX Graphics Kernel for Linux (DXGKRNL)"
HOMEPAGE="https://github.com/microsoft/libdxg"

COMMIT="045831efab4b1e50db2b658dc9e129f11b84b549"

SRC_URI="https://github.com/microsoft/libdxg/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT}.tar.gz"
S="${WORKDIR}/libdxg-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

BDEPEND="\
	>=dev-util/directx-headers-1.614.1\
"

src_prepare() {
	default
	# Insert #include <array> after #include <cwchar> for GCC 14 compatibility
	sed -i '/#include <cwchar>/a #include <array>' src/d3dkmt-wsl.cpp || die
}

src_configure() {
	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install
}
