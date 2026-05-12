# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="ROCm HSA runtime (binary extraction from AMD's Ubuntu packages)"
HOMEPAGE="https://rocm.docs.amd.com/"

ROCM_V="7.2.3"
ROCM_BUILD="70203-90~24.04"
HSA_SO_VER="1.18.70203"

SRC_URI="
	https://repo.radeon.com/rocm/apt/${ROCM_V}/pool/main/h/hsa-rocr/hsa-rocr_1.18.0.${ROCM_BUILD}_amd64.deb
	https://repo.radeon.com/rocm/apt/${ROCM_V}/pool/main/h/hsa-rocr-dev/hsa-rocr-dev_1.18.0.${ROCM_BUILD}_amd64.deb
	https://repo.radeon.com/rocm/apt/${ROCM_V}/pool/main/r/rocprofiler-register/rocprofiler-register_0.6.0.${ROCM_BUILD}_amd64.deb
"

S="${WORKDIR}"

LICENSE="MIT"
# Mirror dev-libs/rocr-runtime SLOT exactly
SLOT="0/7.2"
KEYWORDS="~amd64"

RESTRICT="mirror strip"

RDEPEND="
	dev-libs/elfutils
	sys-process/numactl
	x11-libs/libdrm[video_cards_amdgpu]
	!dev-libs/rocr-runtime
"

QA_PREBUILT="*"

src_unpack() {
	local f
	for f in ${A}; do
		einfo "Extracting ${f}"
		ar p "${DISTDIR}/${f}" data.tar.gz | tar -xzf - -C "${S}" ||
		die "Failed to extract ${f}"
	done
}

src_install() {
	local rocm="${S}/opt/rocm-${ROCM_V}"

	# libhsa-runtime64 → /usr/lib64
	exeinto /usr/lib64
	doexe "${rocm}/lib/libhsa-runtime64.so.${HSA_SO_VER}"
	dosym "libhsa-runtime64.so.${HSA_SO_VER}" "/usr/lib64/libhsa-runtime64.so.1"
	dosym "libhsa-runtime64.so.1" "/usr/lib64/libhsa-runtime64.so"

	# rocprofiler-register runtime dep of libhsa-runtime64
	doexe "${rocm}/lib/librocprofiler-register.so.0.6.0"
	dosym "librocprofiler-register.so.0.6.0" "/usr/lib64/librocprofiler-register.so.0"
	dosym "librocprofiler-register.so.0" "/usr/lib64/librocprofiler-register.so"

	# HSA headers → /usr/include/hsa
	insinto /usr/include/hsa
	insopts -m0644
	doins "${rocm}"/include/hsa/*.h

	# hsakmt headers → /usr/include/hsakmt (needed by hip cmake)
	insinto /usr/include/hsakmt
	doins "${rocm}"/include/hsakmt/*.h

	# cmake configs — patch lib → lib64 to match Gentoo multilib layout
	local cmake_src="${rocm}/lib/cmake/hsa-runtime64"
	insinto /usr/lib64/cmake/hsa-runtime64
	insopts -m0644
	local f
	for f in "${cmake_src}"/*.cmake; do
		sed 's|/lib/libhsa|/lib64/libhsa|g' "${f}" > "${T}/${f##*/}" || die
		doins "${T}/${f##*/}"
	done

	# pkg-config — generated to match rocr-runtime
	cat > "${T}/hsa-runtime64.pc" <<-EOF
		prefix=/usr
		libdir=\${prefix}/lib64
		includedir=\${prefix}/include

		Name: hsa-runtime64
		Description: HSA Runtime 64-bit library
		Version: 1.18.0
		Libs: -L\${libdir} -lhsa-runtime64
		Cflags: -I\${includedir}/hsa
	EOF
	insinto /usr/lib64/pkgconfig
	doins "${T}/hsa-runtime64.pc"
}
