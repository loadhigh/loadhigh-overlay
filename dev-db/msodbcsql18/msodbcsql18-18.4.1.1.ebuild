# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit rpm

DESCRIPTION="Microsoft ODBC Driver 18 for SQL Server on Linux."
HOMEPAGE="https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server?view=sql-server-ver15"
SRC_URI="https://packages.microsoft.com/rhel/9/prod/Packages/m/${P}-1.x86_64.rpm"
S="${WORKDIR}"
LICENSE="Microsoft-odbc"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip mirror"

RDEPEND="
	>=dev-db/unixODBC-2.3.9
	app-crypt/mit-krb5
"

src_install() {
	cp -r opt usr "${ED}"
	if [ -d "${ED}/usr/share/doc/${PN}" ]; then
		mv "${ED}/usr/share/doc/${PN}" "${ED}/usr/share/doc/${PN}-${PV}"
	fi
}

pkg_postinst() {
	odbcinst -i -d -f /opt/microsoft/msodbcsql18/etc/odbcinst.ini
}

pkg_prerm() {
	odbcinst -u -d -n "ODBC Driver 18 for SQL Server"
}
