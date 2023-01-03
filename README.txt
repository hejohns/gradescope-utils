README(1)                   EECS 490 Gradescope Utilities                   README(1)

NAME
       EECS 490 Gradescope Utilities

DESCRIPTION
       Collection of scripts for gradescope stuff

       Each file should contain its own documentation

       Below is just a overview

       originally a port of <https://github.com/eecs490/Assignment-8-Gradescope>
       during W22

   bin
       The main scripts, in pipeline order:

       join.pl : gradescope submissions zip X json
           csv is single csv of all submissions

       split : csv X json
       csv2json : (json, csv) X json
       split.pl : csv X several csv s
           takes csv of all submissions and splits it per student, with processing
           hooks

       upload.pl : several csv s X (on gradescope)
           uploads a directory of submissions (actually not necessarily csv)

       normal workflows go through all three, but eg workflows with student
       submissions from non-gradescope can start at split.pl

   lib
       Perl modules

SEE ALSO
       json_pp(1)

Fall 2022                             2022-09-24                            README(1)
