* CEM matching code 
foreach i of numlist 2000(1)2018 { 
scalar drop _all 
use PIpaper_new_4match.dta, clear 
keep if pubyear ==`i'

_pctile  quality_c1, nq(100) 

local cite05=r(r5) 
local cite10=r(r10) 
local cite15=r(r15) 
local cite25=r(r25) 
local cite30=r(r30) 
local cite40=r(r40) 
local cite50=r(r50) 
local cite60=r(r60) 
local cite70=r(r70) 
local cite75=r(r75) 
local cite80=r(r80) 
local cite90=r(r90) 
local cite95=r(r95) 
local cite99=r(r99) 


cem nb_authrs(0 3.5 6.5 9.5 )   quality_c1(0 `cite25'  `cite50'  `cite75'   `cite95' `cite99' 10000000)  pubyear(#0) jounal_name_R(#0)   degree_year_coarse(#0) , treatment(China)  
drop if cem_matched==0 
gen double strt=real(string(pubyear,"%02.0f")+string(cem_strata,"%04.0f")) 
format strt %15.0f 
order strt wos_uid 
save sample_`i', replace 
}


clear
set obs 1
gen x=.
foreach i of numlist 2000(1)2018 {
append using sample_`i'
		}
		
	
 bysort strt China: gen nb_in_strata = _N
gen weight_hist = 1/nb_in_strata

drop if strt==.
drop x

save matched_papers, replace


// load raw risk set of cited-citing paper pairs
use PIpaper_risk.dta, clear
* atrisk==1 if citing papers are related to cited papers and actually cited focal papers
* atrisk==0 if citing papers are related to cited papers  but did not cite focal papers 
* and all citing papers are published after cited year (based on pubyear,month) 
// restric citing papers are from US only
keep if USA_frct == 1
* drop self and cited related papers 
keep if self_risk == 0 
keep author_id pmid rltd_pmid rltd_rnk rltd_year atrisk rltd_scr
drop if missing(rltd_scr)
save PIpaper_risk_pureUS.dta, replace

use matched_papers.dta, clear
joinby author_id pmid using PIpaper_risk_pureUS.dta
drop if missing(rltd_pmid)
save matched_papers_obs.dta

// 
keep pmid China strt 
duplicates drop 

//  re-caculate cem weghts, some source papers are drop as there is no potential citing papers for these source 
/* we did this in R: calculate cem weights for each paper 
matched_papers<- matched_papers %>%  group_by(strt ) %>% mutate(nb_in_strata_both = n() )
matched_papers$nb_oppsite_in_strata <- matched_papers$nb_in_strata_both-matched_papers$nb_in_strata
matched_papers<- matched_papers %>%  group_by(China) %>% mutate(total_c_or_t = n()) 
matched_papers<- matched_papers %>%  ungroup() %>% mutate(total_control = max (total_c_or_t), total_treat = min(total_c_or_t)) 
matched_papers$cem_weights_final <- ifelse(matched_papers$China==1, 1,  (matched_papers$nb_oppsite_in_strata*matched_papers$total_control)/ (matched_papers$nb_in_strata*matched_papers$total_treat) )
* then merge this to citation pair data 
*/

merge 1:m pmid using matched_papers_obs.dta
keep if _merge==3
save matched_papers_obs.dta, replace

*** then turn to "Variable operation" step to merge all variabels to the estimate dataset 
