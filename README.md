# Gradescope-Utils

## NAME
EECS 490 Gradescope Utilities

## DESCRIPTION
Suite of scripts for gradescope stuff

Each file should contain its own documentation, which can be displayed by running `CMD --help`

Originally a port of
<https://github.com/eecs490/Assignment-8-Gradescope>
in W22

## OVERVIEW
### `gu` wrapper
- `gu --help` brings up this README
- `gu --list` lists all provided scripts
- `gu CMD ARGS` calls `bin/CMD ARGS`
- `gu --version`
(`~/.local/bin` should already be in `$PATH`, but you may need to add it)

#### examples
- `gu map.pl -f gu -f singletonkv2scalar.pl < submissions.json`

### bin
"types":

- **token2uniqname** is a json hash from (eg learn ocaml) tokens to uniqnames
- **submissions** is a json hash of student data, keyed by token

#### the main scripts, in approximate pipeline order:
##### join.pl : **zip** → [**token2uniqname**, **submissions**]
##### split.pl : **token2uniqname** → **csv** → **submissions**
##### map.pl : **json hash** → **json hash**
- stdin: **json hash**
- stdout: **json hash** (with same keys)
- args: λ to run on each value

##### upload.pl : [**token2uniqname**, **submissions**] → ()
#### helper utilities/λs
see `gu --list`

### lib
TODO: document ./lib/

## GETTING STARTED
### basic idea
This is a collection of combinators for processing (primarily json and csv) grading data.
Generally, each combinator should do *one* simple task, reading from stdin and writing to stdout.
This allows you to (post-)compose combinators to modularly build up your full script.
### installing
You don't *need* to install these scripts-- just `git clone` and relative path everything--,
but there is a convenience wrapper.

The two commands are
`make install`
or `make install-lite`.
This installs a wrapper `gu` to `~/.local/bin`.
See OVERVIEW.

`make install` builds everything, which requires **a lot** of dependencies.
You probably want to `make install-lite` which uses the included tarball.

You may need to install cpan modules as you go-- whenever you get the "you may need to install the FOO::BAR module" message.
`make install-runtime-deps` installs some of the runtime dependencies.
## BUGS
Please raise issues on the [github](https://github.com/eecs490/gradescope-utils)
or email [hejohns@umich.edu](mailto:hejohns@umich.edu)
## SEE ALSO
