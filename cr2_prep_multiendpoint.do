cd "S:\ECHO_IHI_CPRD\Matt\ACED4_SymptomPPVWork"

which merlin
which msset

** do the same analysis as in UKB
collect clear
frames reset

/******************************************************************************/
/* Load and prepare data - men */
use ../../Data/Matt/ACED4_Data/analysis_file_major_alternative, clear

* multi symptomatic
gen byte multi = !missing(symptom2)

gen fup_end = min(date_cancer, /*date_mi, date_stroke,*/ date_death, index_symptom_date+365+180)
format fup_end %tdCCYY-NN-DD

gen byte fup_cancer = new_cancer*(date_cancer == fup_end & !missing(new_cancer))
replace fup_cancer = 0 if missing(fup_cancer)
label values fup_cancer new_cancer
gen byte fup_death = date_death == fup_end

/*
gen byte fup_stroke = (date_stroke == fup_end & !missing(date_stroke))
gen byte fup_mi     = (date_mi     == fup_end & !missing(date_mi))
*/

gen byte fup_state = fup_cancer

/*
replace fup_state = 10 if fup_mi & fup_state == 0
replace fup_state = 11 if fup_stroke & fup_state == 0
*/

replace fup_state = 10 if fup_death & fup_state == 0

#delimit ;
label define fup_state	 0 "Censored" /* for use later */
						 1 "Breast" 
						 2 "Gynaecological"
						 3 "Lung"
						 4 "Upper GI"
						 5 "Lower GI"
						 6 "Urological"
						 7 "Prostate"
						 8 "Haematological"
						 9 "Other cancer"
						/*10 "MI (no cancer)"
						11 "Stroke"*/
						10 "Death"
						, replace
	;
#delimit cr
label values fup_state fup_state
tab fup_state

tab fup_state if male
gen age_grp = floor(age/10)*10
tab fup_state smoker if male & age_grp == 70
tab fup_state smoker if male & age_grp == 50

desc						
keep e_patid age male smoker imd index_symptom symptom? multi index_symptom_date fup_end fup_state

keep if male

* check no female-only cancers
assert fup_state != 1
assert fup_state != 2

forval i = 1/10 {
	gen byte state_`i' = fup_state == `i'
	local state_label : label fup_state `i'
	label var state_`i' "`state_label'"
	
	gen fup_end_`i' = fup_end-index_symptom_date
}

drop state_1
drop fup_end_1
drop state_2
drop fup_end_2

local j = 0
foreach i in 3 4 5 6 7 8 9 10 /*11 12*/ {
	local ++j
	rename state_`i' state_`j'
	rename fup_end_`i' fup_end_`j'
}

* declare multi-state survival data
matrix define tmat = 	( .,  1, 2, 3, 4, 5, 6, 7, 8 \ /// from no event 
						  .,  ., ., ., ., ., ., ., . \ /// 2
						  .,  ., ., ., ., ., ., ., . \ /// 3
						  .,  ., ., ., ., ., ., ., . \ /// 4
						  .,  ., ., ., ., ., ., ., . \ /// 5
						  .,  ., ., ., ., ., ., ., . \ /// 6
						  .,  ., ., ., ., ., ., ., . \ /// 7
						  .,  ., ., ., ., ., ., ., . \ /// 8
						  .,  ., ., ., ., ., ., ., .   /// 12
						)

matrix colnames tmat = 	no_event ///
						lung  ///
						upper_gi   ///
						lower_gi  ///
						urological   ///
						prostate  ///
						haematological   ///
						other   ///
						/*mi /// 
						stroke*/ /// 
						death  

matrix rownames tmat = 	no_event ///
						lung  ///
						upper_gi   ///
						lower_gi  ///
						urological   ///
						prostate  ///
						haematological   ///
						other   ///
						/*mi /// 
						stroke*/ /// 
						death  
matrix list tmat
msset, id(e_patid) states(state_*) times(fup_end_*) transmatrix(tmat) 

stset _stop, enter(_start) failure(_status == 1) scale(30)

* prepare and label variables
gen age_grp = 10*(floor(age/10))
replace age_grp = 40 if age_grp == 30

summ age
label define age_grp 40 "30 to 49" 50 "50 to 59" 60 "60 to 69" 70 "70 to 79", replace
label values age_grp age_grp

label var age_grp "Age at index (grouped)"
label var male "Sex"
label var imd "IMD group"
label define imd 1 "Least deprived" 5 "Most deprived", replace
label values imd imd

* fuck IMD
drop imd

* age variable
gen age_c = (age-60)/10
mkspline age_spl = age_c, cubic nknots(6)

* expand symptom var
forval i = 1/15 {
	gen byte symptom_`i' = index_symptom == `i'
	
	forval j = 2/6 {
		replace symptom_`i' = 1 if symptom`j' == `i'
	}
	
	local symptom_label : label (index_symptom) `i'
	label var symptom_`i' "`symptom_label'"	
	
}

