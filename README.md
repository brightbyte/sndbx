# run

Docker-based helper for quickly spinning up a throwaway environment for running
code in a given language, version, and base-image variant. Each supported
language has its own directory (`golang`, `python`, `php`, ...) holding a
`Dockerfile` and a small `config` of defaults; `run` builds the image on first
use (caching it) and starts a container with your code mounted at `/app`.

## Usage

```bash
run <language> [target-dir] [docker-run-args...]
```

- `language` — one of the language directory names (`golang`, `python`, `php`).
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

`rungo`, `runpy`, and `runphp` are thin wrappers that call `run` with the
language pre-selected:

```bash
VERSION=1.26 rungo path/to/code --network=host   # == run go ...
VERSION=3.13 runpy path/to/code
VERSION=8.2  runphp path/to/code
```

## Default versions

Each language directory has a `version` file with the defaults to build when no
`VERSION`/`VARIANT` is given. Bump these to track new upstream releases; review
them all at once with `cat */version`. Example (`golang/version`):

```bash
VERSION=1.26
VARIANT=trixie   # leave empty for languages with no variant axis (e.g. php)
```

## Adding a language

Create a directory with:

- `Dockerfile` — using `${VERSION}` and (optionally) `${VARIANT}` placeholders.
  Extra files in the directory are part of the build context, so the Dockerfile
  can `COPY` in helper scripts.
- `version` — default `VERSION` and `VARIANT` (see above).
- `config` — structural metadata, sourced by `run`:

  ```bash
  RUN_AS_USER=1  # 1: run as host uid:gid with HOME=/app; 0: leave to image
  ```

The directory name is the language name passed to `run`. Add a wrapper (like
`rungo`) if you want a short command.
