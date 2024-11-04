* calculates E-G index;
* syntax: egen ind=egindex(category_id), by(unit)
* eg: egen ind=egindex(mesh_heading), by(setnb)

program _gegindex_b
	version 9
	syntax newvarname =/exp [if] [in], by(varlist)
	
	* touse indicates only vars satisfying `if' and `in' are to be used
	marksample touse, novarlist 

	local exp = subinstr("`exp'","(","",.)
	local exp = subinstr("`exp'",")","",.)
*	disp("exp: `exp'")

	local by = subinstr("`by'","(","",.)
	local by = subinstr("`by'",")","",.)
*	tokenize `by1', parse(" ")
*	disp "1=|`by'|, 2=|`2'|"	
	
	tempvar h t sum sum1 sum1a sum2  x share z tag_exp tag_exp_1 tag_2 c
	quietly {
		* `x' is share of `exp' in overall population;
		gen `c' = 1 if `touse'
		egen `sum' = total(`c')
		bys `exp': egen `x' = total(`c')
		disp("x")
		replace `x' = `x'/`sum'		
		drop `sum'

		* H-index for population
		egen `tag_exp' = tag(`exp') if `touse'
		egen `t' = total(`x'^2) if `tag_exp'==1
		egen `h' = max(`t')
		drop `t'
		disp("h")
		sum `h'

		* `share' is share of `exp' by `by';
		bys `by': egen `sum' = total(`c')
		* `z' is share of `exp' by `by';
		gen `z' = 1/`sum'
		bys `exp' `by': egen `share' = total(`c')
		replace `share' = `share'/`sum'
		drop `sum'
		disp("x")
		sum `x'

		*`sum1' is sum((share-x)^2) within `by'
		* tag values of exp within each `by'
		egen `tag_exp_1' = tag(`exp' `by') if `touse'
		bys `by': egen `sum1' = total((`share'-`x')^2*`tag_exp_1')
		bys `by': egen `sum1a' = total(`x'^2*`tag_exp_1')
		replace `sum1' = `sum1'+`h'-`sum1a'
		
		gen `t' = (`sum1' - (1-`h')*`z')/((1-`h')*(1-`z'))
		bys `by': egen `varlist' = max(`t')
		
		label var `varlist' "E/G index of `exp' by `by'"
	} 	

end
