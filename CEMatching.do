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


recode rltd_rnk (1/10 =1) (11/20 = 2) (21/30 =3) (31/40 =4) (41/50 = 5) (51/60 =6) (61/70 = 7) (71/80 =8) (81/90 = 9)(91/100 =10) (101/110 = 11) (111/120 =12) /*
*/ (121/130 =13) (131/140 = 14) (141/150 =15) (151/170 = 16) (171/ 190=17) (191/ 210= 18) (211/230=19) (231/260=20) (261/300=21) (301/350=22) (351/450=23) /*
*/ (451/650=24) (651/1000=25)(1001/10000000000=26), gen(rltd_rank_coarser)

replace rltd_rank_coarser = 27 if rltd_rank_coarser==.

recode m_rltd_rnk (1/30 =1) (31/60 =2)    (61/90 = 3)  (91/120 = 4)(121/180 =5) /*
*/  (181/240 = 6) (241/400=7) (401/7931=8), gen(rltd_rank_coarserrr)


destring degree_year , replace
recode degree_year (1952/1959 = 2) (1961/1963 =3) (1964/1966 =4) (1967/1969 =5) (1970/1972 = 6) (1973/1975 = 7) (1976/1978 = 8) (1979/1981 = 9) (1982/1984 = 10) (1985/1987 = 11) (1988/1990 = 12) /*
*/  (1991/1993 = 13) (1994/1996 = 14) (1997/1999 = 15) (2000/2002 = 16) (2003/2008 = 17) , gen(degree_year_coarse)



