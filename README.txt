README(1)                   EECS 490 Gradescope Utilities                   README(1)

NAME
       EECS 490 Gradescope Utilities

DESCRIPTION
       Collection of scripts for gradescope stuff

       Each file should contain its own documentation (the perl scripts will use POD,
       which can be read with "perldoc", or "./script-name --help")

       See OVERVIEW and EXAMPLES

       originally a port of <https://github.com/eecs490/Assignment-8-Gradescope>
       during W22

GETTING STARTED
       First, to address a common concern: Yes, most of the scripts are written in
       Perl.  But Gradescope-Utils (hereafter GU) was written with Perl-averseness
       and modularity in mind.  GU does not presuppose Perl knowledge, any more than
       most scripts out there presuppose knowledge of their implementation details.
       The extensional behavior of each script should be clear enough that-- barring
       straight up bugs-- you should never need to read the source, like how you
       wouldn't notice if "cat" or "grep" were replaced with a Perl or Haskell
       implementation.

       So new scripts can be written however one pleases-- I (hejohns) just happen to
       like Perl for text scripting.  Just make the behavior obvious, and the
       "--help" message sufficient.

       Second, I realize that this all seems rather complicated for what should be a
       simple task.  But as you might expect, GU arose from a need.  That is, GU is
       designed for a simple task.  Most scripts are a few lines-- the job is just
       split over so many files so you can see how the data looks at each step, and
       so you can plug in your own scripts when the need arises.

OVERVIEW
   bin
       The main scripts, in approximate pipeline order:

       join.pl : zip -> (json, json)
           csv is single csv of all submissions

           returns a json pair, (token2uniqname, submissions), where submissions is
           keyed by token

           Intended for converting a Gradescope submissions export into json

       csv2json : csv -> json
           "Text::CSV" wrapper that converts csv to key-value

           Intended for converting a csv token2uniqname into json, as an initial step
           for split.pl

       split.pl : (json, csv) -> json
           Takes token2uniqname json and splits csv into json key-value, keyed by
           token

           Intended for processing a csv database dump

       map.pl : json -> json
           This is where ``the real" processing is hooked in

       upload.pl : (json, json) -> ()
           Takes a json pair, (token2uniqname, submissions), and uploads to
           Gradescope

       proj.pl : json -> json
           0-indexed json array projection

       bundled lambdas

       field-n-eq?.pl : TODO
           split.pl

       misc utilities

       grep.pl : (json kv, regex) -> json kv

   lib
       Perl modules

   git submodules
       related scripts in other git repositories

       gradescope-late-days

DEPENDENCIES
       non-exhaustive list of external programs

   runtime
       unzip(1), curl(1), bat(1)

   build
       dzil(1)

SEE ALSO
       json_pp(1)

2023.04.23                         Gradescope-Utils                         README(1)
