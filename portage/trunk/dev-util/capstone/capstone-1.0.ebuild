# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: blshkv$

EAPI=5

inherit multilib

DESCRIPTION="A lightweight multi-platform, multi-architecture disassembly framework"
HOMEPAGE="http://www.capstone-engine.org/"
SRC_URI="http://www.capstone-engine.org/download/${PV}/${P}.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

#TODO: add java and python bindings

src_compile() {
	#https://github.com/aquynh/capstone/issues/51
	sed -e 's:$(PREFIX)/lib:$(PREFIX)/'"$(get_libdir)"':' -i Makefile
}

src_install() {
	emake DESTDIR="${D}" install
	dodir /usr/share/"${PN}"/
	cp -R "${S}/tests" "${D}/usr/share/${PN}/" || die "Install failed!"
	dodoc README
}