# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RPM_COMPRESS_TYPE=none

inherit rpm

DESCRIPTION="sqlcmd and bcp SQL Server command-line tools for Linux"
HOMEPAGE="https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility"
SRC_URI="https://packages.microsoft.com/rhel/9/prod/Packages/m/${P}-1.x86_64.rpm"
S="${WORKDIR}"

LICENSE="Microsoft-mssql-tools"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip mirror"

RDEPEND="
	>=dev-db/unixODBC-2.3.9
	>=dev-db/msodbcsql18-${PV}
"

src_install() {
	cp -a opt usr "${ED}/" || die
	if [[ -d ${ED}/usr/share/doc/${PN} ]]; then
		mv "${ED}/usr/share/doc/${PN}" "${ED}/usr/share/doc/${PN}-${PV}" || die
	fi
	dosym "../../opt/${PN}/bin/bcp" "/usr/bin/bcp"
	dosym "../../opt/${PN}/bin/sqlcmd" "/usr/bin/sqlcmd"
}
