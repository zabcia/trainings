*! 03may2023  raraciborski
*! using predictive margins illustration

version 17

* cd "~/Documents/GitHub/trainings/herc23_margins"
use data/ruralmh, clear

/*
If you want to just view the results on your screen, use the code below
*/
// Estimate model 1
logit smhc ib1.urban i.pvehicle age transit distprov income, vce(robust)
estimates store m1

// What is the effect of living in a rural area?
margins, dydx(urban) vce(unconditional) 

// Estimate model 2, adding preferences
logit smhc ib1.urban i.pvehicle age transit distprov income pref, vce(robust)
est store m2

// What is the effect of living in a rural area?
margins, dydx(urban) vce(unconditional) 

/*
To create a table with the results, use this code. Notice that we can either
display one set of results or multiple
*/

// Estimate marginal effects and table 
margins, dydx(*) vce(unconditional) post    // n.b. model 2 is active!
est store NoOmitted

estimates restore m1
margins, dydx(*) vce(unconditional) post
est store Original

etable, estimates(Original) column(title) ///
    title(Average marginal effects and 95% confidence limits) ///
    center cstat(_r_b, nformat(%4.3f)) ///
    cstat(_r_ci, nformat(%4.3f) sformat("[%s]") cidelimiter(", ")) ///
    note(Incremental effects reported for categorical variables) ///
    export(results/margeff1.docx, replace)
   
etable, estimates(Base NoOmitted) column(estimates) ///
    title(Average marginal effects and 95% confidence limits) ///
    center cstat(_r_b, nformat(%4.3f)) ///
    cstat(_r_ci, nformat(%4.3f) sformat("[%s]") cidelimiter(", ")) ///
    note(Incremental effects reported for categorical variables) ///
    export(results/margeff2.docx, replace)



