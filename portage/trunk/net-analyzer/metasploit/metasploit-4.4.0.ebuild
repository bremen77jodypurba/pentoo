# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/metasploit/metasploit-4.3.0.ebuild,v 1.2 2012/06/08 09:28:04 patrick Exp $

EAPI="4"
inherit eutils

MY_P=${PN/metasploit/framework}-${PV}

MTSLPT_REV=${BASH_REMATCH[2]}

SRC_URI="http://downloads.metasploit.com/data/releases/framework-${PV}.tar.bz2"

#https://dev.metasploit.com/redmine/attachments/download/906/vbsmem-1.2.1.patch
#	https://dev.metasploit.com/redmine/attachments/1200/jboss_seam_remote_command_rb"

DESCRIPTION="Advanced open-source framework for developing, testing, and using vulnerability exploit code"
HOMEPAGE="http://www.metasploit.org/"
SLOT="4.4"
LICENSE="BSD"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="+armitage gui +kissfft lorcon lorcon2 +pcaprub +postgres serialport"

REQUIRED_USE="armitage? ( postgres )"

# Note we use bundled gems (see data/msfweb/vendor/rails/) as upstream voted for
# such solution, bug #247787
RDEPEND="dev-lang/ruby[ssl]
	dev-ruby/rubygems
	>=app-crypt/johntheripper-1.7.9-r1[-minimal]
	!arm? ( dev-ruby/hpricot
		gui? ( virtual/jre )
		dev-ruby/rjb
		>=dev-ruby/msgpack-0.4.6
		>=dev-ruby/json-1.6.6
		>=dev-ruby/nokogiri-1.5.2 )
	postgres? ( dev-db/postgresql-server
		!arm? ( >=dev-ruby/pg-0.13.2
		>=dev-ruby/activerecord-3.2.2[postgres] ) )
	pcaprub? ( net-libs/libpcap )
	armitage? ( net-analyzer/nmap )
	lorcon? ( net-wireless/lorcon-old )
	lorcon2? ( net-wireless/lorcon )"
DEPEND="app-admin/eselect-metasploit"

RESTRICT="strip"

QA_EXECSTACK="
	usr/$(get_libdir)/${PN}${SLOT}/data/meterpreter/msflinker_linux_x86.bin"
QA_WX_LOAD="
	usr/$(get_libdir)/${PN}${SLOT}/data/templates/template_*_linux.bin"
QA_PREBUILT="
	usr/$(get_libdir)/${PN}${SLOT}/data/meterpreter/ext_server_sniffer.lso
	usr/$(get_libdir)/${PN}${SLOT}/data/meterpreter/ext_server_networkpug.lso
	usr/$(get_libdir)/${PN}${SLOT}/data/meterpreter/ext_server_stdapi.lso
	usr/$(get_libdir)/${PN}${SLOT}/data/templates/template_x86_solaris.bin
	usr/$(get_libdir)/${PN}${SLOT}/data/templates/template_x86_bsd.bin"

S=${WORKDIR}/msf3

src_prepare() {
	rm "${S}"/msfupdate
	use gui || rm msfgui
}

src_compile() {
	if use pcaprub; then
		cd "${S}"/external/pcaprub
		ruby extconf.rb
		emake
	fi
	if use kissfft; then
		cd "${S}"/external/ruby-kissfft
		ruby extconf.rb
		emake
	fi
	if use lorcon; then
		cd "${S}"/external/ruby-lorcon
		ruby extconf.rb
		emake
	fi
	if use lorcon2; then
		cd "${S}"/external/ruby-lorcon2
		ruby extconf.rb
		emake
	fi
	if use serialport; then
		cd "${S}"/external/serialport
		ruby extconf.rb
		emake
	fi
}

