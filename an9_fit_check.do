
/* Idea - look at distribution of outcomes at three points */
cd "S:\ECHO_IHI_CPRD\Matt\ACED4_SymptomPPVWork"

set scheme s1color

collect clear
frames reset

frame create model

/******************************************************************************/
/* Load outcomes dataset */
frame model {
	use SIM_RESULTS_2023-03-06/inc_combined.dta, clear
	desc
	keep if !male
	
	keep if inlist(time, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
	
	rename prob_2  prob_Breast
	rename prob_3  prob_Gynaecological
	rename prob_4  prob_Lung
	rename prob_5  prob_UpperGI
	rename prob_6  prob_LowerGI
	rename prob_7  prob_Urological
	rename prob_8  prob_Haematological
	rename prob_9  prob_Other
	rename prob_10 prob_Death
	
	keep index male smoker age time prob_*
	duplicates drop
	
}



use ../../Data/Matt/ACED4_Data/analysis_file, clear
keep if !male

gen age_new = round(age/5)*5
tab age_new
summ age if age_new == 30
summ age if age_new == 35

replace age = age_new
drop age_new

expand 12
sort e_patid 
by e_patid : gen time = _n

frlink m:1 index_symptom male smoker age time, frame(model)
assert age == 100 if missing(model)
drop if age == 100

decode new_cancer, gen(str_cancer)
replace str_cancer = subinstr(str_cancer, " ", "", .)
replace str_cancer = "Other" if str_cancer == "Othercancer"

levelsof str_cancer, local(cancers)

foreach cas in `cancers' {
	gen act_`cas' = (date_cancer-index_symptom_date <= time*30) & (str_cancer == "`cas'")
	frget prob_`cas', from(model)
}

gen act_Death = (date_death-index_symptom_date <= time*30) & (date_death < date_cancer)
frget prob_Death, from(model)

keep e_patid male age smoker imd index_symptom index_symptom_date time act_* prob_*

save ../../Data/Matt/ACED4_Data/model_fit_women_2023-03-14, replace

/******************************************************************************/
/* Check fit */

* overall
use ../../Data/Matt/ACED4_Data/model_fit_women_2023-03-14, clear

gen count = 1

collapse (sum) prob_* act_* count, by(index_symptom time)
foreach thing in Breast Gynaecological Haematological LowerGI Lung Other UpperGI Urological Death {
	gen resid_`thing' = act_`thing'-prob_`thing'
	replace resid_`thing' = 100*resid_`thing'/count
}

summ resid*

twoway	(line resid_Breast         time, lcol("153 142 195") ) /// 
		(line resid_Gynaecological time, lcol("84 39 136"  ) ) /// 
		(line resid_Lung           time, lcol("253 191 111") ) /// 
		(line resid_UpperGI        time, lcol("227 26 28"  ) ) /// 
		(line resid_LowerGI        time, lcol("251 154 153") ) /// 
		(line resid_Urological     time, lcol("51 160 44"  ) ) /// 
		(line resid_Haematological time, lcol("31 120 180" ) ) /// 
		(line resid_Other          time, lcol("166 206 227") ) /// 
		(line resid_Death          time, lcol(gs0          ) ) /// 
		,	by(index_symptom, cols(3) legend(off) yrescale) ///
			ylabel(, angle(h)) /// 
			xsc(r(1 12)) ///
			xlabel(1(1)12)  ///
			xsize(4) ///
			ysize(6) 
graph export model_fit/women_fit1_overall.png, replace width(1000)

* non-smokers
use ../../Data/Matt/ACED4_Data/model_fit_women_2023-03-14, clear
keep if !smoker

gen count = 1

collapse (sum) prob_* act_* count, by(index_symptom time)
foreach thing in Breast Gynaecological Haematological LowerGI Lung Other UpperGI Urological Death {
	gen resid_`thing' = act_`thing'-prob_`thing'
	replace resid_`thing' = 100*resid_`thing'/count
}

summ resid*

