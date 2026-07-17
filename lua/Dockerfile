# Lua has no official Docker image, so build a minimal one on Debian.
# VERSION selects the Debian lua package (e.g. 5.4 -> lua5.4); the versions
# available depend on the VARIANT (Debian suite) chosen. Debian installs the
# interpreter as lua<VERSION>, so symlink it to a generic `lua`/`luac`.
FROM debian:${VARIANT}
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      lua${VERSION} luarocks \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /usr/bin/lua${VERSION} /usr/local/bin/lua \
 && ln -sf /usr/bin/luac${VERSION} /usr/local/bin/luac
WORKDIR /app

CMD ["bash"]
