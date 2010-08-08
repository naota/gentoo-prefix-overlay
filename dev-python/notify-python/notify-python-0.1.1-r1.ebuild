# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/notify-python/notify-python-0.1.1-r1.ebuild,v 1.15 2010/07/20 17:41:23 jer Exp $

EAPI="3"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
PYTHON_EXPORT_PHASE_FUNCTIONS="1"

inherit python

DESCRIPTION="Python bindings for libnotify"
HOMEPAGE="http://www.galago-project.org/"
SRC_URI="http://www.galago-project.org/files/releases/source/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-macos"
IUSE=""

RDEPEND=">=dev-python/pygtk-2.4.0
	>=x11-libs/libnotify-0.4.3"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9"
RESTRICT_PYTHON_ABIS="3.*"

src_prepare() {
	# Disable byte-compilation.
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile

	# Remove the old pynotify.c to ensure it's properly regenerated #212128.
	rm -f src/pynotify.c

	python_src_prepare
}

src_install() {
	python_src_install
	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	python_mod_optimize gtk-2.0/pynotify
}

pkg_postrm() {
	python_mod_cleanup gtk-2.0/pynotify
}