twoway	(line resid_Breast         time, lcol("153 142 195") ) /// 
		(line resid_Gynaecological time, lcol("84 39 136"  ) ) /// 
		(line resid_Lung           time, lcol("253 191 111") ) /// 
		(line resid_UpperGI        time, lcol("227 26 28"  ) ) /// 
		(line resid_LowerGI        time, lcol("251 154 153") ) /// 
		(line resid_Urological     time, lcol("51 160 44"  ) ) /// 
		(line resid_Haematological time, lcol("31 120 180" ) ) /// 
		(line resid_Other          time, lcol("166 206 227") ) /// 
		(line resid_Death          time, lcol(gs0          ) ) /// 
		,	by(index_symptom, cols(3) legend(off) yrescale) ///
			ylabel(, angle(h)) /// 
			xsc(r(1 12)) ///
			xlabel(1(1)12) ///
			xsize(4) ///
			ysize(6) 
graph export model_fit/women_fit2_nonsmokers.png, replace width(1000)

* smokers
use ../../Data/Matt/ACED4_Data/model_fit_women_2023-03-14, clear
keep if  smoker

gen count = 1

collapse (sum) prob_* act_* count, by(index_symptom time)
foreach thing in Breast Gynaecological Haematological LowerGI Lung Other UpperGI Urological Death {
	gen resid_`thing' = act_`thing'-prob_`thing'
	replace resid_`thing' = 100*resid_`thing'/count
}

summ resid*

twoway	(line resid_Breast         time, lcol("153 142 195") ) /// 
		(line resid_Gynaecological time, lcol("84 39 136"  ) ) /// 
		(line resid_Lung           time, lcol("253 191 111") ) /// 
		(line resid_UpperGI        time, lcol("227 26 28"  ) ) /// 
		(line resid_LowerGI        time, lcol("251 154 153") ) /// 
		(line resid_Urological     time, lcol("51 160 44"  ) ) /// 
		(line resid_Haematological time, lcol("31 120 180" ) ) /// 
		(line resid_Other          time, lcol("166 206 227") ) /// 
		(line resid_Death          time, lcol(gs0          ) ) /// 
		,	by(index_symptom, cols(3) legend(off) yrescale) ///
			ylabel(, angle(h)) /// 
			xsc(r(1 12)) ///
			xlabel(1(1)12) ///
			xsize(4) ///
			ysize(6) 
graph export model_fit/women_fit3_smokers.png, replace width(1000)

* age, month 3
use ../../Data/Matt/ACED4_Data/model_fit_women_2023-03-14, clear

gen count = 1
keep if time == 3

collapse (sum) prob_* act_* count, by(index_symptom age)
foreach thing in Breast Gynaecological Haematological LowerGI Lung Other UpperGI Urological Death {
	gen resid_`thing' = act_`thing'-prob_`thing'
	replace resid_`thing' = 100*resid_`thing'/count
}

summ resid*

twoway	(line resid_Breast         age, lcol("153 142 195") ) /// 
		(line resid_Gynaecological age, lcol("84 39 136"  ) ) /// 
		(line resid_Lung           age, lcol("253 191 111") ) /// 
		(line resid_UpperGI        age, lcol("227 26 28"  ) ) /// 
		(line resid_LowerGI        age, lcol("251 154 153") ) /// 
		(line resid_Urological     age, lcol("51 160 44"  ) ) /// 
		(line resid_Haematological age, lcol("31 120 180" ) ) /// 
		(line resid_Other          age, lcol("166 206 227") ) /// 
		(line resid_Death          age, lcol(gs0          ) ) /// 
		,	by(index_symptom, cols(3) legend(off) yrescale) ///
			ylabel(, angle(h)) /// 
			xsc(r(30 95)) ///
			xlabel(30(20)90)  ///
			xsize(4) ///
			ysize(6) 
graph export model_fit/women_fit4_age_month3.png, replace width(1000)

* age, month 6
use ../../Data/Matt/ACED4_Data/model_fit_women_2023-03-14, clear

gen count = 1
keep if time == 6

collapse (sum) prob_* act_* count, by(index_symptom age)
foreach thing in Breast Gynaecological Haematological LowerGI Lung Other UpperGI Urological Death {
	gen resid_`thing' = act_`thing'-prob_`thing'
	replace resid_`thing' = 100*resid_`thing'/count
}

