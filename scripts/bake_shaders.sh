#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

# Target GLSL levels (include modern desktop for Vulkan/GL); keep ES for mobile
GLSL_TARGETS="100 es,120,150,300 es,310 es,320 es,330,450,460"
# Extensions to bake (extend if new stages are added)
EXTS="vert frag geom comp tesc tese"

# Optional --force to bake even without staged shader changes
FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

# Skip if no staged shader source changes (pre-commit trigger)
if [[ $FORCE -eq 0 ]] && ! git diff --name-only --cached -- components/shaders | grep -E '\.(vert|frag|geom|comp|tesc|tese)$' >/dev/null 2>&1; then
  echo "[bake_shaders] No staged shader source changes; skipping."
  echo "[bake_shaders] Use --force to bake all shaders."
  exit 0
fi

# Detect SPIR-V support (older pyside6-qsb may not have --spirv)
QSB_SPIRV_FLAG=()
if pyside6-qsb --help 2>&1 | grep -q -- "--spirv"; then
  QSB_SPIRV_FLAG=(--spirv)
else
  echo "[bake_shaders] Note: pyside6-qsb lacks --spirv; baking GLSL only."
fi

bake() {
  local src="$1"
  local out="${src}.qsb"
  echo "[bake_shaders] Baking $src -> $out"
  # Emit GLSL; include SPIR-V when supported for Vulkan RHI
  pyside6-qsb "$src" -o "$out" --glsl "$GLSL_TARGETS" "${QSB_SPIRV_FLAG[@]}"
}

shopt -s nullglob
for ext in $EXTS; do
  for src in components/shaders/*."$ext"; do
    [ -f "$src" ] || continue
    bake "$src"
  done
done
shopt -u nullglob

echo "[bake_shaders] Done."

