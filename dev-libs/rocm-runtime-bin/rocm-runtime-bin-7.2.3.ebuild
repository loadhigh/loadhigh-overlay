# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="ROCm HSA runtime (binary extraction from AMD's Ubuntu packages)"
HOMEPAGE="https://rocm.docs.amd.com/"

ROCM_V="7.2.3"
ROCM_BUILD="70203-90~24.04"

SRC_URI="
	https://repo.radeon.com/rocm/apt/${ROCM_V}/pool/main/h/hsa-rocr/hsa-rocr_1.18.0.${ROCM_BUILD}_amd64.deb
	https://repo.radeon.com/rocm/apt/${ROCM_V}/pool/main/h/hsa-rocr-dev/hsa-rocr-dev_1.18.0.${ROCM_BUILD}_amd64.deb
	https://repo.radeon.com/rocm/apt/${ROCM_V}/pool/main/r/rocm-device-libs/rocm-device-libs_1.0.0.${ROCM_BUILD}_amd64.deb
	https://repo.radeon.com/rocm/apt/${ROCM_V}/pool/main/r/rocprofiler-register/rocprofiler-register_0.6.0.${ROCM_BUILD}_amd64.deb
	https://repo.radeon.com/rocm/apt/${ROCM_V}/pool/main/r/rocminfo7.2.3/rocminfo7.2.3_1.0.0.${ROCM_BUILD}_amd64.deb
"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="mirror strip"

RDEPEND="
	dev-libs/elfutils
	sys-process/numactl
	sys-libs/ncurses
	x11-libs/libdrm[video_cards_amdgpu]
"

DEPEND="${RDEPEND}"

QA_PREBUILT="*"

src_unpack() {
	local f
	for f in ${A}; do
		einfo "Extracting ${f}"
		ar p "${DISTDIR}/${f}" data.tar.xz 2>/dev/null | tar -xJf - -C "${S}" 2>/dev/null ||
		ar p "${DISTDIR}/${f}" data.tar.gz 2>/dev/null | tar -xzf - -C "${S}" ||
		die "Failed to extract ${f}"
	done
}

src_install() {
	local rocm="${S}/opt/rocm-${ROCM_V}"

	# Install all shared libraries preserving symlinks
	into /opt/rocm
	insinto /opt/rocm/lib
	insopts -m0755

	local lib
	for lib in "${rocm}"/lib/lib*.so.* "${rocm}"/lib/lib*.a; do
		[[ -L "${lib}" ]] && continue
		doins "${lib}"
	done
	# Recreate symlinks
	for lib in "${rocm}"/lib/lib*.so*; do
		[[ -L "${lib}" ]] || continue
		dosym "$(readlink "${lib}")" "/opt/rocm/lib/${lib##*/}"
	done

	# Install device bitcode
	insinto /opt/rocm/lib/llvm/lib/clang/22/lib/amdgcn/bitcode
	insopts -m0644
	doins "${rocm}"/lib/llvm/lib/clang/22/lib/amdgcn/bitcode/*.bc

	# Symlink for amdgcn path compatibility
	dosym lib/llvm/lib/clang/22/lib/amdgcn /opt/rocm/amdgcn

	# Install rocminfo
	exeinto /opt/rocm/bin
	doexe "${rocm}"/bin/rocminfo
	doexe "${rocm}"/bin/rocm_agent_enumerator

	# Install headers
	insinto /opt/rocm/include
	insopts -m0644
	doins -r "${rocm}"/include/hsa
	doins -r "${rocm}"/include/hsakmt

	# Install cmake configs and pkg-config
	insinto /opt/rocm/lib/cmake
	doins -r "${rocm}"/lib/cmake/hsa-runtime64
	doins -r "${rocm}"/lib/cmake/hsakmt
	# libhsakmt.pc from AMD is missing private deps needed when linking the static lib;
	# patch it in place before installing
	sed -i \
		's|^Libs:.*|&\nRequires.private: libdrm libdrm_amdgpu numa|' \
		"${rocm}"/lib/pkgconfig/libhsakmt.pc
	insinto /opt/rocm/lib/pkgconfig
	doins "${rocm}"/lib/pkgconfig/libhsakmt.pc
	# AMD doesn't ship a hsa-runtime64.pc; generate one
	cat > "${T}/hsa-runtime64.pc" <<-EOF
		prefix=/opt/rocm
		libdir=\${prefix}/lib
		includedir=\${prefix}/include

		Name: hsa-runtime64
		Description: HSA Runtime 64-bit library
		Version: 1.18.${ROCM_BUILD%%[-~]*}
		Libs: -L\${libdir} -lhsa-runtime64
		Cflags: -I\${includedir}
	EOF
	doins "${T}/hsa-runtime64.pc"

	# PATH and LDPATH via env.d
	newenvd - 50rocm <<-EOF
		LDPATH="/opt/rocm/lib"
		PATH="/opt/rocm/bin"
		PKG_CONFIG_PATH="/opt/rocm/lib/pkgconfig"
	EOF
}

pkg_postinst() {
	elog "ROCm ${ROCM_V} runtime installed to /opt/rocm/"
	elog "Run 'env-update && source /etc/profile' or re-login."
	elog "Verify with: HSA_ENABLE_DXG_DETECTION=1 rocminfo"
}
