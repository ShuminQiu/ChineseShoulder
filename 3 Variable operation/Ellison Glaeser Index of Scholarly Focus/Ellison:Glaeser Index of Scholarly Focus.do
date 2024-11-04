**** Ellison/Glaeser Index of Scholarly Focus
* raw data: we load law data of mesh terms for each paper. in the raw dataset, we know the mesh terms for each paper (author_id-pmid-year specific paper)

forvalues i = 1999(1)2019 {
use for_herf_allpapers.dta, clear
display "`i'"
keep if inlist(year,`i'-5,`i'-4,`i'-3,`i'-2,`i'-1) /* source paper year i */
drop year
egen eg_5y_PI=egindex_b(mesh), by(author_id)
bysort author_id: keep if _n==_N
keep author_id  eg_5y_PI
gen year=`i'
save focus_`i'.dta, replace
}

use focus_1999.dta, clear
forvalues i = 1999(1)2019 {
append using focus_`i'.dta
}

bysort author_id year: assert _N==1
order author_id year

