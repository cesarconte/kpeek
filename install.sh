#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Cesar <yugurta@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
# install.sh: Instalador de KPeek para KDE Plasma 6 sobre Wayland (instalación estricta en /usr)

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Instalando KPeek (Quick Look para Dolphin, Escritorio y Diálogos) en /usr..."

# Limpiar cualquier instalación residual previa en ~/.local para evitar shadowing
rm -f "${HOME}/.local/bin/kpeek"
rm -f "${HOME}/.local/share/applications/io.github.iamandelib.kpeek.desktop"
rm -f "${HOME}/.local/share/kio/servicemenus/kpeek.desktop"

# 1. Compilar e instalar en /usr
cmake -B "${SCRIPT_DIR}/build" -S "${SCRIPT_DIR}" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
cmake --build "${SCRIPT_DIR}/build" -j"$(nproc)"
sudo -n cmake --install "${SCRIPT_DIR}/build" --prefix /usr

# 2. Configurar atajo de Dolphin (Space / Meta+Space) y liberar Espacio de toggle_selection_mode
for DOLPHIN_RC in "${HOME}/.local/share/kxmlgui5/dolphin/dolphinui.rc" "${HOME}/.local/share/kxmlgui6/dolphin/dolphinui.rc"; do
    if [ -f "$DOLPHIN_RC" ] && grep -q '<ActionProperties scheme="Default">' "$DOLPHIN_RC"; then
        if ! grep -q 'name="toggle_selection_mode"' "$DOLPHIN_RC"; then
            sed -i '/<ActionProperties scheme="Default">/a \  <Action name="toggle_selection_mode" shortcut=""/>' "$DOLPHIN_RC"
        fi
        if ! grep -q "servicemenu_kpeek.desktop::peek" "$DOLPHIN_RC"; then
            sed -i '/<Action name="toggle_selection_mode" shortcut=""\/>/a \  <Action name="servicemenu_kpeek.desktop::peek" shortcut="Space; Meta+Space"/>' "$DOLPHIN_RC"
        fi
    fi
done
echo "  ✓ Atajo Space / Meta+Space configurado en Dolphin"

# 3. Registrar atajo global Meta+Space en KDE Plasma 6
if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file kglobalshortcutsrc --group "services" --group "io.github.iamandelib.kpeek.desktop" --key "_launch" "Meta+Space"
    echo "  ✓ Atajo global 'Meta+Space' registrado en Plasma 6"
fi

# 4. Actualizar base de datos de KDE
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
    echo "  ✓ Base de datos Sycoca de KDE actualizada"
fi

echo ""
echo "🎉 ¡KPeek instalado y configurado con éxito en /usr!"
