*! 03may2023  raraciborski
*! annotated descriptive statistics table code

version 17

/* Create a constant to use in making our totals over urban 
(n.b. as of writing this code, Stata will not let you label the first row with 
the total of the column variables without this step)
*/
generate toturb=1
label variable toturb "N (%)"

/* Update variable labels with summary statistics */
foreach var of varlist nvisits age income {
    local lbl : variable label `var'
    label variable `var' "`lbl', mean (SD)"
}

/* Update value labels */
label define ynpct 0 "No (%)" 1 "Yes (%)"
label values smhc pvehicle ynpct

/* Create Table 1 descriptives by urban/rural residence */
table (var) (urban), style(table-1) /// apply classic "Table 1" style
    stat(sum toturb) stat(percent toturb) /// 
    stat(mean nvisits) stat(sd nvisits)  /// mean & SD number of visits
    stat(fvpercent smhc) /// percent with & without mental healthcare
    stat(mean age income) stat(sd age income) /// mean & SD age and income
    stat(fvpercent pvehicle) /// percent with & without personal vehicle
    nformat(%3.1f mean sd percent fvpercent) /// format statistics as ###.#
    sformat("(%s)" sd) /// add () around SD
    sformat("%s%%" percent fvpercent) // add % sign to percentages

/* Save results */
collect export results/table1.docx, replace 