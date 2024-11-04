
* CEM matching, use other country as treated country.
foreach cntry in  Germany Japan UK Switz Canada CName_not_inCN { 
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


cem nb_authrs(0 3.5 6.5 9.5 )   quality_c1(0 `cite25'  `cite50'  `cite75'   `cite95' `cite99' 10000000)  pubyear(#0) jounal_name_R(#0)   degree_year_coarse(#0) , treatment(`cntry')  
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
		
	
 bysort strt `cntry': gen nb_in_strata = _N
gen weight_hist = 1/nb_in_strata

drop if strt==.
drop x
save `cntry'_matched_papers, replace


// load raw risk set of cited-citing paper pairs
/*
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
*/
use  `cntry'_matched_papers.dta, clear
joinby author_id pmid using PIpaper_risk_pureUS.dta
drop if missing(rltd_pmid)
save `cntry'_matched_papers_obs.dta

// 
keep pmid `cntry' strt 
duplicates drop 

//  re-caculate cem weghts, some source papers are drop as there is no potential citing papers for these source 
/* we did this in R: calculate cem weights for each paper 
`cntry'_matched_papers<- `cntry'_matched_papers %>%  group_by(strt ) %>% mutate(nb_in_strata_both = n() )
`cntry'_matched_papers$nb_oppsite_in_strata <- `cntry'_matched_papers$nb_in_strata_both-`cntry'_matched_papers$nb_in_strata
`cntry'_matched_papers<- `cntry'_matched_papers %>%  group_by(`cntry') %>% mutate(total_c_or_t = n()) 
`cntry'_matched_papers<- `cntry'_matched_papers %>%  ungroup() %>% mutate(total_control = max (total_c_or_t), total_treat = min(total_c_or_t)) 
`cntry'_matched_papers$cem_weights_final <- ifelse(`cntry'_matched_papers$`cntry'==1, 1,  (`cntry'_matched_papers$nb_oppsite_in_strata*`cntry'_matched_papers$total_control)/ (matched_papers$nb_in_strata*matched_papers$total_treat) )
* then merge this to citation pair data 
*/

bysort strt `cntry': gen nb_in_strata = _N
bysort strt: gen nb_in_strata_both = _N
gen nb_oppsite_in_strata = nb_in_strata_both - nb_in_strata
keep if nb_oppsite_in_strata > 0
bysort `cntry': gen total_c_or_t = _N
egen total_control = total(total_c_or_t) if `cntry' == 0
egen total_treat = total(total_c_or_t) if `cntry' == 1
gen cem_weights_final = cond(`cntry' == 1, 1, (nb_oppsite_in_strata * total_control) / (nb_in_strata * total_treat))

merge m:1 pmid using `cntry'matched_papers_obs.dta
save `cntry'_matched_papers_obs.dta, replace


}
*******merge all control to `cntry'_matched_papers_obs, and get estimation dataset, then run default model for all countries.


foreach cntry in Germany Japan UK Switz Canada   CName_not_inCN { //* 
use `cntry'_matched_papers_obs.dta , clear 
*(2) 
reghdfe  atrisk   `cntry' /*  
*/ csumpub05_10 csumpub10_15 csumpub15_25 csumpub25_30 csumpub30_40 csumpub40_50 csumpub50_60 csumpub60_70 csumpub70_80 csumpub80_90 csumpub90_95 csumpub95_99 csumpub99_100 csumcite05_10 csumcite10_15 csumcite15_25 csumcite25_30 csumcite30_40 csumcite40_50 csumcite50_60 csumcite60_70 csumcite70_80 csumcite80_90 csumcite90_95 csumcite95_99 csumcite99_100 /* cumulative publications
*/ i_English_prm    lndist/* Communication
*/ US_training US_reprint_or_1st US_other_P  same_ethn common_coauthor focal_coauthor dum_editorial_top31_3y/* Network
*/ allhome_intens_rscl allforeign_intens_rscl usa_intens_rscl/* geographic clustering 
*/ subfield_csum_pcto2o own_rltf_tim_pcr  eg_5y_PI /* interllectual controls 
*/  nrrw_dum /* Reputation
*/  [pweight = cem_weights_final] , /* 
*/ absorb( pubyear#rltd_year  rltd_rank_coarser   degree_year     strt  female  samejournal) cluster( author_id strt )

est store  model2

estadd scalar adjr2=e(r2_a)

distinct pmid if e(sample)
estadd scalar Cited_Papers=r(ndistinct)

distinct rltd_pmid if e(sample)
estadd scalar Risk_papers=r(ndistinct)

distinct author_id if e(sample)
estadd scalar Investigators=r(ndistinct)

estadd ysumm
estadd scalar meandv=e(ymean)
estadd scalar sddv=e(ysd)
mat b = e(b)
mat V = e(V)
estadd scalar mgntd=(b[1,1])/e(sddv)
estadd scalar mgntd_lo=(b[1,1]-1.96*sqrt(V[1,1]))/e(sddv)
estadd scalar mgntd_hi=(b[1,1]+1.96*sqrt(V[1,1]))/e(sddv)

esttab  model2/*
*/ using "`cntry'_effct.rtf", varwidth(25) nonumber noobs nogaps nodep noconstant label b(%5.3f) se(%5.3f)  star(+ 0.10 * 0.05 ** 0.01)  compress scalars("meandv Mean of Dependent Variable" "sddv s.d. of Dependent Variable" "mgntd Country effect in s.d. units" "mgntd_lo Country effect lower bound in s.d. units" "mgntd_hi Country effect upper bound in s.d. units" "adjr2 Adjusted R2" "Investigators No. of Investigators" "Cited_Papers No. of Cited Papers" "Risk_papers No. of Citing Papers" "N No. of Citing/Cited Paper Pairs")  sfmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %10.0f %10.0f %10.0f %10.0f ) replace
}



**** gathering Country effect in s.d. units,Country effect lower bound in s.d. units,Country effect upper bound in s.d. units for each country, then plot (see Figure2_plot.R)


