# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="aws-okta allows you to authenticate with AWS using your Okta credentials."
HOMEPAGE="https://github.com/segmentio/aws-okta"
EGIT_REPO_URI="https://github.com/segmentio/aws-okta.git"

EGIT_CLONE_TYPE="single"
EGIT_COMMIT="v${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"

DEPEND="
	>=dev-lang/go-1.13
	"

src_compile() {
	emake "dist/aws-okta-v${PV}-linux-amd64"
}

src_install() {
	newbin "dist/aws-okta-v${PV}-linux-amd64" aws-okta
}
