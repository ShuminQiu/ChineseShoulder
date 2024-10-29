****Table 2: Estimating the China location discount (or premium) on the rate of US citations [Linear Probability Model

use ChineseShoulder_estimate.dta, clear 

**** (1) China only 

reghdfe  atrisk   China /* CHINA 
*/  [pweight = cem_weights_final], /* 
*/ absorb( pubyear#rltd_year  rltd_rank_coarser       degree_year strt  female  samejournal) cluster( author_id strt )

est store  model1

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

*(2) 
reghdfe  atrisk   China /* CHINA 
*/ csumpub05_10 csumpub10_15 csumpub15_25 csumpub25_30 csumpub30_40 csumpub40_50 csumpub50_60 csumpub60_70 csumpub70_80 csumpub80_90 csumpub90_95 csumpub95_99 csumpub99_100 csumcite05_10 csumcite10_15 csumcite15_25 csumcite25_30 csumcite30_40 csumcite40_50 csumcite50_60 csumcite60_70 csumcite70_80 csumcite80_90 csumcite90_95 csumcite95_99 csumcite99_100 /* cumulative publications
*/ i_English_prm    lndist/* Communication
*/ US_training US_reprint_or_1st US_other_P lnnb_usa sameth_max_last common_coauthor focal_coauthor dum_editorial_top31_3y/* Network
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

*(3) 
reghdfe  atrisk   China /* CHINA 
*/ csumpub05_10 csumpub10_15 csumpub15_25 csumpub25_30 csumpub30_40 csumpub40_50 csumpub50_60 csumpub60_70 csumpub70_80 csumpub80_90 csumpub90_95 csumpub95_99 csumpub99_100 csumcite05_10 csumcite10_15 csumcite15_25 csumcite25_30 csumcite30_40 csumcite40_50 csumcite50_60 csumcite60_70 csumcite70_80 csumcite80_90 csumcite90_95 csumcite95_99 csumcite99_100 /* cumulative publications
*/ i_English_prm    lndist/* Communication
*/ US_training US_reprint_or_1st US_other_P lnnb_usa sameth_max_last common_coauthor focal_coauthor dum_editorial_top31_3y/* Network
*/ allhome_intens_rscl allforeign_intens_rscl usa_intens_rscl/* geographic clustering 
*/ subfield_csum_pcto2o own_rltf_tim_pcr  eg_5y_PI /* interllectual controls 
*/  nrrw_dum /* Reputation
*/cn_ustraining  cn_US_reprint_or_1st cn_US_other_P cn_lnnb_usa  cn_sameth_max_last cn_dum_editorial_top31_3y/*
*/  [pweight = cem_weights_final] , /* 
*/ absorb( pubyear#rltd_year  rltd_rank_coarser   degree_year     strt  female  samejournal) cluster( author_id strt )

est store  model3

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


 lincom China + cn_ustraining
 lincom China + cn_sameth_max_last

*(4) 
reghdfe  atrisk   China /* CHINA 
*/ csumpub05_10 csumpub10_15 csumpub15_25 csumpub25_30 csumpub30_40 csumpub40_50 csumpub50_60 csumpub60_70 csumpub70_80 csumpub80_90 csumpub90_95 csumpub95_99 csumpub99_100 csumcite05_10 csumcite10_15 csumcite15_25 csumcite25_30 csumcite30_40 csumcite40_50 csumcite50_60 csumcite60_70 csumcite70_80 csumcite80_90 csumcite90_95 csumcite95_99 csumcite99_100 /* cumulative publications
*/ i_English_prm    lndist/* Communication
*/ US_training US_reprint_or_1st US_other_P lnnb_usa sameth_max_last common_coauthor focal_coauthor dum_editorial_top31_3y/* Network
*/ allhome_intens_rscl allforeign_intens_rscl usa_intens_rscl/* geographic clustering 
*/ subfield_csum_pcto2o own_rltf_tim_pcr  eg_5y_PI /* interllectual controls 
*/  nrrw_dum /* Reputation
*/cn_allhome_intens_rscl cn_allforeign_intens_rscl cn_usa_intens_rscl /*
*/  [pweight = cem_weights_final] , /* 
*/ absorb( pubyear#rltd_year  rltd_rank_coarser   degree_year     strt  female  samejournal) cluster( author_id strt )

est store  model4

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


*(5) 
reghdfe  atrisk   China /* CHINA 
*/ csumpub05_10 csumpub10_15 csumpub15_25 csumpub25_30 csumpub30_40 csumpub40_50 csumpub50_60 csumpub60_70 csumpub70_80 csumpub80_90 csumpub90_95 csumpub95_99 csumpub99_100 csumcite05_10 csumcite10_15 csumcite15_25 csumcite25_30 csumcite30_40 csumcite40_50 csumcite50_60 csumcite60_70 csumcite70_80 csumcite80_90 csumcite90_95 csumcite95_99 csumcite99_100 /* cumulative publications
*/ i_English_prm    lndist/* Communication
*/ US_training US_reprint_or_1st US_other_P lnnb_usa sameth_max_last common_coauthor focal_coauthor dum_editorial_top31_3y/* Network
*/ allhome_intens_rscl allforeign_intens_rscl usa_intens_rscl/* geographic clustering 
*/ subfield_csum_pcto2o own_rltf_tim_pcr  eg_5y_PI /* interllectual controls 
*/  nrrw_dum /* Reputation
*/cn_subfield_csum_pcto2o cn_own_rltf_tim_pcr cn_eg_5y_PI/*
*/  [pweight = cem_weights_final] , /* 
*/ absorb( pubyear#rltd_year  rltd_rank_coarser   degree_year     strt  female  samejournal) cluster( author_id strt )

est store  model5

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


_pctile  subfield_csum_pcto2o , nq(100) 

local p90=r(r90) 
local p95=r(r95) 
local p99=r(r99) 

lincom China + `p99'  * cn_subfield_csum_pcto2o 


*(6)
reghdfe  atrisk   China /* CHINA 
*/ csumpub05_10 csumpub10_15 csumpub15_25 csumpub25_30 csumpub30_40 csumpub40_50 csumpub50_60 csumpub60_70 csumpub70_80 csumpub80_90 csumpub90_95 csumpub95_99 csumpub99_100 csumcite05_10 csumcite10_15 csumcite15_25 csumcite25_30 csumcite30_40 csumcite40_50 csumcite50_60 csumcite60_70 csumcite70_80 csumcite80_90 csumcite90_95 csumcite95_99 csumcite99_100 /* cumulative publications
*/ i_English_prm    lndist/* Communication
*/ US_training US_reprint_or_1st US_other_P lnnb_usa sameth_max_last common_coauthor focal_coauthor dum_editorial_top31_3y/* Network
*/ allhome_intens_rscl allforeign_intens_rscl usa_intens_rscl/* geographic clustering 
*/ subfield_csum_pcto2o own_rltf_tim_pcr  eg_5y_PI /* interllectual controls 
*/  nrrw_dum /* Reputation
*/cn_nrrw_dum/*
*/  [pweight = cem_weights_final] , /* 
*/ absorb( pubyear#rltd_year  rltd_rank_coarser   degree_year     strt  female  samejournal) cluster( author_id strt )

est store  model6

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

reghdfe  atrisk   China /* CHINA 
*/ csumpub05_10 csumpub10_15 csumpub15_25 csumpub25_30 csumpub30_40 csumpub40_50 csumpub50_60 csumpub60_70 csumpub70_80 csumpub80_90 csumpub90_95 csumpub95_99 csumpub99_100 csumcite05_10 csumcite10_15 csumcite15_25 csumcite25_30 csumcite30_40 csumcite40_50 csumcite50_60 csumcite60_70 csumcite70_80 csumcite80_90 csumcite90_95 csumcite95_99 csumcite99_100 /* cumulative publications
*/ i_English_prm    lndist/* Communication
*/ US_training US_reprint_or_1st US_other_P lnnb_usa sameth_max_last common_coauthor focal_coauthor dum_editorial_top31_3y/* Network
*/ allhome_intens_rscl allforeign_intens_rscl usa_intens_rscl/* geographic clustering 
*/ subfield_csum_pcto2o own_rltf_tim_pcr  eg_5y_PI /* interllectual controls 
*/  nrrw_dum /* Reputation
*/  cn_ustraining  cn_US_reprint_or_1st cn_US_other_P cn_lnnb_usa cn_sameth_max_last cn_dum_editorial_top31_3y cn_allhome_intens_rscl cn_allforeign_intens_rscl cn_usa_intens_rscl  cn_subfield_csum_pcto2o cn_own_rltf_tim_pcr cn_eg_5y_PI  cn_nrrw_dum/*
*/  [pweight = cem_weights_final] , /* 
*/ absorb( pubyear#rltd_year  rltd_rank_coarser   degree_year     strt  female  samejournal) cluster( author_id strt )

est store  model7

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



esttab  model1 model2 model3 model4 model5  model6 model7 /*
*/ using  Table2,    drop(csumpub05_10 csumpub10_15 csumpub15_25 csumpub25_30 csumpub30_40 csumpub40_50 csumpub50_60 csumpub60_70 csumpub70_80 csumpub80_90 csumpub90_95 csumpub95_99 csumpub99_100 csumcite05_10 csumcite10_15 csumcite15_25 csumcite25_30 csumcite30_40 csumcite40_50 csumcite50_60 csumcite60_70 csumcite70_80 csumcite80_90 csumcite90_95 csumcite95_99 csumcite99_100) /*
*/   tex varwidth(25) nonumber noobs nogaps nodep noconstant label b(%5.3f) se(%5.3f)  star(+ 0.10 * 0.05 ** 0.01)  compress scalars("meandv Mean of Dependent Variable" "sddv s.d. of Dependent Variable" "mgntd China effect in s.d. units" "mgntd_lo China effect lower bound in s.d. units" "mgntd_hi China effect upper bound in s.d. units" "adjr2 Adjusted R2" "Investigators No. of Investigators" "Cited_Papers No. of Cited Papers" "Risk_papers No. of Citing Papers" "N No. of Citing/Cited Pairs")  sfmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %10.0f %10.0f %10.0f %10.0f ) replace
