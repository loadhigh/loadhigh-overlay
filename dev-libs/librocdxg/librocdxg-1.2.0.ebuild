# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="ROCm GPU compute library for WSL2 via /dev/dxg"
HOMEPAGE="https://github.com/ROCm/librocdxg"

SRC_URI="https://github.com/ROCm/librocdxg/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${PV}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1)"
KEYWORDS="~amd64"
RESTRICT="mirror"

# WIN_SDK is not a portage package — it lives on /mnt/c from the Windows host.
# We validate its presence at build time rather than expressing it as DEPEND.
BDEPEND="
	>=dev-build/cmake-3.15
	virtual/pkgconfig
"
RDEPEND="
	dev-libs/rocm-runtime-bin
"
DEPEND=""

# The repo ships a prebuilt libthunk_proxy.a (x86_64 only, closed-source shim).
QA_PREBUILT="*"

WIN_SDK_DEFAULT='/mnt/c/Program Files (x86)/Windows Kits/10/Include/10.0.26100.0'

pkg_pretend() {
	local sdk="${WIN_SDK:-${WIN_SDK_DEFAULT}}"
	if [[ ! -f "${sdk}/shared/d3dkmthk.h" ]]; then
		eerror "Windows SDK headers not found at: ${sdk}/shared/"
		eerror "Install the Windows SDK on your Windows host, or set WIN_SDK"
		eerror "to the Include/<version> path (e.g. in /etc/portage/make.conf)."
		die "Windows SDK headers required"
	fi
}

src_prepare() {
	cmake_src_prepare
	# Remove ldconfig call — portage runs it post-merge
	sed -i '/execute_process.*ldconfig/d' CMakeLists.txt || die
}

src_configure() {
	local sdk="${WIN_SDK:-${WIN_SDK_DEFAULT}}"
	local mycmakeargs=(
		-DWIN_SDK="${sdk}/shared"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/opt/rocm"
		-DROCM_DEP_ROCMCORE=OFF
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# env.d so HSA runtime can find librocdxg and the loader activates it
	newenvd - 55rocm-dxg <<-EOF
		LDPATH="/opt/rocm/$(get_libdir)"
		HSA_ENABLE_DXG_DETECTION=1
	EOF
}

pkg_postinst() {
	elog "librocdxg is installed to /opt/rocm/$(get_libdir)."
	elog "HSA_ENABLE_DXG_DETECTION=1 has been set via env.d."
	elog "Run 'env-update && source /etc/profile' or re-login to activate."
	elog ""
	elog "Verify with: rocminfo"
}
