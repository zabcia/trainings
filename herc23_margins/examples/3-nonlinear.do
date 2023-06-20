*! 03may2023  raraciborski
*! marginal effects & predictive margins for linear models: introduction

version 17
adopath + ./tools

clear
use data/ruralmh

// Graphics options to apply to all graphs below (slide theme)
local gopts xsize(6.1) ysize(5.4) graphregion(fcolor("231 230 230")) ///
    title(, span color("51 63 80") margin(medium)) ///
    subtitle(, span color("51 63 80")) ///
    ytitle(, color("51 63 80") margin(medsmall)) ///
    ylabel(, labcolor("51 63 80")) ///
    xtitle(, color("51 63 80") margin(medsmall)) ///
    xlabel(, labcolor("51 63 80")) ///
    caption(, color("51 63 80") ring(1) span size(*0.9)) ///
    note("*simulated data*", color("51 63 80") position(5) ring(2) size(*0.75))
    
// -marginsplot- options
local popts mlabel(_margin) mlabgap(small)

/*** Marginal and incremental effects more important for nonlinear models ***/
/* Let's try fitting our original linear model for visits as a Poisson count 
   model instead */
poisson nvisits c.age ib1.urban i.pvehicle
* writeif, cformat(%5.4f)
margins, dydx(age)

// varies over age even if age isn't interacted with anything
margins, dydx(age) at(age=(20(10)70))
marginsplot, name(poisson_at, replace) `gopts' xscale(range(15 75)) ///
    plotopts(`popts' mlabpos(4) mlabf(%5.4f)) 
    
// and differs by rural vs urban even though there is no interaction there!
margins, dydx(age) at(age=(20(10)70)) by(urban)
marginsplot, name(poisson_at_urban, replace) `gopts' xscale(range(15 75)) ///
    plotopts(`popts' mlabpos(4) mlabf(%5.4f) color(%70)) ciopts(color(%50)) ///
    plot2opts(pstyle(p4)) ci2opts(pstyle(p4)) ///
    legend(order(3 "Rural" 4 "Urban"))
    
/* You can see the functional relationship by plotting the predicted 
   (i.e. adjusted mean) outcome. */
margins, at(age=(20(10)70)) by(urban)
marginsplot, name(yhat_age, replace) `gopts' xscale(range(15 70)) ///
    ylabel(0(0.5)3) ///
    plotopts(`popts' mlabpos(7) mlabf(%3.2f)) ///
    plot2opts(pstyle(p4)) ci2opts(pstyle(p4)) ///
    legend(order(3 "Rural" 4 "Urban") ring(0) pos(5) col(1))

/* You can also examine group differences, even without having interaction 
   terms. */
margins urban#pvehicle
marginsplot, name(yhat_cat, replace) `gopts' recast(scatter) horizontal ///
    xlabel(0(0.5)3) yscale(range(-0.5 1.5)) ///
    plotopts(`popts' mlabpos(7) mlabf(%3.2f)) ///
    plot2opts(pstyle(p4)) ci2opts(pstyle(p4)) ///
    legend(order(4 "Has personal vehicle" 3 "No vehicle") ring(0) pos(1) col(1)) 

/* Use care though if you have covariates that differ systematically in your
   data. For example, income is much higher in our urban subjects with more
   variation than our rural subjects. Compare the results. 
*/
poisson nvisits c.age income ib1.urban i.pvehicle
margins urban#pvehicle  // <-- default
marginsplot, name(yhat_cat_i, replace) `gopts' recast(scatter) horizontal ///
    xlabel(0(0.5)3) yscale(range(-0.5 1.5)) ///
    plotopts(`popts' mlabpos(6) mlabf(%3.2f)) ///
    plot2opts(pstyle(p4)) ci2opts(pstyle(p4)) ///
    title("As observed") note("") ///
    legend(order(4 "Has personal vehicle" 3 "No vehicle") ring(0) pos(10) col(1)) 
    
margins urban#pvehicle, at(income=51.1)     // <-- at rural mean income
marginsplot, name(yhat_cat_inci, replace) `gopts' recast(scatter) horizontal ///
    xlabel(0(0.5)3) yscale(range(-0.5 1.5)) ///
    plotopts(`popts' mlabpos(6) mlabf(%3.2f)) ///
    plot2opts(pstyle(p4)) ci2opts(pstyle(p4)) ///
    title("Income fixed to rural average") note("") ///
    legend(off) 
 
graph combine yhat_cat_i yhat_cat_inci, name(yhat_combined, replace) ///
    col(1) xcommon xsize(6.1) ysize(5.4) graphregion(fcolor("231 230 230")) ///
    title("Predictive margins of urban#pvehicle with 95% CIs", ///
        span color("51 63 80") margin(medsmall) size(*0.9)) ///
    note("*simulated data*", color("51 63 80") position(5) ring(2) size(*0.75))    