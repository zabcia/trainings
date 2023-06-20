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

/* Linear coefficients are also MEs ... */
regress nvisits c.age ib1.urban i.pvehicle
* writeif, cformat(%5.4f)
margins, dydx(age) 
marginsplot, name(linear, replace) `gopts' ///
    plotopts(`popts' mlabpos(4) mlabf(%5.4f))

margins, dydx(age) at(age=(20(10)70)) 
marginsplot, name(linear_at, replace) `gopts' ///
    plotopts(`popts' mlabpos(4) mlabf(%5.4f)) xscale(range(20 75))

/* ... unless a variable enters nonlinearly (interaction with itself) ... */
regress nvisits c.age##c.age
* writeif, cformat(%5.4f)
estimates store reg2

/* ... or as in interaction with another variable. */
regress nvisits c.age ib1.urban##i.pvehicle
writeif, cformat(%4.3f)
estimates store reg3

/* In this case, the value is no longer constant across values of age. */
estimates restore reg2
margins, dydx(age) at(age=(20(10)70))
marginsplot, name(me_age, replace) xscale(range(20 72)) `gopts' ///
    plotopts(`popts'mlabpos(5) mlabf(%5.3f))

/* Notice that (unless you have a very good imagination) you do not see the 
   functional form if you just plot the marginal effects. The plot, in this
   case is just a straight line because our function is linear once we take the 
   derivative. 
*/
   
