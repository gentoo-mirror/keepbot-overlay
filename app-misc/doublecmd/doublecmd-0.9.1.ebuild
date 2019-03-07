# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils xdg-utils

DESCRIPTION="Cross Platform file manager."
HOMEPAGE="https://${PN}.sourceforge.io/"
SRC_URI="mirror://sourceforge/${PN}/doublecmd-${PV}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""
#IUSE="gtk qt4 qt5"
#REQUIRED_USE=" ^^ ( gtk qt4 qt5 )"
#	gtk? ( x11-libs/gtk+:2 )
#	qt5? ( >=dev-qt/qtcore-5.6
#	qt4? ( >=dev-qt/qtpascal-2.5 )

RESTRICT="strip"

DEPEND=">=dev-lang/lazarus-1.8"
RDEPEND="
	${DEPEND}
	sys-apps/dbus
	dev-libs/glib
	sys-libs/ncurses
	x11-libs/libX11
	x11-libs/gtk+:2
"

S="${WORKDIR}/doublecmd-${PV}"

src_prepare(){
	eapply_user

	# use gtk && export lcl="gtk2"
	export lcl="gtk2"
	# use qt4 && export lcl="qt"
	# use qt5 && export lcl="qt5"
	use amd64 && export CPU_TARGET="x86_64" || export CPU_TARGET="i386"

	export lazpath="/usr/share/lazarus"

	# if use qt4 ; then
	# 	cp /usr/lib/qt4/libQt4Pas.so plugins/wlx/WlxMplayer/src/
	# 	cp /usr/lib/qt4/libQt4Pas.so src/
	# fi

	# if use qt5 ; then
	# 	cp /usr/lib/qt4/libQt5Pas.so plugins/wlx/WlxMplayer/src/
	# 	cp /usr/lib/qt4/libQt5Pas.so src/
	# fi

	find ./ -type f -name "build.sh" -exec sed -i 's#$lazbuild #$lazbuild --lazarusdir=/usr/share/lazarus #g' {} \;
}

src_compile(){
	./build.sh beta || die
}

src_install(){
    pax-mark m ${PN}
	install/linux/install.sh --portable-prefix="build"
	newicon pixmaps/mainicon/colored/v4_4.png ${PN}.png
	diropts -m0755
	dodir "/opt"
    install/linux/install.sh --portable-prefix=build
    rsync -a "${S}/build/" "${D}/opt" || die "Unable to copy files"
	dosym "/opt/${PN}/${PN}" "/usr/bin/${PN}"
	make_desktop_entry ${PN} "Double Commander" "${PN}" "Utility;" || die "Failed making desktop entry!"
}

pkg_postinst() {
	xdg_desktop_database_update
    gnome2_icon_cache_update

	elog "Double Commander is successfully installed."
}

pkg_postrm() {
	xdg_desktop_database_update
    gnome2_icon_cache_update
}
