# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/coq/coq-8.2_p1-r1.ebuild,v 1.7 2010/04/09 10:34:41 aballier Exp $

EAPI="2"

inherit eutils multilib

MY_PV="${PV/_p/pl}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Coq is a proof assistant written in O'Caml"
HOMEPAGE="http://coq.inria.fr/"
SRC_URI="http://coq.inria.fr/distrib/V${MY_PV}/files/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-macos"
IUSE="norealanalysis gtk debug +ocamlopt doc"

RDEPEND=">=dev-lang/ocaml-3.10[ocamlopt?]
	>=dev-ml/camlp5-5.09[ocamlopt?]
	gtk? ( >=dev-ml/lablgtk-2.10.1[ocamlopt?] )"
DEPEND="${RDEPEND}
	doc? (
		media-libs/netpbm[png]
		virtual/latex-base
		dev-tex/hevea
		dev-tex/xcolor
		|| ( dev-texlive/texlive-pictures app-text/ptex )
		|| ( dev-texlive/texlive-mathextra app-text/ptex )
		)"

S="${WORKDIR}/${MY_P}"

src_configure() {
	ocaml_lib=`ocamlc -where`
	local myconf="--prefix ${EPREFIX}/usr
		--bindir ${EPREFIX}/usr/bin
		--libdir ${EPREFIX}/usr/$(get_libdir)/coq
		--mandir ${EPREFIX}/usr/share/man
		--emacslib ${EPREFIX}/usr/share/emacs/site-lisp
		--coqdocdir ${EPREFIX}/usr/$(get_libdir)/coq/coqdoc
		--docdir ${EPREFIX}/usr/share/doc/${PF}
		--camlp5dir ${ocaml_lib}/camlp5
		--lablgtkdir ${ocaml_lib}/lablgtk2"

	use debug && myconf="--debug $myconf"
	use norealanalysis && myconf="$myconf --reals no"
	use norealanalysis || myconf="$myconf --reals all"
	use doc || myconf="$myconf --with-doc no"

	if use gtk; then
		use ocamlopt && myconf="$myconf --coqide opt"
		use ocamlopt || myconf="$myconf --coqide byte"
	else
		myconf="$myconf --coqide no"
	fi
	use ocamlopt || myconf="$myconf -byte-only"
	use ocamlopt && myconf="$myconf --opt"

	export CAML_LD_LIBRARY_PATH="${S}/kernel/byterun/"
	./configure $myconf || die "configure failed"
}

src_compile() {
	emake STRIP="true" -j1 || die "make failed"
}

src_install() {
	emake STRIP="true" COQINSTALLPREFIX="${D}" install || die
	dodoc README CREDITS CHANGES

	use gtk && domenu "${FILESDIR}/coqide.desktop"
}
