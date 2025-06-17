# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit rpm

DESCRIPTION="Install sqlcmd and bcp the SQL Server command-line tools on Linux."
HOMEPAGE="https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver15"
SRC_URI="https://packages.microsoft.com/rhel/9/prod/Packages/m/${P}-1.x86_64.rpm"
S=${WORKDIR}
LICENSE="Microsoft-mssql-tools"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip mirror"

BDEPEND="app-arch/rpm2targz"

RDEPEND="
	>=dev-db/unixODBC-2.3.9 \
	>=dev-db/msodbcsql18-${PV}
"

src_install() {
	cp -r opt usr "${ED}"
	mv "${ED}/usr/share/doc/${PN}" "${ED}/usr/share/doc/${PN}-${PV}"
	dosym "../../opt/${PN}/bin/bcp" "/usr/bin/bcp"
	dosym "../../opt/${PN}/bin/sqlcmd" "/usr/bin/sqlcmd"
}