summ resid*

twoway	(line resid_Breast         age, lcol("153 142 195") ) /// 
		(line resid_Gynaecological age, lcol("84 39 136"  ) ) /// 
		(line resid_Lung           age, lcol("253 191 111") ) /// 
		(line resid_UpperGI        age, lcol("227 26 28"  ) ) /// 
		(line resid_LowerGI        age, lcol("251 154 153") ) /// 
		(line resid_Urological     age, lcol("51 160 44"  ) ) /// 
		(line resid_Haematological age, lcol("31 120 180" ) ) /// 
		(line resid_Other          age, lcol("166 206 227") ) /// 
		(line resid_Death          age, lcol(gs0          ) ) /// 
		,	by(index_symptom, cols(3) legend(off) yrescale) ///
			ylabel(, angle(h)) /// 
			xsc(r(30 95)) ///
			xlabel(30(20)90)  ///
			xsize(4) ///
			ysize(6) 
graph export model_fit/women_fit5_age_month6.png, replace width(1000)

* age, month 12
use ../../Data/Matt/ACED4_Data/model_fit_women_2023-03-14, clear

gen count = 1
keep if time == 12

collapse (sum) prob_* act_* count, by(index_symptom age)
foreach thing in Breast Gynaecological Haematological LowerGI Lung Other UpperGI Urological Death {
	gen resid_`thing' = act_`thing'-prob_`thing'
	replace resid_`thing' = 100*resid_`thing'/count
}

summ resid*

twoway	(line resid_Breast         age, lcol("153 142 195") ) /// 
		(line resid_Gynaecological age, lcol("84 39 136"  ) ) /// 
		(line resid_Lung           age, lcol("253 191 111") ) /// 
		(line resid_UpperGI        age, lcol("227 26 28"  ) ) /// 
		(line resid_LowerGI        age, lcol("251 154 153") ) /// 
		(line resid_Urological     age, lcol("51 160 44"  ) ) /// 
		(line resid_Haematological age, lcol("31 120 180" ) ) /// 
		(line resid_Other          age, lcol("166 206 227") ) /// 
		(line resid_Death          age, lcol(gs0          ) ) /// 
		,	by(index_symptom, cols(3) legend(off) yrescale) ///
			ylabel(, angle(h)) /// 
			xsc(r(30 95)) ///
			xlabel(30(20)90)  ///
			xsize(4) ///
			ysize(6) 
graph export model_fit/women_fit6_age_month12.png, replace width(1000)







/******************************************************************************/
/* Load outcomes dataset */
frame model {
	use SIM_RESULTS_2023-03-06/inc_combined.dta, clear
	desc
	keep if  male
	
	keep if inlist(time, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
	
	rename prob_2  prob_Lung
	rename prob_3  prob_UpperGI
	rename prob_4  prob_LowerGI
	rename prob_5  prob_Urological
	rename prob_6  prob_Prostate
	rename prob_7  prob_Haematological
	rename prob_8  prob_Other
	rename prob_9  prob_Death
	
	keep index male smoker age time prob_*
	duplicates drop
	
}



use ../../Data/Matt/ACED4_Data/analysis_file, clear
keep if  male

gen age_new = round(age/5)*5
tab age_new
summ age if age_new == 30
summ age if age_new == 35

replace age = age_new
drop age_new

expand 12
sort e_patid 
by e_patid : gen time = _n

frlink m:1 index_symptom male smoker age time, frame(model)
assert age == 100 if missing(model)
drop if age == 100

decode new_cancer, gen(str_cancer)
replace str_cancer = subinstr(str_cancer, " ", "", .)
replace str_cancer = "Other" if str_cancer == "Othercancer"

levelsof str_cancer, local(cancers)

foreach cas in `cancers' {
	gen act_`cas' = (date_cancer-index_symptom_date <= time*30) & (str_cancer == "`cas'")
	frget prob_`cas', from(model)
}

gen act_Death = (date_death-index_symptom_date <= time*30) & (date_death < date_cancer)
frget prob_Death, from(model)

keep e_patid male age smoker imd index_symptom index_symptom_date time act_* prob_*

save ../../Data/Matt/ACED4_Data/model_fit_men_2023-03-14, replace

/******************************************************************************/
/* Check fit */

* overall
use ../../Data/Matt/ACED4_Data/model_fit_men_2023-03-14, clear

gen count = 1

collapse (sum) prob_* act_* count, by(index_symptom time)
foreach thing in Lung UpperGI LowerGI Urological Prostate Haematological Other Death {
	gen resid_`thing' = act_`thing'-prob_`thing'
	replace resid_`thing' = 100*resid_`thing'/count
}