save ../../Data/Matt/ACED4_Data/analysis_file_prepped_men_major_alternative, replace



/******************************************************************************/
/* Load and prepare data - women */
use ../../Data/Matt/ACED4_Data/analysis_file_major_alternative, clear

* multi symptomatic
gen byte multi = !missing(symptom2)

gen fup_end = min(date_cancer, /*date_mi, date_stroke,*/ date_death, index_symptom_date+365+180)
format fup_end %tdCCYY-NN-DD

gen byte fup_cancer = new_cancer*(date_cancer == fup_end & !missing(new_cancer))
replace fup_cancer = 0 if missing(fup_cancer)
label values fup_cancer new_cancer
gen byte fup_death = date_death == fup_end

/*
gen byte fup_stroke = (date_stroke == fup_end & !missing(date_stroke))
gen byte fup_mi     = (date_mi     == fup_end & !missing(date_mi))
*/

gen byte fup_state = fup_cancer

/*
replace fup_state = 10 if fup_mi & fup_state == 0
replace fup_state = 11 if fup_stroke & fup_state == 0
*/

replace fup_state = 10 if fup_death & fup_state == 0

#delimit ;
label define fup_state	 0 "Censored" /* for use later */
						 1 "Breast" 
						 2 "Gynaecological"
						 3 "Lung"
						 4 "Upper GI"
						 5 "Lower GI"
						 6 "Urological"
						 7 "Prostate"
						 8 "Haematological"
						 9 "Other cancer"
						/*10 "MI (no cancer)"
						11 "Stroke"*/
						10 "Death"
						, replace
	;
#delimit cr
label values fup_state fup_state
tab fup_state

tab fup_state if !male
gen age_grp = floor(age/10)*10
tab fup_state smoker if !male & age_grp == 70
tab fup_state smoker if !male & age_grp == 50

desc						
keep e_patid age male smoker imd index_symptom symptom? multi index_symptom_date fup_end fup_state

keep if !male

* check no male-only cancers
assert fup_state != 7

forval i = 1/15 {
	gen byte state_`i' = fup_state == `i'
	local state_label : label fup_state `i'
	label var state_`i' "`state_label'"
	
	gen fup_end_`i' = fup_end-index_symptom_date
}

drop state_7
drop fup_end_7

local j = 0
foreach i in 1 2 3 4 5 6    8 9 10 {
	local ++j
	rename state_`i' state_`j'
	rename fup_end_`i' fup_end_`j'
}

* declare multi-state survival data
matrix define tmat = 	( .,  1, 2, 3, 4, 5, 6, 7, 8,   9 \ /// from no event 
						  .,  ., ., ., ., ., ., ., .,   . \ /// 2
						  .,  ., ., ., ., ., ., ., .,   . \ /// 3
						  .,  ., ., ., ., ., ., ., .,   . \ /// 4
						  .,  ., ., ., ., ., ., ., .,   . \ /// 5
						  .,  ., ., ., ., ., ., ., .,   . \ /// 6
						  .,  ., ., ., ., ., ., ., .,   . \ /// 7
						  .,  ., ., ., ., ., ., ., .,   . \ /// 8
						  .,  ., ., ., ., ., ., ., .,   . \ /// 9
						  .,  ., ., ., ., ., ., ., .,   .   /// 12
						)

matrix colnames tmat = 	no_event ///
						breast ///
						gynaecological /// 
						lung  ///
						upper_gi   ///
						lower_gi  ///
						urological   ///
						haematological   ///
						other   ///
						/*mi /// 
						stroke*/ /// 
						death  

matrix rownames tmat = 	no_event ///
						breast ///
						gynaecological /// 
						lung  ///
						upper_gi   ///
						lower_gi  ///
						urological   ///
						haematological   ///
						other   ///
						/*mi /// 
						stroke*/ /// 
						death  
matrix list tmat
msset, id(e_patid) states(state_*) times(fup_end_*) transmatrix(tmat) 

stset _stop, enter(_start) failure(_status == 1) scale(30)

* prepare and label variables
gen age_grp = 10*(floor(age/10))
replace age_grp = 40 if age_grp == 30

summ age
label define age_grp 40 "30 to 49" 50 "50 to 59" 60 "60 to 69" 70 "70 to 79", replace
label values age_grp age_grp

label var age_grp "Age at index (grouped)"
label var male "Sex"
label var imd "IMD group"
label define imd 1 "Least deprived" 5 "Most deprived", replace
label values imd imd

* fuck IMD
drop imd

* age variable
gen age_c = (age-60)/10
mkspline age_spl = age_c, cubic nknots(6)

* expand symptom var
forval i = 1/15 {
	gen byte symptom_`i' = index_symptom == `i'
	
	forval j = 2/6 {
		replace symptom_`i' = 1 if symptom`j' == `i'
	}
	
	local symptom_label : label (index_symptom) `i'
	label var symptom_`i' "`symptom_label'"	
	
}


save ../../Data/Matt/ACED4_Data/analysis_file_prepped_women_major_alternative, replace


