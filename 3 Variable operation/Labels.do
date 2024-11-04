* labels and statistics 
************************************* ************************************* ************************************* variables and labels ************************************* ************************************* 
recode rltd_rnk (1/10 =1) (11/20 = 2) (21/30 =3) (31/40 =4) (41/50 = 5) (51/60 =6) (61/70 = 7) (71/80 =8) (81/90 = 9)(91/100 =10) (101/110 = 11) (111/120 =12) /*
*/ (121/130 =13) (131/140 = 14) (141/150 =15) (151/170 = 16) (171/ 190=17) (191/ 210= 18) (211/230=19) (231/260=20) (261/300=21) (301/350=22) (351/450=23) /*
*/ (451/650=24) (651/1000=25)(1001/10000000000=26), gen(rltd_rank_coarser)



foreach var in  i_English_prm   US_training US_reprint_or_1st US_other_P lnnb_usa sameth_max_last common_coauthor focal_coauthor dum_editorial_top31_3y allhome_intens_rscl allforeign_intens_rscl usa_intens_rscl subfield_csum_pcto2o own_rltf_tim_pcr  eg_5y_PI  nrrw_dum {
replace `var' = 0 if `var'==.
}

gen allhome_intens_rscl=allhome_intens/100
gen allforeign_intens_rscl= allforeign_intens/100
gen usa_intens_rscl= usa_intens/100




foreach var in   US_reprint_or_1st US_other_P lnnb_usa sameth_max_last dum_editorial_top31_3y allhome_intens_rscl allforeign_intens_rscl usa_intens_rscl  subfield_csum_pcto2o own_rltf_tim_pcr eg_5y_PI  nrrw_dum {
gen cn_`var' = China*`var'
}
gen cn_ustraining = China* US_training


*** labels 
label variable China "Chinese Investigator"
label variable female "Female Investigator"
label variable degree_year "Investigator PhD Degree Year"
label variable indep_year "Investigator Career Independent Year"
label variable samejournal "Citation from Same Journal"

label variable i_English_prm "Investigator from English-speaking Country"
label variable lndist "Log(Avg. Distance)"

label variable US_training "Investigator with US Training"
label variable US_reprint_or_1st "US First/Reprinted Cited Author"
label variable US_other_P "US Cited Author in Other Positions"
label variable lnnb_usa "Log(Cumulative No. of US Coauthorships)"
label variable sameth_max_last "Citation from Same Ethnicity"
label variable common_coauthor "Citing Coauthor is Investigator's Past Collaborator"
label variable focal_coauthor "Common Coauthor"
label variable dum_editorial_top31_3y "Investigator is an Editorial Author"
label variable allhome_intens_rscl "Subfield Home Research Intensity"
label variable allforeign_intens_rscl "Subfield Foreign Research Intensity"
label variable usa_intens_rscl "Subfield USA Research Intensity"
label variable subfield_csum_pcto2o "Importance of Subfield for Investigator"
label variable own_rltf_tim_pcr "Importance of Investigator for the Subfield"
label variable eg_5y_PI "Ellison/Glaeser Index of Scholarly Focus"
label variable nrrw_dum "Retraction-heavy Subfield"


label variable cn_ustraining "China * Investigator with US Training"
label variable cn_US_reprint_or_1st "China * US First/Reprinted Cited Author"
label variable cn_US_other_P "China * US Cited Author in Other Positions"
label variable cn_lnnb_usa "China * Log(Cumulative No. of US Coauthorships)"
label variable cn_sameth_max_last "China * Citation from Same Ethnicity"
label variable cn_common_coauthor "China * Citing Coauthor is Investigator's Past Collaborator"
label variable cn_focal_coauthor "China * Common Coauthor"
label variable cn_dum_editorial_top31_3y "China * Investigator is an Editorial Author"
label variable cn_allhome_intens_rscl "China * Subfield Home Research Intensity"
label variable cn_allforeign_intens_rscl "China * Subfield Foreign Research Intensity"
label variable cn_usa_intens_rscl "China * Subfield USA Research Intensity"
label variable cn_subfield_csum_pcto2o "China * Importance of Subfield for Investigator"
label variable cn_own_rltf_tim_pcr "China * Importance of Investigator for the Subfield"
label variable cn_eg_5y_PI "China * Ellison/Glaeser Index of Scholarly Focus"
label variable cn_nrrw_dum "China * Retraction-heavy Subfield"