summ resid*

twoway	(line resid_Lung           time, lcol("253 191 111") ) /// 
		(line resid_UpperGI        time, lcol("227 26 28"  ) ) /// 
		(line resid_LowerGI        time, lcol("251 154 153") ) /// 
		(line resid_Urological     time, lcol("51 160 44"  ) ) /// 
		(line resid_Prostate       time, lcol("178 223 138") ) /// 
		(line resid_Haematological time, lcol("31 120 180" ) ) /// 
		(line resid_Other          time, lcol("166 206 227") ) /// 
		(line resid_Death          time, lcol(gs0          ) ) /// 
		,	by(index_symptom, cols(3) holes(13) legend(off) yrescale) ///
			ylabel(, angle(h)) /// 
			xsc(r(1 12)) ///
			xlabel(1(1)12)  ///
			xsize(4) ///
			ysize(6) 
graph export model_fit/men_fit1_overall.png, replace width(1000)

* non-smokers
use ../../Data/Matt/ACED4_Data/model_fit_men_2023-03-14, clear
keep if !smoker

gen count = 1

collapse (sum) prob_* act_* count, by(index_symptom time)
foreach thing in Lung UpperGI LowerGI Urological Prostate Haematological Other Death {
	gen resid_`thing' = act_`thing'-prob_`thing'
	replace resid_`thing' = 100*resid_`thing'/count
}

summ resid*

twoway	(line resid_Lung           time, lcol("253 191 111") ) /// 
		(line resid_UpperGI        time, lcol("227 26 28"  ) ) /// 
		(line resid_LowerGI        time, lcol("251 154 153") ) /// 
		(line resid_Urological     time, lcol("51 160 44"  ) ) /// 
		(line resid_Prostate       time, lcol("178 223 138") ) /// 
		(line resid_Haematological time, lcol("31 120 180" ) ) /// 
		(line resid_Other          time, lcol("166 206 227") ) /// 
		(line resid_Death          time, lcol(gs0          ) ) /// 
		,	by(index_symptom, cols(3) holes(13) legend(off) yrescale) ///
			ylabel(, angle(h)) /// 
			xsc(r(1 12)) ///
			xlabel(1(1)12) ///
			xsize(4) ///
			ysize(6) 
graph export model_fit/men_fit2_nonsmokers.png, replace width(1000)

* smokers
use ../../Data/Matt/ACED4_Data/model_fit_men_2023-03-14, clear
keep if  smoker

gen count = 1

collapse (sum) prob_* act_* count, by(index_symptom time)
foreach thing in Lung UpperGI LowerGI Urological Prostate Haematological Other Death {
	gen resid_`thing' = act_`thing'-prob_`thing'
	replace resid_`thing' = 100*resid_`thing'/count
}

summ resid*

twoway	(line resid_Lung           time, lcol("253 191 111") ) /// 
		(line resid_UpperGI        time, lcol("227 26 28"  ) ) /// 
		(line resid_LowerGI        time, lcol("251 154 153") ) /// 
		(line resid_Urological     time, lcol("51 160 44"  ) ) /// 
		(line resid_Prostate       time, lcol("178 223 138") ) /// 
		(line resid_Haematological time, lcol("31 120 180" ) ) /// 
		(line resid_Other          time, lcol("166 206 227") ) /// 
		(line resid_Death          time, lcol(gs0          ) ) /// 
		,	by(index_symptom, cols(3) holes(13) legend(off) yrescale) ///
			ylabel(, angle(h)) /// 
			xsc(r(1 12)) ///
			xlabel(1(1)12) ///
			xsize(4) ///
			ysize(6) 
graph export model_fit/men_fit3_smokers.png, replace width(1000)

