*! 03may2023
*! using predictive margins illustration

version 17

use data/ruralmh, clear

// Graphics options to apply to all graphs below (slide theme)
local gopts xsize(6.1) ysize(5.4) graphregion(fcolor("231 230 230")) ///
    title(, span color("51 63 80") size(*.9)) ///
    subtitle(, span color("51 63 80") size(*.9)) ///
    ytitle(, color("51 63 80") margin(medsmall)) ///
    ylabel(, nogrid labcolor("51 63 80")) ///
    xtitle(, color("51 63 80") margin(medsmall)) ///
    xlabel(, nogrid labcolor("51 63 80")) ///
    caption(, color("51 63 80") ring(1) span size(*0.9)) ///
    note("*simulated data*", color("51 63 80") position(5) ring(2) size(*0.75))
    
logit smhc i.pvehicle age ib1.urban transit distprov income
est store m1


// Is the probability of smhc lower in urban areas?
margins urban, cformat(%4.3f)

/* 
This is not what you want! Why? Because these are the estimates if everyone
(including those who live in urban areas) live in rural areas and the effect
if everyone (including those who live in rural areas) live in urban areas 
*/
logit smhc i.pvehicle age ib1.urban transit distprov income
margins if urban==0, at(urban=(0 1)) post cformat(%4.3f) // coeflegend

    // test whether the predicted probabilities differ if everyone lived in
    // a rural area vs an urban area
test 1bn._at = 2._at
    // Graph for comparisons
marginsplot, name(predprob, replace) recast(bar) `gopts' ///
    plotopts(barwidth(0.5) bcolor(%70)) ///
    title(Predicted probabilities for rural residents) ///
    subtitle(with 95% confidence intervals) ///
    ytitle("Predicted probability" "(received specialty mental health care)") ///
    ylabel(0.8(0.02).9) yline(0.826, lpattern(dash) lstyle(foreground)) ///
    xtitle("As if living in an urban/suburban ZIP") ///
    text(0.826 0.5 "Rural (obs.)" "= 0.826", ///
        color("51 63 80") size(*.9) placement(6)) ///   
    
// Which variable has the largest urban-rural differences in probablity?
est restore m1

/* Because we have several continuous covariates we need to specify where to 
   evaluate them. By using multiple at() values, we obtain estimates for each
   rather than with a single at() for all variables together, which would 
   give us the conditional effects.
*/
margins urban, at((p10) age) at((p50) age) at((p90) age) ///
    at((p10) income) at((p50) income) at((p90) income) ///
    at((p10) transit) at((p50) transit) at((p90) transit) ///
    at((p10) distprov) at((p50) distprov) at((p90) distprov) ///
    at(pvehicle=0) at(pvehicle=1) mcompare(bonferroni)
    
marginsplot, name(factors, replace) recast(scatter) horizontal ///
    title(Predicted probabilities by residence location) ///
    subtitle(with 95% confidence intervals adjusted for multiple comparisons) ///
    plotdim(urban) plotopts(mcolor(%70)) ///
    plot2opts(pstyle(p4)) ci2opts(pstyle(p4)) ///
    xline(0.9, lpattern(dash) lstyle(foreground))  ///
    xlabel(0.7 0.8 " " 0.9 "Urban (obs.) = .9" 1.0) ///
    xtitle("Predicted probability" "(received specialty mental health care)") ///
    ytitle("") `gopts' ///
    legend(order(3 "Rural" 4 "Urban") ring(0) pos(7)) 
    

