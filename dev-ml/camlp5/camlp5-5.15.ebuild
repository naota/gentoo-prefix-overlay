# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ml/camlp5/camlp5-5.15.ebuild,v 1.1 2010/08/10 06:34:21 aballier Exp $

EAPI="2"

inherit multilib findlib

DESCRIPTION="A preprocessor-pretty-printer of ocaml"
HOMEPAGE="http://pauillac.inria.fr/~ddr/camlp5/"
SRC_URI="http://pauillac.inria.fr/~ddr/camlp5/distrib/src/${P}.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-macos"
IUSE="doc +ocamlopt"

DEPEND=">=dev-lang/ocaml-3.10[ocamlopt?]"
RDEPEND="${DEPEND}"

src_configure() {
	./configure \
		-prefix "${EPREFIX}"/usr \
		-bindir "${EPREFIX}"/usr/bin \
		-libdir "${EPREFIX}"/usr/$(get_libdir)/ocaml \
		-mandir "${EPREFIX}"/usr/share/man || die "configure failed"
}

src_compile(){
	emake -j1 || die "emake failed"
	if use ocamlopt; then
		emake -j1 opt || die "Compiling native code programs failed"
		emake -j1 opt.opt || die "Compiling native code programs failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	# findlib support
	local dir="$(ocamlfind printconf destdir)/${PN}"
	dir="${dir#${EPREFIX}}"
	insinto "${dir}"
	doins etc/META || die "failed to install META file for findlib support"

	use doc && dohtml -r doc/*

	dodoc CHANGES DEVEL ICHANGES README UPGRADING MODE
}
