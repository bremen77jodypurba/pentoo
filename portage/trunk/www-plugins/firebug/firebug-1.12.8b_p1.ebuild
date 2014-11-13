# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit firefox-plugin

FFP_XPI_FILE="${P}"
FFP_XPI_FILEID="253590"
DESCRIPTION="Powerful web development tool for firefox"
HOMEPAGE="http://getfirebug.com"
SRC_URI="http://addons.mozilla.org/firefox/downloads/file/${FFP_XPI_FILEID} -> ${FFP_XPI_FILE}.xpi"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="|| (
	>=www-client/firefox-bin-23.0
	>=www-client/firefox-23.0
)"
DEPEND="${RDEPEND}"