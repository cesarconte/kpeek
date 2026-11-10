#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Cesar <yugurta@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
# uninstall.sh: Desinstalador limpio de KPeek

set -eo pipefail

BIN_DIR="${HOME}/.local/bin"
APPS_DIR="${HOME}/.local/share/applications"
SERVICEMENUS_DIR="${HOME}/.local/share/kio/servicemenus"
DESKTOP_PLASMOID_DIR="${HOME}/.local/share/plasma/plasmoids/org.kde.desktopcontainment"

echo "==> Desinstalando KPeek..."

rm -f "${BIN_DIR}/kpeek"
rm -f "${SERVICEMENUS_DIR}/kpeek.desktop"
rm -f "${APPS_DIR}/io.github.iamandelib.kpeek.desktop"
rm -rf "${DESKTOP_PLASMOID_DIR}"

if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
fi

echo "✓ Desinstalación completada."
