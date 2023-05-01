# Gradescope-Utils

## NAME
EECS 490 Gradescope Utilities

## DESCRIPTION
Collection of scripts for gradescope stuff

Each file should contain its own documentation, which can be displayed by running `--help`

Originally a port of
<https://github.com/eecs490/Assignment-8-Gradescope>
during W22

## GETTING STARTED

First, to address a common concern:
Yes, most of the scripts are written in Perl.
But Gradescope-Utils (hereafter GU) does not presuppose Perl knowledge
any more than most scripts out there presuppose knowledge of their implementation details.
The extensional behavior of each script should be clear enough that--
barring bonafide bugs--
you should never *need* to read the source.
(You wouldn't notice if `cat` or `grep` were replaced with a Perl or Haskell implementation.)

Second, I realize this all seems rather complicated for what seems like a simple task.
But GU arose from a need; That is, GU *is* designed for a simple task.
Most scripts are half a terminal--
the job is just split over so many files so each step is well defined,
and so you can see how the data looks at each step.
Moreover, the modularity allows you to plug in your own scripts as the need arises.

## OVERVIEW
### bin
"types":

- **token2uniqname** is a json hash from (eg learn ocaml) tokens to uniqnames
- **submissions** is a json hash of student data, keyed by token

#### the main scripts, in approximate pipeline order:
##### join.pl : **zip** → [**token2uniqname**, **submissions**]
- stdin: n/a
- stdout: json pair of (**token2uniqname**, **submissions**)
- args: a Gradescope submissions export **zip**, and hooks to configure what ends up in **submissions**

##### split.pl : **token2uniqname** → **csv** → **submissions**
- stdin: **token2uniqname**
- stdout: **submissions**
- args: filepath to a **csv** (eg a sqlite dump),
and hooks to configure what ends up in **submissions**

comes with a wrapper to run each student in parallel, [`parallel.rb`](#parallelrb)

##### map.pl : **json hash** → **json hash**
- stdin: **json hash**
- stdout: **json hash** (with same keys)
- args: λ to run on each value

#### upload.pl : [**token2uniqname**, **submissions**] → ()
- stdin: json pair of (**token2uniqname**, **submissions**)
- stdout: debug messages
- args: Gradescope class and assignment ids

#### help utilities
##### id.pl : a → a
for testing
##### parallel.rb
##### singletonkv2scalar.pl : **json hash** → **json**
##### proj.pl : **json array** → **json**
##### grep.pl : **json hash** → **json hash**
##### mergekv.pl : **json hash**
##### json2string.pl
##### string2json.pl
##### csv2json.pl
##### field-n-eq? : **json array** → Bool

### lib

## SEE ALSO
