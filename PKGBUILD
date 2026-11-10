# Maintainer: Cesar <yugurta@gmail.com>
# Contributor: CachyOS Linux Architect Team

pkgname=kpeek
pkgver=1.1.0
pkgrel=1
pkgdesc="macOS Quick Look previewer for KDE Plasma 6 (Dolphin, Desktop and File Dialogs) with Spacebar trigger"
arch=('x86_64')
url="https://github.com/cesarconte/kpeek"
license=('GPL-2.0-or-later')
depends=(
    'glibc'
    'kconfig'
    'kcoreaddons'
    'kcrash'
    'kdbusaddons'
    'ki18n'
    'kio'
    'kirigami'
    'kirigami-addons'
    'libarchive'
    'qt6-base'
    'qt6-declarative'
    'qt6-multimedia'
    'qt6-svg'
)
makedepends=(
    'cmake'
    'extra-cmake-modules'
    'ninja'
)
optdepends=(
    'dolphin: KDE file manager integration'
    'libreoffice: Office document conversion support'
    'poppler-qt6: High-fidelity PDF rendering'
)
source=("kpeek::git+file://${startdir}#branch=main")
sha256sums=('SKIP')

build() {
    cmake -B build -S "${srcdir}/${pkgname}" \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DBUILD_TESTING=OFF

    cmake --build build
}

package() {
    DESTDIR="${pkgdir}" cmake --install build
}
