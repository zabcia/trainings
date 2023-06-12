*! 21apr2023  raraciborski
*! Generate data for rural telehealth example

version 17

cscript 
set seed 98841		// Min: 1000, Max: 100000 2023-04-21 20:29:53 UTC
set obs 20000

gen subid = strofreal(_n,"%05.0f")
label var subid "Subject ID"

// Generate 7 covariates 
	// 1 - Age
gen age = rpoisson(44)
label var age "Age in years"

gen age18 = age-18
label var age18 "Age, years over 18"

	// 2 - Binary urban residence: older = more likely to be rural
gen ru = rnormal()
gen rural = -.56 + .0189*age 
gen urban = ((1-rural) + ru) > 0	 
note urban : ~25% of the veteran population lives in rural areas /*
	*/(https://www.va.gov/HOMELESS/nchav/resources/veteran-populations/rural.asp)
label var urban "Lives in urban/suburban ZIP"
label def yn 1 "Yes" 0 "No"
label val urban yn
drop ru rural

	// 3 - Public transit connectivity, f(urban)
gen anytransit = rbinomial(1,.75) if urban==1
replace anytransit = rbinomial(1,.25) if urban==0
gen double transit = anytransit*rbeta(2,4) if urban==1
replace transit = anytransit*rbeta(2,2) if urban==0
drop anytransit
label var transit "Public transit connectivity index"
/* Values made up, but allowed values are [0,1] for proportion of jobs 
   accessible by public transit in 45 minutes or less 
*/

	// 4 - Distance to provider, f(urban)
gen distprov = round(rpoisson(5)*(urban==1) + rchi2(20)*(urban==0))
label var distprov "Distance to provider in miles"

	// 5 - Income, f(urban, age)
gen ri = rnormal(0,5)*urban + rnormal(0,2)*(urban==0)		// add random variation
replace ri = min(exp(ri),900) if ri > 0		// specifically at the upper tail
gen income = round(44.9 + .05*age + (-.001)*(age^2) + 3*urban + ri)
drop ri
label var income "Household income in $1,000s"
/* https://www.pewresearch.org/fact-tank/2019/12/09/veteran-households-in-u-s-are-economically-better-off-than-those-of-non-veterans */

	// 6 - Personal vehicle, f(urban, transit, income)
gen rv = rnormal()
gen pvehicle = (0.65 -.02*urban - 0.05*transit + .015*income + rv)>0
drop rv
note pvehicle: 8.3% of households have no personal vehicle (ACS)
label var pvehicle "Personal vehicle in household"
label val pvehicle yn

    // 7 - Propensity to seek mental health care, f(age, income, urban)
gen rs = rnormal()
gen double pref = ///
    0.5 - .003*age + .000001*age^2 + .0002*income - .1*(urban==0) + rs
drop rs
qui sum pref
replace pref = (pref-r(mean))/r(sd)
label var pref "Preference for seeking mental health care"

// Effects
	local b0  0.95  		// base odds (age=18, urban, no transit, vehicle, dist.)
	local b1 -0.009 	// b1 age (-)
	local b2  0     	// b2 rural (n)
	local b3  0.5 		// b3 transit (+)
	local b4 -0.02 		// b4 distprov (-)
	local b5  0.005		// b5 income (+)
	local b6  1.2		// b6 pvehicle (+)
    local b7  0.45      // b7 pref (+)

// Outcome
gen e = rlogistic()
gen xb = `b0' + (`b2')*(urban==0) + e ///
	+ (`b1')*age18 		///
	+ (`b3')*transit 	///
	+ (`b4')*distprov 	///
	+ (`b5')*income 	///
	+ (`b6')*pvehicle   ///
    + (`b7')*pref
gen smhc = xb > 0
label var smhc "Received specialty mental health care"
label val smhc yn


    // Outcome (secondary) - # of visits ("continuous")
gen nvisits = round(max(0,xb)), before(smhc)
label var nvisits "Number of specialty mental health visits"

drop xb e 

compress
order subid nvisits smhc urban age age18 income pvehicle transit distprov 
label data "Simulated rural mental health data"
save data\ruralmh, replace