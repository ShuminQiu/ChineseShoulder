
***** ***** * PART 1: SPLIT "LAST_NAME" INTO SINGLE WORD "SURNAME" * ***** *****
use "us_authors.dta", clear
sort last_name
gen id = _n

//Clean special characters in surnames
gen surname_full = upper(last_name) 
gen surname = upper(last_name)
drop last_name
gen country_ln = ""
label var country_ln "Country mapping"

*charlist surname //&'()-./0127ABCDEFGHIJKLMNOPQRSTUVWXYZ
* drop special characters only in institution names
drop if strpos(surname, "&") | strpos(surname, "/") | ///
	    strpos(surname, "0") | strpos(surname, "1") | ///
		strpos(surname, "2") | strpos(surname, "7")
* clean "."
replace surname = subinstr(surname, "ST.", "ST", .)
forval i = 1/2 {
	replace surname = trim(substr(surname, 3, strlen(surname)-3)) if strpos(surname, ".") == 2
}
replace surname = trim(substr(surname, 1, strlen(surname)-2)) ///
	if strpos(surname, ".") == strlen(surname)-1 & strpos(surname, ".") != 0
replace surname = trim(substr(surname, 1, strlen(surname)-3)) ///
	if strpos(surname, ".") == strlen(surname)-2 & strpos(surname, ".") != 0
replace surname = trim(substr(surname, 1, strlen(surname)-3)) ///
	if strpos(surname, ".") == strlen(surname)
replace surname = subinstr(surname, ".", " ", .)
* clean "(...)"
gen temp1 = strpos(surname, "(")
gen temp2 = strpos(surname, ")")
gen temp = substr(surname, temp1, temp2 - temp1 + 2) if temp1 != .
replace surname = trim(subinstr(surname, temp, "", .)) if temp != ""
replace surname = subinstr(surname, "  ", " ", .)
drop temp*
* clean apostrophe
gen temp = strpos(surname, "'")
gen tempstr = substr(surname, temp-1, 2) if temp
*tab tempstr
gen marked = ///
	((tempstr == "D'" | tempstr == "O'" | tempstr == "L'") & ///
	 (temp == 2 | substr(surname, temp - 2, 1) == "-")) | ///
	(strpos(surname, "DELL'") | strpos(surname, "DALL'")) 
replace surname = subinstr(surname, "D' ", "D'", .) if marked
replace surname = subinstr(surname, "O' ", "O'", .) if marked
replace surname = subinstr(surname, "L' ", "L'", .) if marked
	replace surname = trim(subinstr(surname, "'", " ", .)) if temp & !marked
replace surname = subinstr(surname, "  ", " ", .)	
drop temp* marked
* clean hyphen
gen temp = strpos(surname, "-")
replace surname = trim(subinstr(surname, "-", " ", .)) if inrange(temp, 1, 4) //unlikely to be joint surnames
replace surname = subinstr(surname, "  ", " ", .)	
drop temp
gen tempstr = subinstr(surname, "-", "", .)
gen temp = strlen(surname) - strlen(tempstr)
replace surname = trim(subinstr(surname, "-", " ", .)) if temp > 1
replace surname = subinstr(surname, "  ", " ", .)
drop temp*	
* clean "II", "III", "IV", "V", "JR", "SR"
replace surname = substr(surname, 1, strlen(surname)-2) if ///
	inlist(substr(surname, -2, 2), " V")
replace surname = substr(surname, 1, strlen(surname)-3) if ///
	inlist(substr(surname, -3, 3), " II", " LL", " IV", " LV", " JR", " SR")
replace surname = substr(surname, 1, strlen(surname)-4) if ///
	inlist(substr(surname, -4, 4), " III", "LLL")
	