* age, month 3
use ../../Data/Matt/ACED4_Data/model_fit_men_2023-03-14, clear

gen count = 1
keep if time == 3

collapse (sum) prob_* act_* count, by(index_symptom age)
foreach thing in Lung UpperGI LowerGI Urological Prostate Haematological Other Death {
	gen resid_`thing' = act_`thing'-prob_`thing'
	replace resid_`thing' = 100*resid_`thing'/count
}

summ resid*

twoway	(line resid_Lung           age, lcol("253 191 111") ) /// 
		(line resid_UpperGI        age, lcol("227 26 28"  ) ) /// 
		(line resid_LowerGI        age, lcol("251 154 153") ) /// 
		(line resid_Urological     age, lcol("51 160 44"  ) ) /// 
		(line resid_Prostate       age, lcol("178 223 138") ) /// 
		(line resid_Haematological age, lcol("31 120 180" ) ) /// 
		(line resid_Other          age, lcol("166 206 227") ) /// 
		(line resid_Death          age, lcol(gs0          ) ) /// 
		,	by(index_symptom, cols(3) holes(13) legend(off) yrescale) ///
			ylabel(, angle(h)) /// 
			xsc(r(30 95)) ///
			xlabel(30(20)90)  ///
			xsize(4) ///
			ysize(6) 
graph export model_fit/men_fit4_age_month3.png, replace width(1000)

* age, month 6
use ../../Data/Matt/ACED4_Data/model_fit_men_2023-03-14, clear

gen count = 1
keep if time == 6

collapse (sum) prob_* act_* count, by(index_symptom age)
foreach thing in Lung UpperGI LowerGI Urological Prostate Haematological Other Death {
	gen resid_`thing' = act_`thing'-prob_`thing'
	replace resid_`thing' = 100*resid_`thing'/count
}

summ resid*

twoway	(line resid_Lung           age, lcol("253 191 111") ) /// 
		(line resid_UpperGI        age, lcol("227 26 28"  ) ) /// 
		(line resid_LowerGI        age, lcol("251 154 153") ) /// 
		(line resid_Urological     age, lcol("51 160 44"  ) ) /// 
		(line resid_Prostate       age, lcol("178 223 138") ) /// 
		(line resid_Haematological age, lcol("31 120 180" ) ) /// 
		(line resid_Other          age, lcol("166 206 227") ) /// 
		(line resid_Death          age, lcol(gs0          ) ) /// 
		,	by(index_symptom, cols(3) holes(13) legend(off) yrescale) ///
			ylabel(, angle(h)) /// 
			xsc(r(30 95)) ///
			xlabel(30(20)90)  ///
			xsize(4) ///
			ysize(6) 
graph export model_fit/men_fit5_age_month6.png, replace width(1000)

* age, month 12
use ../../Data/Matt/ACED4_Data/model_fit_men_2023-03-14, clear

gen count = 1
keep if time == 12

collapse (sum) prob_* act_* count, by(index_symptom age)
foreach thing in Lung UpperGI LowerGI Urological Prostate Haematological Other Death {
	gen resid_`thing' = act_`thing'-prob_`thing'
	replace resid_`thing' = 100*resid_`thing'/count
}

summ resid*

twoway	(line resid_Lung           age, lcol("253 191 111") ) /// 
		(line resid_UpperGI        age, lcol("227 26 28"  ) ) /// 
		(line resid_LowerGI        age, lcol("251 154 153") ) /// 
		(line resid_Urological     age, lcol("51 160 44"  ) ) /// 
		(line resid_Prostate       age, lcol("178 223 138") ) /// 
		(line resid_Haematological age, lcol("31 120 180" ) ) /// 
		(line resid_Other          age, lcol("166 206 227") ) /// 
		(line resid_Death          age, lcol(gs0          ) ) /// 
		,	by(index_symptom, cols(3) holes(13) legend(off) yrescale) ///
			ylabel(, angle(h)) /// 
			xsc(r(30 95)) ///
			xlabel(30(20)90)  ///
			xsize(4) ///
			ysize(6) 
graph export model_fit/men_fit6_age_month12.png, replace width(1000)