/* The plotted values above are **conditional** marginal effects, meaning they
   are marginal effects evaluated conditional on a specified value of age. 

   To summarize a single "marginal effect", we now have to decide how to 
   approach. What typically gets reported is the average marginal effect (AME). 
   The AME is the average of the derivative of the conditional expectation 
   evaluated for each observation.
*/
preserve 
generate me_age = _b[c.age] + 2*_b[c.age#c.age]*age     // <-- derivative
summarize me_age        // <-- this std. dev. too small for inference/tests
                        // because it ignores uncertainty in the estimates; you 
                        // need another formula if you are doing this by hand!
local ame : display %4.3f `r(mean)'
contract me_age age
scatter me_age age [fw=_freq], name(ame_age, replace) msymbol(oh) /// 
    title("Contribution to average marginal effect") ///
    ytitle("Effect on linear prediction") ///
    yline(`ame', lcolor(175 73 16) lpattern(dash)) ///
    text(`=`ame'-.001' 70 "AME = `ame'", placement(7)) ///
    `gopts' xlabel(20(10)70) ///
    caption(Size of marker is proportionate to number of observations)
restore

/* Fortunately, -margins- calculates the AME and correct standard errors 
   by default if you specify -dydx()- */
margins, dydx(age)

/* By constrast, the marginal effect at the mean is the conditional expectation
   evaluated at the sample average [NB: for the linear model, this is the same
   as the average marginal effect]
*/
summarize age, meanonly
local mage `r(mean)'

/* And the marginal effect at a representative value is the conditional 
   expectation evaluated at a specified "representative" value
*/
summarize age if urban==0, meanonly
local mage0 `r(mean)'
summarize age if urban==1, meanonly
local mage1 `r(mean)'

margins, dydx(age) at(age=(`mage')) at(age=(`mage0')) at(age=(`mage1'))
marginsplot, recast(scatter) name(mem_mer, replace) ///
    xdim(_at, labels("MEM: age=44.0" "MER: age=45.1" "MER: age=43.7")) ///
    ylabel(-0.06(0.02)0.04) xtitle(Marginal effects) ///
    `gopts' xscale(range(0.5 3.5)) plotopts(`popts' mlabf(%5.4f)) ///
    note(Plot not shown in presentation, suffix)

/* We can visualize what a ME is by seeing the tangent at each point
   on the function for simple functions of one variable. */
scalar b1hat = _b[age] 
scalar b2hat = _b[c.age#c.age]
local b0 = round(_b[_cons],0.01)
local b1 = round(b1hat,0.001)
local b2 = round(b2hat,0.0001)
scalar yhat1 = _b[_cons] + (b1hat)*20 + (b2hat)*20^2
scalar yhat2 = _b[_cons] + (b1hat)*70 + (b2hat)*70^2
scalar s1 = b1hat + 2*(b2hat)*20
scalar s2 = b1hat + 2*(b2hat)*70
scalar x1i = yhat1-(s1)*20
scalar x2i = yhat2-(s2)*70

local y1pt = scalar(yhat1)
local y2pt = scalar(yhat2)
    
twoway function y = _b[_cons] + b1hat*x + (b2hat)*x^2, range(18 73) ///
        lpattern(shortdash) lcolor(%75) || ///
    function y=scalar(x1i)+scalar(s1)*x, range(19 21)  ///
        lpattern(solid) lcolor("25 133 195") lwidth(medthick) || ///
    function y=scalar(x2i)+scalar(s2)*x, range(68.25 71.75)  ///
        lpattern(solid) lcolor("25 133 195") lwidth(medthick)  || ///
    pcarrowi `=`y1pt'+.2' 22 `y1pt' 20 ///
        "ME=`=round(scalar(s1),0.001)' at age=20" || ///
    pcarrowi `=`y2pt'+.2' 67 `y2pt' 70 ///
        (9) "ME=`=round(scalar(s2),0.001)' at age=70", ///
    scheme(s2mono) legend(off) `gopts' name(me_how, replace) ///
    title("Illustrating marginal effects of age") ///
    caption("tangents (solid lines) show derivative evaluated over narrow range" ///
     "dashed line is functional relationship between outcome and age") ///
    xtitle("age") ytitle("number of visits")

/*** Incremental effects ***/
est restore reg3
local rv : display %3.2f _b[0.urban] + _b[0.urban#1.pvehicle]
local rnv : display %3.2f _b[0.urban]

generate asrural = _b[_cons]+_b[0.urban] ///  everyone gets rural intercept
                   +(_b[1.pvehicle]+_b[0.urban#1.pvehicle])*pvehicle ///
                   /// ^ and the extra bit from the rural*pvehicle interaction
                   +_b[age]*age // but their actual age

generate asurban = _b[_cons] ///  everyone gets urban-only intercept
                   +(_b[1.pvehicle])*pvehicle /// & only main effect of pvehicle
                   +_b[age]*age // along with their actual age

mean asrural asurban, cformat(%4.3f)
local ie : display %5.4f _b[asrural] - _b[asurban]
 
twoway (rspike asrural asurban age if pvehicle==1, ///
        lcolor(%20) lpattern(dash)) || ///
    (scatter asurban age if pvehicle==1, ///
        pstyle(p1) mcolor(%20) msymbol(oh)) || ///
    (scatter asrural age if pvehicle==1, ///
        pstyle(p1) mcolor(%20) msymbol(v)) || ///
    (rspike asrural asurban age if pvehicle==0, lcolor(%20) lpattern(dash)) || ///
    (scatter asurban age if pvehicle==0, ///
        pstyle(p4) mcolor(%20) msymbol(oh)) || ///
    (scatter asrural age if pvehicle==0, pstyle(p4) mcolor(%20) msymbol(v)) ///
    , name(ie_rural, replace) `gopts' legend(off) ///
    title(Contribution to average incremental effect, margin(small)) ///
    subtitle(Rural vs urban residence) ///
    ytitle(Conditional expectation) ylabel(0(0.5)3.5) ///
    xtitle("(effect is constant across all ages)", suffix) ///
    text(3.3 50 "IE (with car) = `rv'", placement(5) size(small)) ///
    text(.75 50 "IE (without car) = `rnv'", placement(9) size(small)) ///        
    caption(Darker lines indicate more observations) 

/* This calculation is what is done by -margins- if dydx() is a factor 
   variable */
est restore reg3
margins, dydx(urban)

/*
    - How many unique marginal effects exist?
        - One per variable
        - One per subject
        - One per subject per variable
        - One per unique covariate pattern in the data ***
    
    - When we report an average marginal effect, what determines its value?
        - The magnitude of the variable's effect
        - The relative proportions of each type of subject in the sample
        - Both ***
        
    - Which marginal effects will we be able to estimate with the greatest
      precision?
        - Those for variables with low variance
        - Those with many observations 
        - Those where subjects with the same values have similar outcomes ***
*/