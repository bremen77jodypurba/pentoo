# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Next generation web scanner, identifies what software websites are running"
HOMEPAGE="http://www.morningstarsecurity.com/research/whatweb"
SRC_URI="http://www.morningstarsecurity.com/downloads/${P}.tar.gz"
RESTRICT="fetch"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="json"

DEPEND="dev-lang/ruby"
RDEPEND="${DEPEND}
	json? ( dev-ruby/json )"

#future rdepend:
#dns: em-resolv-replace 
#mongodb: bison bson_ext mongo rchardet

pkg_nofetch(){
	einfo "${P} must be downloaded manually!"
	einfo "Run the following command to download it to /usr/portage/distfiles:"
	einfo "###"
	einfo "wget -U Mozilla -O /usr/portage/distfiles/${P}.tar.gz ${SRC_URI}"
	einfo "###"
	einfo
	einfo "For details, see https://code.google.com/p/pentoo/issues/detail?id=62"
}

src_prepare() {
	# fix install
	sed -i 's|plugins-disabled||g' Makefile || die
	sed -i 's|$(DOCPATH)/$(NAME)|$(DOCPATH)/${PF}|g' Makefile || die
	sed -i -e 's:#!/usr/bin/env ruby:#!/usr/bin/env ruby18:' whatweb || die
}

src_compile() {
	# do nothing
	true
}

src_install() {
	dodir /usr/share/doc/"${PF}"
	DESTDIR="${D}" emake install || die "install failed"
	dodoc CHANGELOG README TODO whatweb.xsl || die
}