#!/bin/bash
# Compila Sonic 2 (RSDKv4) para navegador DENTRO de WSL (Linux), sin usar programas de Windows.
set -e
cd "$(dirname "$0")"

echo "=== 1/4 Emscripten (solo la primera vez) ==="
if [ ! -d "$HOME/emsdk" ]; then
  git clone https://github.com/emscripten-core/emsdk.git "$HOME/emsdk"
  (cd "$HOME/emsdk" && ./emsdk install latest && ./emsdk activate latest)
fi
source "$HOME/emsdk/emsdk_env.sh"

echo "=== 2/4 Archivos del juego ==="
if [ ! -f Data.rsdk ]; then
  echo "ERROR: no encuentro Data.rsdk en esta carpeta."
  exit 1
fi
mkdir -p wasm

MODFLAG=""
if [ -d mods ]; then
  echo "Mods encontrados:"
  for d in mods/*/; do
    if [ -f "${d}mod.ini" ]; then echo "   OK     $d"; else echo "   FALTA mod.ini en $d"; fi
  done
  MODFLAG="--preload-file mods"
else
  echo "No hay carpeta mods: se compila SIN mods."
fi

echo "=== 3/4 Compilando (tarda unos minutos) ==="
em++ -std=c++17 -O2 -ftrivial-auto-var-init=zero -fno-strict-aliasing -fwrapv \
  RSDKv4/Animation.cpp RSDKv4/Audio.cpp RSDKv4/Collision.cpp RSDKv4/Debug.cpp RSDKv4/Drawing.cpp \
  RSDKv4/Ini.cpp RSDKv4/Input.cpp RSDKv4/main.cpp RSDKv4/Math.cpp RSDKv4/Object.cpp RSDKv4/Palette.cpp \
  RSDKv4/PauseMenu.cpp RSDKv4/Reader.cpp RSDKv4/RetroEngine.cpp RSDKv4/RetroGameLoop.cpp RSDKv4/Scene.cpp \
  RSDKv4/Scene3D.cpp RSDKv4/Script.cpp RSDKv4/Sprite.cpp RSDKv4/String.cpp RSDKv4/Text.cpp RSDKv4/Userdata.cpp \
  -o wasm/index.js -lm --bind -s USE_SDL=2 -s USE_SDL_IMAGE=2 -s 'SDL2_IMAGE_FORMATS=["png"]' \
  -s USE_OGG=1 -s USE_VORBIS=1 -s TOTAL_MEMORY=60MB -s ALLOW_MEMORY_GROWTH=1 \
  -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=FS --preload-file Data.rsdk $MODFLAG

echo "=== 4/4 Pagina ==="
cp -f web/index.html wasm/index.html

echo
echo "=== LISTO === Los archivos quedaron en la carpeta wasm."
