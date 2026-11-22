#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Cesar <yugurta@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
# uninstall.sh: Desinstalador limpio de KPeek en /usr

set -eo pipefail

echo "==> Desinstalando KPeek de /usr..."

sudo -n rm -f /usr/bin/kpeek
sudo -n rm -f /usr/share/kio/servicemenus/kpeek.desktop
sudo -n rm -f /usr/share/applications/io.github.iamandelib.kpeek.desktop
sudo -n rm -f /usr/share/metainfo/io.github.iamandelib.kpeek.metainfo.xml
sudo -n rm -f /usr/share/icons/hicolor/scalable/apps/sc-apps-io.github.iamandelib.kpeek.svg

# Limpieza adicional de residuos previos en ~/.local si existieran
rm -f "${HOME}/.local/bin/kpeek"
rm -f "${HOME}/.local/share/kio/servicemenus/kpeek.desktop"
rm -f "${HOME}/.local/share/applications/io.github.iamandelib.kpeek.desktop"

if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
fi

echo "✓ Desinstalación completada de /usr."