//Clean "trouble-maker" Vietnamese names (i.e., full names recorded as last names)
replace country_ln = "Vietnamese" ///
	if strpos(surname, "NGUYEN") | ///
	   (strpos(surname, "PHAM ") == 1 | strpos(surname, "PHAM-") == 1 | strpos(surname, " PHAM")) | ///
	   (strpos(surname, "PHAN ") == 1 | strpos(surname, "PHAN-") == 1 | strpos(surname, " PHAN")) | ///
	   (strpos(surname, "TRAN ") == 1 | strpos(surname, "TRAN-") == 1 | strpos(surname, " TRAN")) | ///
	   (strpos(surname, "ANH ") | strpos(surname, "ANH-")) | ///
	   (strpos(surname, "INH ") | strpos(surname, "INH-")) | ///
	   strpos(surname, "UONG") | strpos(surname, "UYET") | strpos(surname, "UYNH") | ///
       inlist(surname, "VAN DUY", "VAN HA", "VAN SANG LE", "VAN TAM", ///
	                   "XUAN VAN LE", "TAM TRIET NGO DUC", "THI TUC NGHI LE")
					   
//Filter special cases of country-specific prefixes
replace surname = " " + surname 
* VAN* -> Dutch
replace country_ln = "Dutch" if country_ln == "" & ///
	(strpos(surname, " VAN ") | strpos(surname, " VANDE ") | ///
	 strpos(surname, " VANDEN ") | strpos(surname, " VANDER ") | ///
	 strpos(surname, " VAN'T ") | strpos(surname, " VANT "))
replace country_ln = "Dutch" if country_ln == "" & ///
	(strpos(surname, " VANDE") == 1 | ///
	 strpos(surname, " VANDEN") == 1 | ///
	 strpos(surname, " VANDER") == 1)
* VON*, VOM, ZUR -> German
replace country_ln = "German" if country_ln == "" & ///
	(strpos(surname, " VON ") | strpos(surname, " VONDER ") | ///
	 strpos(surname, " VOM ") | strpos(surname, " ZUR "))
* O' -> Irish
replace country_ln = "Irish" if country_ln == "" & strpos(surname, " O'")
* LE, LES, DU, DES, L', D'H -> French
replace country_ln = "French" if country_ln == "" & ///
	(/*strpos(surname, " LE ") |*/ strpos(surname, " LES ") | ///
	 strpos(surname, " DU ") | strpos(surname, " DES ") | ///
	 strpos(surname, " L'") | strpos(surname, " D'H"))
* LO, DI, DAL, DALLA, DELLA, DALL', DELL' -> Italian
replace country_ln = "Italian" if country_ln == "" & /// 
	(strpos(surname, " LO ") | strpos(surname, " DI ") | strpos(surname, " DAL ") | ///
	 strpos(surname, " DALLA ") | strpos(surname, " DELLA ") | ///
	 strpos(surname, " DALL'") == 1 | strpos(surname, " DELL'") == 1)
* DOS, ...E..., FILHO; DA -> Portuguese
replace country_ln = "Portuguese" if country_ln == "" & ///
	(strpos(surname, " DOS ") | strpos(surname, " E ") | ///
	 strpos(surname, "FILHO") | strpos(surname, " DA "))
* LOS, ...I/Y..; SAN -> Hispanic 
replace country_ln = "Hispanic" if country_ln == "" & ///
	(strpos(surname, " LOS ") | strpos(surname, " SAN ") | ///
	 strpos(surname, " I ") > 1 | strpos(surname, " Y ") > 1)
* WOJ* -> Polish	 
replace country_ln = "Polish" if country_ln == "" & strpos(surname_full, " WOJ") 	 
* AL, EL, UL, BIN, HAJ, MOHD, ABU, ABD*  -> Arabic
replace country_ln = "Arabic" if country_ln == "" & ///
	(inlist(substr(surname, 1, 4), " AL ", " EL ", " EL-", " UL ") | ///
	 inlist(substr(surname, 1, 5), " ABU ", " BIN ", " HAJ ") | ///
	 (strpos(surname, "ABD")  | strpos(surname, " ABU ") | ///
	 strpos(surname, " BIN ") | strpos(surname, " HAJ ") | ///
	 strpos(surname, " ALI ") | strpos(surname, "ALI ") == 1))