src_install() {
	# should be as simple as copying everything into the target...
	dodir /usr/$(get_libdir)/${PN}${SLOT}
	cp -R "${S}"/* "${ED}"/usr/$(get_libdir)/${PN}${SLOT} || die "Copy files failed"
	rm -Rf "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/documentation "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/README.md "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/THIRD-PARTY.md || die
	fowners -R root:0 /

	# do not remove LICENSE, bug #238137
	dodir /usr/share/doc/${PF}
	cp -R "${S}"/{documentation,README.md,THIRD-PARTY.md} "${ED}"/usr/share/doc/${PF} || die
	dosym /usr/share/doc/${PF}/documentation /usr/$(get_libdir)/${PN}${SLOT}/documentation

	#handled by metasploit eselect now
	#dodir /usr/bin/
	#for file in msf*; do
	#	dosym /usr/$(get_libdir)/${PN}${SLOT}/${file} /usr/bin/${file}
	#done

	newinitd "${FILESDIR}"/msfrpcd.initd msfrpcd${SLOT}
	newconfd "${FILESDIR}"/msfrpcd.confd msfrpcd${SLOT}

	# Avoid useless revdep-rebuild trigger #377617
	dodir /etc/revdep-rebuild/
	echo "SEARCH_DIRS_MASK=\"/usr/lib*/${PN}${SLOT}/data/john\"" > \
		"${ED}"/etc/revdep-rebuild/70-${PN}${SLOT}

	if use armitage; then
		echo -e "#!/bin/sh \n\nexport MSF_DATABASE_CONFIG=/usr/$(get_libdir)/${PN}${SLOT}/armitage.yml\n" > armitage
		echo -e "java -Xmx256m -jar /usr/$(get_libdir)/${PN}${SLOT}/data/armitage/armitage.jar \$* &\n" >> armitage
		dobin armitage
		insinto /usr/$(get_libdir)/${PN}${SLOT}/
		doins  "${FILESDIR}"/armitage.yml
	fi

	if use pcaprub; then
		cd "${S}"/external/pcaprub
		emake DESTDIR="${ED}" install
	fi
	if use lorcon; then
		cd "${S}"/external/ruby-lorcon
		emake DESTDIR="${ED}" install
	fi
	if use lorcon2; then
		cd "${S}"/external/ruby-lorcon2
		emake DESTDIR="${ED}" install
	fi
	if use kissfft; then
		cd "${S}"/external/ruby-kissfft
		emake DESTDIR="${ED}" install
	fi
	if use serialport; then
		cd "${S}"/external/serialport
		emake DESTDIR="${ED}" install
	fi

	#unbundle johntheripper, it makes me sick to have to do this...
	rm -rf "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/data/john/run.*
	dodir /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.any
	for i in $(ls -1 "${ROOT}"/etc/john); do
		dosym /etc/john/${i} /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.any/${i}
	done
	dosym /usr/sbin/unique /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.any/unique
	dosym /usr/sbin/john /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.any/john
	dosym /usr/sbin/unafs /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.any/unafs
	dosym /usr/sbin/genmkvpwd /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.any/genmkvpwd
	dosym /usr/sbin/john-mailer /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.any/john-mailer
	dosym /usr/sbin/undrop /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.any/undrop
	dosym /usr/sbin/unshadow /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.any/unshadow
	dosym /usr/sbin/tgtsnarf /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.any/tgtsnarf
	dosym /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.any /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x64.mmx
	dosym /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.any /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.mmx
	dosym /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.any /usr/$(get_libdir)/${PN}${SLOT}/data/john/run.linux.x86.sse2

	#unbundle the key ruby gems and the ones which install binaries so we don't have to allow (more) QA violations
	rm -rf "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/lib/gemcache/ruby/1.9.1/arch
	rm -rf "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/lib/gemcache/ruby/1.9.1/arch-old
	rm -rf "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/lib/gemcache/ruby/1.9.1/specifications/activerecord-*.gemspec
	rm -rf "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/lib/gemcache/ruby/1.9.1/specifications/msgpack-*.gemspec
	rm -rf "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/lib/gemcache/ruby/1.9.1/specifications/json-*.gemspec
	rm -rf "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/lib/gemcache/ruby/1.9.1/specifications/nokogiri-*.gemspec
	rm -rf "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/lib/gemcache/ruby/1.9.1/specifications/pg-*.gemspec
	rm -rf "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/lib/gemcache/ruby/1.9.1/gems/activerecord*
	rm -rf "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/lib/gemcache/ruby/1.9.1/gems/msgpack*

	#force to use the outdated bundled version of metasm
	doenvd "${FILESDIR}"/91metasploit

	#while we are commiting fixes for filth, let's bogart msfupdate
#	echo "#!/bin/sh" > "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/msfupdate
#	echo "echo \"[*]\"" >> "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/msfupdate
#	echo "echo \"[*] Attempting to update the Metasploit Framework...\"" >> "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/msfupdate
#	echo "echo \"[*]\"" >> "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/msfupdate
#	echo "echo \"\"" >> "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/msfupdate
#	echo "ESVN_REVISION=HEAD emerge --oneshot \"=${CATEGORY}/${PF}\"" >> "${ED}"/usr/$(get_libdir)/${PN}${SLOT}/msfupdate

	use gui &&	make_desktop_entry msfgui${SLOT} \
			"Metasploit Framework" \
			metasploit \
			'GNOME;System;Network;' &&
		doicon "${FILESDIR}"/metasploit.icon
}

pkg_postinst() {
	"${EROOT}"/usr/bin/eselect metasploit set --use-old ${PN}${SLOT}

	if use postgres; then
		elog "You need to prepare the database as described on the following page:"
		elog "https://community.rapid7.com/docs/DOC-1268"
	fi

	elog "Adjust /usr/$(get_libdir)/${PN}${SLOT}/armitage.yml and /etc/conf.d/msfrpcd${PV} files if necessary"
	if use eselect; then
		elog
		elog "To switch between installed slots, execute as root:"
		elog " # eselect metasploit set [slot number]"
	fi
	elog "You might need to run env-update and relogin"
	elog
}
