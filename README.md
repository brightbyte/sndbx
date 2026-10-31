# run

Docker-based helper for quickly spinning up a throwaway environment for running
code in a given language, version, and base-image variant. Each supported
language has its own directory (`golang`, `python`, `php`, ...) holding a
`Dockerfile` and a small `config` of defaults; `run` builds the image on first
use (caching it, via `build`) and starts a container with your code mounted at
`/app`. `build <language>` rebuilds the image unconditionally, e.g. after
editing a Dockerfile; it takes the same `VERSION`/`VARIANT` variables. Both
scripts share `lib.sh`.

## Usage

```bash
run <language> [target-dir] [docker-run-args...]
```

- `language` — one of the language directory names (`golang`, `python`, `php`,
  `node`, `ruby`, `lua`).
- `target-dir` — directory to mount at `/app` (defaults to the current dir).
  A leading argument starting with `-` is passed straight to `docker run`.
- Anything after the target is forwarded to `docker run`.

Two environment variables select what to build:

- `VERSION` — runtime version, e.g. `1.26` (default: per-language).
- `VARIANT` — base-image variant/suite, e.g. `trixie` (default: per-language;
  some languages, like php, have no variant axis).

Example:

```bash
VERSION=1.26 VARIANT=trixie run go path/to/code --network=host
```

## Convenience wrappers

`rungo`, `runpy`, `runphp`, `runnode`, `runruby`, and `runlua` are thin wrappers
that call `run` with the language pre-selected:

```bash
VERSION=1.26 rungo path/to/code --network=host   # == run golang ...
VERSION=3.13 runpy path/to/code
VERSION=8.2  runphp path/to/code
VERSION=24   runnode path/to/code
VERSION=3.4  runruby path/to/code
VERSION=5.4  runlua path/to/code
```

## Default versions

Each language directory has a `config` file holding the `VERSION`/`VARIANT`
defaults to build when none are given in the environment. Bump these to track
new upstream releases; review them all at once with `grep -H '^VERSION' */config`.
Example (`golang/config`):

```bash
VERSION=1.26
VARIANT=trixie   # leave empty for languages with no variant axis (e.g. php)
RUN_AS_USER=1    # 1: run as host uid:gid with HOME=/app; 0: leave to image
```

To see what to bump them to, `latest` lists recent registry tags in the shape
each language actually uses (repo and tag template are derived from the
`Dockerfile` FROM line, so nothing extra to configure):

```bash
./latest            # all languages
./latest golang php # just these
```

Note: lua is built `FROM debian`, so `latest` lists its Debian suites (the
variant axis); the lua version itself comes from that suite's apt packages.

## Adding a language

Create a directory with:

- `Dockerfile` — using `${VERSION}` and (optionally) `${VARIANT}` placeholders.
  Extra files in the directory are part of the build context, so the Dockerfile
  can `COPY` in helper scripts.
- `config` — settings sourced by `run`:

  ```bash
  VERSION=1.26   # default version (env VERSION overrides)
  VARIANT=trixie # default variant; leave empty for no variant axis
  RUN_AS_USER=1  # 1: run as host uid:gid with HOME=/app; 0: leave to image
  ```

The directory name is the language name passed to `run`. Add a wrapper (like
`rungo`) if you want a short command.