gen temp = strpos(surname, "AHM")
replace country_ln = "Arabic" if country_ln == "" & temp > 0 & ///
	(substr(surname_full, temp + 3, 1) == "D" | substr(surname_full, temp + 4, 1) == "D")
drop temp	

replace surname = substr(surname, 2, strlen(surname)-1)
save "TEMP us_authors.dta", replace	

//Manually clean special cases before spliting
replace country_ln = "German" if surname == "MEYER-AUF-DER-HEIDE"
replace country_ln = "Hispanic" if surname == "FDEZ SANZ"
replace country_ln = "Hispanic" if surname == "LOPEZ-RAM-DE-VIU"
replace country_ln = "Hispanic" if surname == "OTERO-DE-LA-ROZA"
replace country_ln = "Hispanic" if inlist(surname, "LA O", "IA O")
replace country_ln = "Portugese" if strpos(surname, "-DOS-")
replace country_ln = "Arabic" ///
	if strpos(surname, "-AL-") | strpos(surname, "-UL-") | ///
	   strpos(surname, "-ABU-") | strpos(surname, "-BIN-")
replace surname = subinstr(surname, "-DE-", "", .)
replace surname = subinstr(surname, "-DA-", "", .)
replace country_ln = "" if inlist(surname, "DU SHI-XUAN", "DU LI", "DU LEE")
replace surname = "KYLE CORDOVA" if surname == "KYLE E CORDOVA"
replace surname = "DU SHI XUAN" if surname == "DU SHI-XUAN"
save "TEMP us_author names.dta", replace
keep if country_ln != ""
save "TEMP us_author country_ln.dta"
	
	   
//Split surnames into single-word surnames
use "TEMP us_author names.dta", replace
drop if country_ln != ""
replace surname = subinstr(surname, "'", " ", .) //mostly names with "D'"
keep id surname*
* split by hyphen
split surname, p("-")
drop surname
reshape long surname, i(id surname_full) j(n1)
drop if surname == "" 
* split by space
split surname, p(" ")
drop if surname5 != "" //all institution names
drop surname5 surname6
gen marked = surname4 != ""
gen mmarked = marked & (strpos(surname, " DE ") | strpos(surname, "DE LA"))
drop if marked & !mmarked
forval i = 1/4 {
	replace surname`i' = "" if mmarked & inlist(surname`i', "DE", "LA")
}
drop *marked
gen marked = 1 if !strpos(surname, " ")
gen surname0 = subinstr(surname, " ", "", .) if strpos(surname, " ")
replace marked = 0 if surname0 != ""
gen surname7 = "ST" + surname2 if surname1 == "SAINT" & surname2 != ""
replace surname7 = "MC" + surname2 if surname1 == "MAC" & surname2 != ""
replace surname7 = subinstr(surname1, "MAC", "MC", 1) ///
	if substr(surname1, 1, 3) == "MAC" & strlen(surname1) >= 6
replace surname2 = "" if inlist(surname1, "ST", "SAINT", "MC", "MAC", "FITZ")
replace surname1 = "" if surname2 != "" & ///
	(inlist(surname1, "DE", "LA", "DEL", "DELA", "ST", "MC") | ///
	 inlist(surname1, "SAINT", "MAC", "FITZ", "BAR", "BEN"))
replace surname2 = "" if inlist(surname2, "DE", "LA", "DEL", "DELA", "ST", "MC")
gen temp = strpos(surname1, "'")
replace surname7 = substr(surname1, temp+1, strlen(surname1)-temp) if temp > 0
replace surname1 = subinstr(surname1, "'", "", .) if temp > 0
drop temp
ren surname surname_split
reshape long surname, i(id surname_full n1 surname_split) j(n2)
drop if surname == "" | strlen(surname) == 1
replace marked = (n2 == marked) 
compress
save "TEMP us_author single-word surnames.dta", replace
* note: 
* 	marked == 1 iff 
*		(strpos(surname_split, " ") == 0 & surname == surname_split) | 
* 	    (strpos(surname_split, " ") != 0 & surname == subinstr(surname_split, " ", "", .))


