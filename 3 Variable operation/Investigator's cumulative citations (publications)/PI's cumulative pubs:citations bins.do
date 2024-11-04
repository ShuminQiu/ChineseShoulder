* investigator cumulative publication bins (13 bins), 
* investigator cumulative citations bins (13 bins)
use PIpaper_new_4match.dta, clear 
gen year = pubyear-1 
joinby authorid year using csum_751chemists_final.dta 

_pctile csum_inpubmed, nq(100) 
gen csumpub05=r(r5) 
gen csumpub10=r(r10) 
gen csumpub15=r(r15) 
gen csumpub25=r(r25) 
gen csumpub30=r(r30)
gen csumpub40=r(r40) 
gen csumpub50=r(r50) 
gen csumpub60=r(r60) 
gen csumpub75=r(r75) 
gen csumpub80=r(r80)
gen csumpub90=r(r90) 
gen csumpub95=r(r95) 
gen csumpub99=r(r99) 


gen csumpub05_10 = 1  if  csum_inpubmed   > csumpub05 & csum_inpubmed   <= csumpub10
replace csumpub05_10 =0 if csumpub05_10 ==.

gen csumpub10_15 = 1  if  csum_inpubmed   > csumpub10 & csum_inpubmed   <= csumpub15
replace csumpub10_15 =0 if csumpub10_15 ==.

gen csumpub15_25 = 1  if  csum_inpubmed   > csumpub15 & csum_inpubmed   <= csumpub25
replace csumpub15_25 =0 if csumpub15_25 ==.

gen csumpub25_30 = 1  if  csum_inpubmed   > csumpub25 & csum_inpubmed   <= csumpub30
replace csumpub25_30 =0 if csumpub25_30 ==.


gen csumpub30_40  = 1  if  csum_inpubmed   > csumpub30 & csum_inpubmed   <= csumpub40
replace csumpub30_40  =0 if csumpub30_40  ==.

gen csumpub40_50  = 1  if  csum_inpubmed   > csumpub40 & csum_inpubmed   <= csumpub50
replace csumpub40_50  =0 if csumpub40_50  ==.

gen csumpub50_60  = 1  if  csum_inpubmed   > csumpub50 & csum_inpubmed   <= csumpub60
replace csumpub50_60  =0 if csumpub50_60  ==.

gen csumpub60_70  = 1  if  csum_inpubmed   > csumpub60 & csum_inpubmed   <= csumpub75
replace csumpub60_70  =0 if csumpub60_70  ==.

gen csumpub70_80  = 1  if  csum_inpubmed   > csumpub75 & csum_inpubmed   <= csumpub80
replace csumpub70_80  =0 if csumpub70_80  ==.

gen csumpub80_90  = 1  if  csum_inpubmed   > csumpub80 & csum_inpubmed   <= csumpub90
replace csumpub80_90  =0 if csumpub80_90  ==.

gen csumpub90_95  = 1  if  csum_inpubmed   > csumpub90 & csum_inpubmed   <= csumpub95
replace csumpub90_95  =0 if csumpub90_95  ==.

gen csumpub95_99  = 1  if  csum_inpubmed   > csumpub95 & csum_inpubmed   <= csumpub99
replace csumpub95_99  =0 if csumpub95_99  ==.

gen csumpub99_100  = 1  if  csum_inpubmed   > csumpub99
replace csumpub99_100  =0 if csumpub99_100  ==.



_pctile csum_cit_nslf, nq(100) 
gen csumcite05=r(r5) 
gen csumcite10=r(r10) 
gen csumcite15=r(r15) 
gen csumcite25=r(r25) 
gen csumcite30=r(r30)
gen csumcite40=r(r40) 
gen csumcite50=r(r50) 
gen csumcite60=r(r60) 
gen csumcite75=r(r75) 
gen csumcite80=r(r80)
gen csumcite90=r(r90) 
gen csumcite95=r(r95) 
gen csumcite99=r(r99) 


gen csumcite05_10 = 1  if  csum_incitemed   > csumcite05 & csum_incitemed   <= csumcite10
replace csumcite05_10 =0 if csumcite05_10 ==.

gen csumcite10_15 = 1  if  csum_incitemed   > csumcite10 & csum_incitemed   <= csumcite15
replace csumcite10_15 =0 if csumcite10_15 ==.

gen csumcite15_25 = 1  if  csum_incitemed   > csumcite15 & csum_incitemed   <= csumcite25
replace csumcite15_25 =0 if csumcite15_25 ==.

gen csumcite25_30 = 1  if  csum_incitemed   > csumcite25 & csum_incitemed   <= csumcite30
replace csumcite25_30 =0 if csumcite25_30 ==.


gen csumcite30_40  = 1  if  csum_incitemed   > csumcite30 & csum_incitemed   <= csumcite40
replace csumcite30_40  =0 if csumcite30_40  ==.

gen csumcite40_50  = 1  if  csum_incitemed   > csumcite40 & csum_incitemed   <= csumcite50
replace csumcite40_50  =0 if csumcite40_50  ==.

gen csumcite50_60  = 1  if  csum_incitemed   > csumcite50 & csum_incitemed   <= csumcite60
replace csumcite50_60  =0 if csumcite50_60  ==.

gen csumcite60_70  = 1  if  csum_incitemed   > csumcite60 & csum_incitemed   <= csumcite75
replace csumcite60_70  =0 if csumcite60_70  ==.

gen csumcite70_80  = 1  if  csum_incitemed   > csumcite75 & csum_incitemed   <= csumcite80
replace csumcite70_80  =0 if csumcite70_80  ==.

gen csumcite80_90  = 1  if  csum_incitemed   > csumcite80 & csum_incitemed   <= csumcite90
replace csumcite80_90  =0 if csumcite80_90  ==.

gen csumcite90_95  = 1  if  csum_incitemed   > csumcite90 & csum_incitemed   <= csumcite95
replace csumcite90_95  =0 if csumcite90_95  ==.

gen csumcite95_99  = 1  if  csum_incitemed   > csumcite95 & csum_incitemed   <= csumcite99
replace csumcite95_99  =0 if csumcite95_99  ==.

gen csumcite99_100  = 1  if  csum_incitemed   > csumcite99
replace csumcite99_100  =0 if csumcite99_100  ==.

keep pmid csumcite05_10 csumcite10_15 csumcite15_25 csumcite25_30 csumcite30_40 csumcite40_50 csumcite50_60 csumcite60_70 csumcite70_80 csumcite80_90 csumcite90_95 csumcite95_99 csumcite99_100 csumpub05_10 csumpub10_15 csumpub15_25 csumpub25_30 csumpub30_40 csumpub40_50 csumpub50_60 csumpub60_70 csumpub70_80 csumpub80_90 csumpub90_95 csumpub95_99 csumpub99_100
duplicates drop 
joinby pmid using matched_papers_obs

save matched_papers_obs, replace 
