# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/hashed-storage/hashed-storage-0.4.13.ebuild,v 1.4 2010/07/20 13:46:00 josejx Exp $

EAPI=2

CABAL_FEATURES="bin lib profile haddock"
inherit haskell-cabal

DESCRIPTION="Hashed file storage support code."
HOMEPAGE="http://hackage.haskell.org/cgi-bin/hackage-scripts/package/hashed-storage"
SRC_URI="http://hackage.haskell.org/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-macos"
IUSE="test"

RDEPEND=">=dev-lang/ghc-6.10
		dev-haskell/binary
		dev-haskell/dataenc
		=dev-haskell/mmap-0.4*
		dev-haskell/mtl
		dev-haskell/zlib"
DEPEND=">=dev-haskell/cabal-1.6
		test? (
			dev-haskell/test-framework
			dev-haskell/test-framework-hunit
			dev-haskell/test-framework-quickcheck2
			dev-haskell/zip-archive
		)
		${RDEPEND}"

src_configure() {
	cabal_src_configure $(cabal_flag test)
}

src_install() {
	cabal_src_install

	rm "${ED}/usr/bin/hashed-storage-test" 2> /dev/null
	rmdir "${ED}/usr/bin" 2> /dev/null # only if empty
}
