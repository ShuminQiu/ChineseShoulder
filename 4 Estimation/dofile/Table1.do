local replace replace 
use cntry_on_UScite.dta, clear 
ppmlhdfe  nb_uscites  China,  /* CHINA  
*/ absorb(  nb_authrs ) cluster(country)
outreg2 using "table1", excel tex  `replace' nocons  
local replace

ppmlhdfe  nb_uscites  China,  /* CHINA  
*/ absorb( pubyear nb_authrs ) cluster(country)
outreg2 using "table1", excel tex  `replace' nocons  
local replace

ppmlhdfe  nb_uscites  China,  /* CHINA  
*/ absorb( pubyear nb_authrs journal_name) cluster(country)
outreg2 using "table1", excel tex  `replace' nocons  
local replace


