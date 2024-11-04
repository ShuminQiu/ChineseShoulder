
***********************  count nb of PI's cumulative US coauthorships 

forvalues i = 1999(1)2019 {
use alltop_pub751.dta, clear
keep if year<`i'   /* source paper year i */
drop year
egen nb_usa=sum(usa), by(author_id)
bysort author_id: keep if _n==_N
keep author_id nb_usa 
gen year=`i'
save usa_coauthorship_`i'.dta, replace
}

use usa_coauthorship_1999.dta, clear
forvalues i = 1999(1)2019 {
append using usa_coauthorship_`i'.dta
rename year pubyear
}
save usa_coauthorship_csum.dta, replace

use "matched_papers_obs.dta",clear

merge m:1  author_id pubyear using  usa_coauthorship_csum.dta
drop if strt==.
drop _merge

replace nb_usa = 0 if nb_usa==.
gen lnnb_usa=log(lnnb_usa+1)




