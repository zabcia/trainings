*! 13jun2023  raraciborski
*! Control do-file used to produce results for HERC margins talk

/* 
Using these do-files:
These files should be executed in their entirety. Because they rely on local
macros that are defined at the beginning of the programs, you may get 
unexpected results if you try to run them by highlighting a section and just
running that piece or by copying and pasting code into the Command window.
*/

version 17      
/* 
The -version- command here means this do-file was written in Stata 
Version 17 & if it is run in a later version, Stata will continue to interpret 
commands as if it is running Version 17. 

Version 17 is required to run the Table 1 example, but otherwise you can
set back to  
*/

/* 
You must either (1) save the downloaded do-files in folders named the same 
as mine or (2) change the -cd- command below to reference where you saved the
files.
*/
cd "~/Documents/GitHub/trainings/herc23_margins"

/*
Did you know: Stata runs on Windows, Mac, and Linux. Using the "/" is 
compatible across all operating systems and makes your code easier for others
to use.

Did you know: The "~" is a shortcut for your home directory. Your home 
directory is set by the operating system, not Stata. In general, this is where
Stata opens on your computer unless you customized the location.
*/

// Create dataset used in examples
quietly do data/mkdata

// Make "Table 1" descriptive statistics
quietly do examples/1-make_table1

// Create linear model marginal effects and predictive margins examples
/* 
Throughout this next do-file, you'll see variables entered into the model using
factor variable notation. If you aren't familiar with this Stata syntax, 
    - i.varname         use an indicator for each level, omitting 1st
    - ib#.varname       as above, but omit the value # as the reference category
    - c.varname         treat varname as continuous in an interaction
    - i.var1##c.var2    include main effects for var1 and var2 along with their
                        interaction

Type . help fvvarlist to learn more.
*/
do examples/2-linear

// Create linear model marginal effects and predictive margins examples
do examples/3-nonlinear

// Make revised "Table 1" descriptive statistics
quietly do examples/4-make_table1b

// Complete predictive margins examples
do examples/5-logit_predmarg

// Complete marginal (incremental) effects examples
do examples/6-logit_margeff
