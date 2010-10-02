# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/wine/wine-1.1.25.ebuild,v 1.13 2010/09/25 05:35:39 vapier Exp $

EAPI="2"

inherit eutils flag-o-matic multilib

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://source.winehq.org/git/wine.git"
	inherit git
	SRC_URI=""
	#KEYWORDS=""
else
	MY_P="${PN}-${PV/_/-}"
	SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"
	KEYWORDS="-* amd64 x86 ~x86-fbsd"
	S=${WORKDIR}/${MY_P}
fi

GV="0.9.1"
DESCRIPTION="free implementation of Windows(tm) on Unix"
HOMEPAGE="http://www.winehq.org/"
SRC_URI="${SRC_URI}
	gecko? ( mirror://sourceforge/wine/wine_gecko-${GV}.cab )"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="alsa cups custom-cflags dbus esd +gecko gnutls hal jack jpeg lcms ldap nas ncurses +opengl +oss png samba scanner ssl win64 +X xcomposite xinerama xml"
RESTRICT="test" #72375

RDEPEND=">=media-libs/freetype-2.0.0
	media-fonts/corefonts
	dev-lang/perl
	dev-perl/XML-Simple
	ncurses? ( >=sys-libs/ncurses-5.2 )
	jack? ( media-sound/jack-audio-connection-kit )
	dbus? ( sys-apps/dbus )
	gnutls? ( net-libs/gnutls )
	hal? ( sys-apps/hal )
	X? (
		x11-libs/libXcursor
		x11-libs/libXrandr
		x11-libs/libXi
		x11-libs/libXmu
		x11-libs/libXxf86vm
		x11-apps/xmessage
	)
	xinerama? ( x11-libs/libXinerama )
	alsa? ( media-libs/alsa-lib )
	esd? ( media-sound/esound )
	nas? ( media-libs/nas )
	cups? ( net-print/cups )
	opengl? ( virtual/opengl )
	jpeg? ( media-libs/jpeg )
	ldap? ( net-nds/openldap )
	lcms? ( =media-libs/lcms-1* )
	samba? ( >=net-fs/samba-3.0.25 )
	xml? ( dev-libs/libxml2 dev-libs/libxslt )
	scanner? ( media-gfx/sane-backends )
	ssl? ( dev-libs/openssl )
	png? ( media-libs/libpng )
	!win64? ( amd64? (
		X? (
			>=app-emulation/emul-linux-x86-xlibs-2.1
			>=app-emulation/emul-linux-x86-soundlibs-2.1
		)
		opengl? ( app-emulation/emul-linux-x86-opengl )
		app-emulation/emul-linux-x86-baselibs
		>=sys-kernel/linux-headers-2.6
	) )"
DEPEND="${RDEPEND}
	X? (
		x11-proto/inputproto
		x11-proto/xextproto
		x11-proto/xf86vidmodeproto
	)
	xinerama? ( x11-proto/xineramaproto )
	sys-devel/bison
	sys-devel/flex"

src_unpack() {
	if [[ $(( $(gcc-major-version) * 100 + $(gcc-minor-version) )) -lt 404 ]] ; then
		use win64 && die "you need gcc-4.4+ to build 64bit wine"
	fi

	if [[ ${PV} == "9999" ]] ; then
		git_src_unpack
	else
		unpack ${MY_P}.tar.bz2
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.1.15-winegcc.patch #260726
	epatch_user #282735
	sed -i '/^UPDATE_DESKTOP_DATABASE/s:=.*:=true:' tools/Makefile.in || die
	sed -i '/^MimeType/d' tools/wine.desktop || die #117785
}

src_configure() {
	export LDCONFIG=/bin/true

	use custom-cflags || strip-flags
	use amd64 && ! use win64 && multilib_toolchain_setup x86

	# XXX: should check out these flags too:
	#	audioio capi fontconfig freetype gphoto
	econf \
		--sysconfdir=/etc/wine \
		$(use_with alsa) \
		$(use_with cups) \
		$(use_with esd) \
		$(use_with gnutls) \
		$(! use dbus && echo --without-hal || use_with hal) \
		$(use_with jack) \
		$(use_with jpeg) \
		$(use_with lcms cms) \
		$(use_with ldap) \
		$(use_with nas) \
		$(use_with ncurses curses) \
		$(use_with opengl) \
		$(use_with oss) \
		$(use_with png) \
		$(use_with scanner sane) \
		$(use_with ssl openssl) \
		$(use_enable win64) \
		$(use_with X x) \
		$(use_with xcomposite) \
		$(use_with xinerama) \
		$(use_with xml) \
		$(use_with xml xslt) \
		|| die "configure failed"

	emake -j1 depend || die "depend"
}

src_compile() {
	emake all || die "all"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE AUTHORS README
	if use gecko ; then
		insinto /usr/share/wine/gecko
		doins "${DISTDIR}"/wine_gecko-${GV}.cab || die
	fi
}
