# Shared by run and build; sourced, not executed.
#
# resolve_language <language> sets DIR, LANG_DIR, VERSION, VARIANT, TAG,
# IMAGE and RUN_AS_USER for a language directory next to this file.

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { echo "$(basename "$0"): $*" >&2; exit 1; }

# A language is any sibling directory that contains a Dockerfile.
list_languages() {
  local d
  for d in "$HERE"/*/; do
    [ -f "$d/Dockerfile" ] && basename "$d"
  done
}

resolve_language() {
  LANG_DIR="$1"
  DIR="$HERE/$LANG_DIR"
  [ -f "$DIR/Dockerfile" ] || die "unknown language '$LANG_DIR' (try: $(list_languages | paste -sd' ' -))"

  # Per-language settings live in config: the VERSION/VARIANT image defaults and
  # RUN_AS_USER. Remember any VERSION/VARIANT from the environment first, source
  # config, then let the environment values take precedence over the file's.
  local env_version="${VERSION-}"
  local env_variant="${VARIANT-}"
  RUN_AS_USER=1
  [ -f "$DIR/config" ] && . "$DIR/config"
  VERSION="${env_version:-${VERSION-}}"
  VARIANT="${env_variant:-${VARIANT-}}"

  [ -n "${VERSION:-}" ] || die "no version for '$LANG_DIR' (set VERSION, or add it to $DIR/config)"

  # Image tag encodes the axes that vary. Languages without a variant (php) tag by
  # version alone.
  if [ -n "${VARIANT:-}" ]; then
    TAG="$VERSION-$VARIANT"
  else
    TAG="$VERSION"
  fi
  IMAGE="run-$LANG_DIR:$TAG"
}
