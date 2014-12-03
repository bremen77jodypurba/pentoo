# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

FFP_TARGETS="firefox"
inherit mozilla-addon

MOZ_ADDON_ID=6647
DESCRIPTION="A HTTP analyzer addon for Firefox"
HOMEPAGE="http://code.google.com/p/httpfox"
SRC_URI="http://addons.mozilla.org/firefox/downloads/latest/${MOZ_ADDON_ID} -> ${FFP_XPI_FILE}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

pkg_postinst() {
	ewarn "This ebuild installs the latest STABLE version !"
	ewarn "It is used by the maintainer to check for new versions ..."
}
