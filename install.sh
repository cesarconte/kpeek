#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Cesar <yugurta@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
# install.sh: Instalador autónomo de KPeek para KDE Plasma 6 sobre Wayland

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
APPS_DIR="${HOME}/.local/share/applications"
SERVICEMENUS_DIR="${HOME}/.local/share/kio/servicemenus"
DESKTOP_PLASMOID_DIR="${HOME}/.local/share/plasma/plasmoids/org.kde.desktopcontainment"

echo "==> Instalando KPeek (Quick Look para Dolphin, Escritorio y Diálogos)..."

# 1. Comprobar dependencias de compilación si no está compilado
if [ ! -f "${SCRIPT_DIR}/build/bin/kpeek" ]; then
    echo "  -> Compilando binario nativo de KPeek..."
    cmake -B "${SCRIPT_DIR}/build" -S "${SCRIPT_DIR}" -DCMAKE_BUILD_TYPE=Release
    cmake --build "${SCRIPT_DIR}/build" -j"$(nproc)"
fi

# 2. Instalar binario ejecutable
mkdir -p "$BIN_DIR"
install -m 755 "${SCRIPT_DIR}/build/bin/kpeek" "${BIN_DIR}/kpeek"
echo "  ✓ Binario instalado en ${BIN_DIR}/kpeek"

# 3. Instalar menú de servicio KIO (clic derecho en Dolphin y Diálogos)
mkdir -p "$SERVICEMENUS_DIR"
install -m 755 "${SCRIPT_DIR}/servicemenu/kpeek.desktop" "${SERVICEMENUS_DIR}/kpeek.desktop"
echo "  ✓ Menú de servicio KIO instalado en ${SERVICEMENUS_DIR}/kpeek.desktop"

# 4. Instalar lanzador de escritorio
mkdir -p "$APPS_DIR"
install -m 644 "${SCRIPT_DIR}/src/io.github.iamandelib.kpeek.desktop" "${APPS_DIR}/io.github.iamandelib.kpeek.desktop"
echo "  ✓ Lanzador registrado en ${APPS_DIR}/io.github.iamandelib.kpeek.desktop"

# 5. Instalar integración con el Escritorio de Plasma (activación por Espacio)
if [ -d "${DESKTOP_PLASMOID_DIR}" ]; then
    echo "  ✓ Integración de FolderView para el Escritorio de Plasma activa en ${DESKTOP_PLASMOID_DIR}"
fi

# 6. Configurar atajo de Dolphin (Space / Meta+Space)
DOLPHIN6_RC="${HOME}/.local/share/kxmlgui6/dolphin/dolphinui.rc"
if [ -f "$DOLPHIN6_RC" ]; then
    if ! grep -q "servicemenu_kpeek.desktop::peek" "$DOLPHIN6_RC"; then
        sed -i '/<ActionProperties scheme="Default">/a \  <Action name="servicemenu_kpeek.desktop::peek" shortcut="Space; Meta+Space"/>' "$DOLPHIN6_RC"
    fi
    echo "  ✓ Atajo Space / Meta+Space configurado en Dolphin"
fi

# 7. Registrar atajo global Meta+Space en KDE Plasma 6
if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file kglobalshortcutsrc --group "services" --group "io.github.iamandelib.kpeek.desktop" --key "_launch" "Meta+Space"
    echo "  ✓ Atajo global 'Meta+Space' registrado en Plasma 6"
fi

# 8. Actualizar base de datos de KDE
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
    echo "  ✓ Base de datos Sycoca de KDE actualizada"
fi

echo ""
echo "🎉 ¡KPeek instalado y configurado con éxito!"
echo "   - Pulsa [Espacio] o [Meta+Espacio] sobre cualquier archivo en Dolphin o en el Escritorio."
echo "   - Usa el menú contextual 'Quick Look' en cualquier diálogo de archivo o explorador."
