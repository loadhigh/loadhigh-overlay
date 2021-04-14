# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# NOTE: The comments in this file are for instruction and documentation.
# They're not meant to appear with your final, production ebuild.  Please
# remember to remove them before submitting or committing your ebuild.  That
# doesn't mean you can't add your own comments though.

# The EAPI variable tells the ebuild format in use.
# It is suggested that you use the latest EAPI approved by the Council.
# The PMS contains specifications for all EAPIs. Eclasses will test for this
# variable if they need to use features that are not universal in all EAPIs.
# If an eclass doesn't support latest EAPI, use the previous EAPI instead.
EAPI=7
inherit rpm

# inherit lists eclasses to inherit functions from. For example, an ebuild
# that needs the eautoreconf function from autotools.eclass won't work
# without the following line:
#inherit autotools
#
# Eclasses tend to list descriptions of how to use their functions properly.
# Take a look at the eclass/ directory for more examples.

# Short one-line description of this package.
DESCRIPTION="Install sqlcmd and bcp the SQL Server command-line tools on Linux."
LICENSE="all-rights-reserved"

# Homepage, not used by Portage directly but handy for developer reference
HOMEPAGE="https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver15"

# Point to any required sources; these will be automatically downloaded by
# Portage.

MY_PV="$(ver_rs 4 '-')"
SRC_URI="https://packages.microsoft.com/rhel/8/prod/${PN}-${MY_PV}.x86_64.rpm"

SLOT="0"

S=${WORKDIR}

KEYWORDS="~amd64"

RDEPEND=">=dev-db/unixODBC-2.3.9"