***** *** PART 2: MAP SINGLE-WORD SURNAMES TO WVSCODES (COUNTRY CODES) *** *****

//Merge single-word surnames to Census-based surname-sharewvs* matrix
use "TEMP us_author single-word surnames.dta", clear
merge m:1 surname using "${IPUMS}/Last name origin matrix ${vipums} WVS.dta" 
drop if _m != 3 | case == 0
drop precount midcount _m
drop if case == 1 & postcount < 10
save "TEMP us_author surnames WVS RAW.dta", replace

//Aggregate single-word surname shares into surname_full shares
* step 1: drop surnames with too few occurence in IPUMS
drop if case == 1 & postcount < 100

* step 2: in case subinstr(surname_split, " ", "", .) is matched
* drop the splited component surnames 
* E.g., 
*	A'HEARN is splited in to AHEARN, A (already dropped), and HEARN
* 	if AHEARN is matched, then HEARN is no longer considered
bysort surname_full surname_split: egen hasmarked = max(marked)
drop if hasmarked & !marked
drop *marked

* step 3: aggregate matched surname's into surname_split with equal weights
foreach var of varlist postcount-sharewvs70000 {
	bysort surname_full surname_split: egen temp = mean(`var')
	replace `var' = temp
	drop temp
}
keep id surname_full n1 surname_split sharewvs* *count case

* step 4: aggregate matched surname_split's into surname_full with equal weights
foreach var of varlist postcount-sharewvs70000 {
	bysort surname_full: egen temp = mean(`var')
	replace `var' = temp
	drop temp
}
keep id surname_full sharewvs* *count case
save "TEMP us_author surnames WVS FINAL.dta", replace







***** ***** *** PART 3: FILTER REMAINING UNMATCHED SPECIAL CASES *** ***** *****

//Filter remaning special cases among unmatched surnames
/*
		BPLcode	GSScode	WVScode	EUBMcode
Danish		400		  7		208		   7
Finnish		401		  9		246		  16
Norwegian	404		 19		578       15
Swede		405		 26		752		  17
English		410		  8		826		  19
Scotish		411		 24		826		  20
Irish		414		 14	  41400		   8
French		421		 10		250        1
Dutch		425		 18		528		   3
Greece		433		 12		300	      11
Italian		434		 15		380        5
Portuguese	436		 32		620		  13
Spanish		438		 25		724       12
Austrian	450		  2		 40       18
Czech		452		  6	  45200	      24
German		453		 11		276        4
Polish		455		 21		616       26
Yugoslavic	457		 34	  45700       30
Russian		465		 23	  46500	      28
Mexican		200		 17	    484       99 //coded to missing instead of Spanish
Cuban		250		250	  	214		  99 //coded to missing instead of Spanish	
Vietnamese	518		519		704		  99	
Indian		521		 31		356       99
Jewish 	  53440		100		376		  99
Arabic			     37	  54700		  99

* Notes: 
*	(1) thorough scan through all GSS countries' common surname construction 
*	(2) includes bplcodes (IPUMS codes) with at least 10% of total counts;
*	(3) shares are calculated among included codes and rounded by 0.1
*/

gen marked = 1 //for all remaining unmatched surnames
* English surnames
* 8 - English, 14 - Irish
replace sharegss8  = 1   if marked & ///
	(substr(surname, -5, 5) == "WAITE" | substr(surname, -6, 6) == "WAITES")
replace sharegss8  = 0.7 if marked & substr(surname, -5, 5) == "COMBE"
replace sharegss14 = 0.3 if marked & substr(surname, -5, 5) == "COMBE"	
replace marked = marked & sharegss8 == .
* Irish/Scotish surnames
* 14 - Irish, 24 - Scotish
replace sharegss14 = 1   if marked & strpos(surname, "FITZ") == 1
replace sharegss14 = 0.8 if marked & strpos(surname, "MC") == 1
replace sharegss24 = 0.2 if marked & strpos(surname, "MC") == 1
replace marked = marked & sharegss14 == .
* French surnames
replace sharegss10 = 1   if marked & strpos(surname, "EAU")
replace marked = marked & sharegss10 == .
* Greek surnames
replace sharegss12 = 1   if marked & (strpos(surname, "OULO") | /// 
	inlist(substr(surname, -4, 4), "AKIS", "AKOS", "ATOS", "IDES", "IDIS", "OTIS", "TSIS", "TZIS", "ULOS"))
replace marked = marked & sharegss12 == .
* Italian surnames 
replace sharegss15 = 1   if marked & ///	
	(inlist(substr(surname, -4, 4), "ILLO", "ELLO", "ELLI", "ELIO", "ETTO", "ETTA", "IONE", "IANO", "LINI") | ///
	 inlist(substr(surname, -4, 4), "AZZO", "ASSO", "OSSO", "ETTI", "OTTI", "UTTI", "ELLA") | ///
	 strpos(surname, "ZZ") | strpos(surname, "CC") | strpos(surname, "CHIO") | ///
	 strpos(surname, "GLIO") | strpos(surname, "GLIA"))
replace marked = marked & sharegss15 == .
* Hispanic surnames
* 17 - Mexican, 25 - Spanish
replace sharegss17 = 0.8 if marked & (substr(surname, -2, 2) == "EZ" | country_ln == "Hispanic")
replace sharegss25 = 0.2 if marked & (substr(surname, -2, 2) == "EZ" | country_ln == "Hispanic")
replace marked = marked & sharegss17 == .
* German surnames 
* note: derived from stems of top-20 common German surnames
replace sharegss11 = 1   if marked & ///	
	(inlist(substr(surname, -6, 6), "BERGER", "ZINGER") | ///
	 inlist(substr(surname, -4, 4), "BACH", "BECK", "MANN") | strpos(surname, "JUNG") == 1 | ///
	 strpos(surname, "AEU") | strpos(surname, "AUER") | strpos(surname, "OEC") | strpos(surname, "OENE") | ///
	 strpos(surname, "SCHMID") | strpos(surname, "SCHMIT") | strpos(surname, "SCHNEID") | ///
	 strpos(surname, "MAYER") | strpos(surname, "MEYER") | strpos(surname, "MEIER") | ///
	 strpos(surname, "SCHU") | strpos(surname, "SCHR") | strpos(surname, "HOFF") |  ///
	 strpos(surname, "MULLER") | strpos(surname, "WAGNER") | strpos(surname, "ZIMMER") | ///
	 strpos(surname, "HEIM") | strpos(surname, "WEIN") | strpos(surname, "WALTER"))
replace marked = marked & sharegss11 == .
* German/Swede surnames
* 11 - German, 26 - Swede, 23 - Russian
replace sharegss11 = 0.7 if marked & substr(surname, -4, 4) == "BURG" 
replace sharegss26 = 0.3 if marked & substr(surname, -4, 4) == "BURG"
replace sharegss26 = 0.4 if marked & substr(surname, -4, 4) == "BERG"
replace sharegss11 = 0.3 if marked & substr(surname, -4, 4) == "BERG" 
replace sharegss23 = 0.3 if marked & substr(surname, -4, 4) == "BERG" 
replace marked = marked & sharegss11 == .
* Scadanavian surnames
* 26 - Swede, 19 - Norwegian, 7 - Danish, 9 - Finnish, 11 - German
replace sharegss26 = 1   if marked & substr(surname, -5, 5) == "STROM"   
replace sharegss19 = 1   if marked & substr(surname, -4, 4) == "STAD"
replace sharegss19 = 0.6 if marked & substr(surname, -4, 4) == "AARD"
replace sharegss7  = 0.4 if marked & substr(surname, -4, 4) == "AARD" 
replace sharegss7  = 0.5 if marked & substr(surname, -3, 3) == "SEN"
replace sharegss19 = 0.2 if marked & substr(surname, -3, 3) == "SEN"
replace sharegss11 = 0.2 if marked & substr(surname, -3, 3) == "SEN"
replace sharegss26 = 0.1 if marked & substr(surname, -3, 3) == "SEN"
replace sharegss9  = 1   if marked & inlist(substr(surname, -4, 4), "ANEN", "ONEN")
replace marked = marked & sharegss26 == . & sharegss19 == . & sharegss7 == . & sharegss9 == .
* Eastern European surnames
* 23 - Russian, 34 - Yugoslavic, 21 - Polish, 6 - Czech, 11 - German, 2 - Austrian
replace sharegss23 = 0.6 if marked & inlist(substr(surname, -2, 2), "EV", "OV")
replace sharegss34 = 0.2 if marked & inlist(substr(surname, -2, 2), "EV", "OV")
replace sharegss11 = 0.2 if marked & inlist(substr(surname, -2, 2), "EV", "OV")
replace sharegss23 = 0.6 if marked & substr(surname, -3, 3) == "OFF" //conditional on not "HOFF"
replace sharegss11 = 0.4 if marked & substr(surname, -3, 3) == "OFF"
replace sharegss34 = 0.5 if marked & (substr(surname, -3, 3) == "VIC" | substr(surname, -4, 4) == "VICH")
replace sharegss2  = 0.2 if marked & (substr(surname, -3, 3) == "VIC" | substr(surname, -4, 4) == "VICH")
replace sharegss6  = 0.1 if marked & (substr(surname, -3, 3) == "VIC" | substr(surname, -4, 4) == "VICH")
replace sharegss21 = 0.1 if marked & (substr(surname, -3, 3) == "VIC" | substr(surname, -4, 4) == "VICH")
replace sharegss23 = 0.1 if marked & (substr(surname, -3, 3) == "VIC" | substr(surname, -4, 4) == "VICH")
replace marked = marked & sharegss23 == .
replace sharegss21 = 1 if marked & (strpos(surname, "CZ") | strpos(surname, "SZ"))
replace marked = marked & sharegss21 == .
replace sharegss23 = 0.5 if marked & (strpos(surname, "WSKY") | substr(surname, -3, 3) == "SKY")
replace sharegss21 = 0.3 if marked & (strpos(surname, "WSKY") | substr(surname, -3, 3) == "SKY")
replace sharegss6  = 0.1 if marked & (strpos(surname, "WSKY") | substr(surname, -3, 3) == "SKY")
replace sharegss11 = 0.1 if marked & (strpos(surname, "WSKY") | substr(surname, -3, 3) == "SKY")
replace sharegss21 = 0.9 if marked & (strpos(surname, "WSKI") | substr(surname, -3, 3) == "SKI")
replace sharegss11 = 0.1 if marked & (strpos(surname, "WSKI") | substr(surname, -3, 3) == "SKI")
replace marked = marked & sharegss23 == . & sharegss21 == .
replace sharegss21 = 0.6 if marked & strpos(surname, "KOW") //conditional on not other cases
replace sharegss23 = 0.4 if marked & strpos(surname, "KOW") 
replace marked = marked & sharegss23 == . & sharegss21 == .
replace sharegss11 = 0.6 if marked & substr(surname, -4, 4) == "BAUM"
replace sharegss23 = 0.3 if marked & substr(surname, -4, 4) == "BAUM"
replace sharegss21 = 0.1 if marked & substr(surname, -4, 4) == "BAUM"
replace marked = marked & sharegss23 == . & sharegss21 == .
* Indian surnames
replace sharegss31 = 1   if marked & ///
	(strpos(surname, "VENKAT") | strpos(surname, "GOPAL") | strpos(surname, "RAJA") | strpos(surname, "JAYA") | ///
	 strpos(surname, "BHAT") | strpos(surname, "DHR") | strpos(surname, "SUDEVAN") | strpos(surname, "CHANDRA") | ///
	 strpos(surname, "KUMAR") | strpos(surname, "NATHAN") > 1)
replace marked = marked & sharegss31 == .
