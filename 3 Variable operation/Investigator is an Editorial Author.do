
* 
* allpaper_751.dta: raw data of PI'S paper address and countries. If this paper has at least a us coauthor, then usa =1
forvalues i = 1999(1)2019 {
use allpaper_751.dta, clear
display "`i'"
keep if inlist(year,`i'-3,`i'-2,`i'-1) /* source paper year i */
drop year

egen nb_editorial_top31_3y=sum(editorial_top31), by(author_id)

bysort author_id: keep if _n==_N
keep author_id  nb_editorial_top31_3y
gen year=`i'
save editorial_`i'.dta, replace
}

use editorial_1999.dta, clear
forvalues i = 1999(1)2019 {
append using editorial_`i'.dta
}
order author_id year
gen dum_editorial_top31_3y = 1 if nb_editorial_top31_3y>0
replace  dum_editorial_top31_3y = 0 if dum_editorial_top31_3y==.

save PIeditorial_csum_3y.dta, replace

use "matched_papers_obs.dta",clear
drop _merge
merge m:1  author_id pubyear using  PIeditorial_csum_3y.dta
drop if strt==.
drop _merge
replace dum_editorial_top31_3y = 0 if dum_editorial_top31_3y==.





