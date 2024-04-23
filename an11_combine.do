
/* Combine symptom-specific results files */
clear
local loop_counter = 0

qui foreach male in 0 1 {
	foreach age in 90 80 70 60 50 40 30 {
		foreach smoke in 0 1 {
			forval symp = 1/15 {
				if `symp' == 13 & `male' {
					// do nothing
					// pm bleed in meb
				}
				else {
					
					if `loop_counter' == 0 {
						use all_cis/rf_male`male'_age`age'_smoker`smoke'_symptom`symp', clear
						local loop_counter = 1
					}
					else if `loop_counter' == 1 {
						cap append using all_cis/rf_male`male'_age`age'_smoker`smoke'_symptom`symp'
					}
				}
			}
		}
	}	
}

/* Neaten and format results data */
cap drop time_row time_string
cap rename (pr_*) (prob_*)

* fix symptom labelling
#delimit ;
label define symptom	 0 "No symptom"
						 1 "Abdominal pain"
						 2 "Abdominal bloating"
						 3 "Breast lump"
						 4 "Change in bowel habit"
						 5 "Dyspepsia"
						 6 "Dysphagia"
						 7 "Dyspnoea"
						 8 "Fatigue"
						 9 "Haematuria"
						10 "Haemoptysis"
						11 "Jaundice"
						12 "Night sweats"
						13 "Post-menopausal bleeding"
						14 "Rectal bleeding"
						15 "Weight loss"
						/*16 "Abdominal lump"
						17 "Constipation"
						18 "Cough"
						19 "Diarrhoea"
						20 "Pelvic pain"
						21 "Nausea / vomiting"
						22 "UTI"*/
	, replace
	;
#delimit cr
label values index_symptom symptom

* male
label define male 0 "Women" 1 "Men", replace
label values male male

* smoking
label define smoking 0 "Never smoker" 1 "Ever smoker", replace
label values smoker smoking
		
* sort 
sort male index_symptom age smoker time


* merge with point estimates
rename prob_* prob_ci_*

desc

merge 1:1 index_symptom male smoker age time using "S:\ECHO_IHI_CPRD\Matt\ACED4_SymptomPPVWork\results_run2/inc_combined.dta"

drop if _merge == 2
assert _merge == 3
drop _merge

forval i = 1/10 {
	
	if !missing(prob_`i') {
		* if big simulation point estimate is outside the simulated CIs,
		* push the CIs out to include it
		replace lci_`i' = prob_`i' if prob_`i' < lci_`i'
		replace uci_`i' = prob_`i' if prob_`i' > uci_`i'
		
		* centre the simulated CIs around the best-estimate prob
		* look, it's a fudge, but it's the best I can do
	
		* shift CIs by 1/1000 to avoid 0s
		gen logit_width = logit(uci_`i' + 0.001)-logit(lci_`i' + 0.001)

		* otherwise, centre the confidence intervals
		* on the big simulation main estimate, on the logit scale
		replace lci_`i' = invlogit(logit(prob_`i') - (logit_width/2))
		replace uci_`i' = invlogit(logit(prob_`i') + (logit_width/2))
		
		drop logit_width
	}
}

drop prob_ci_*

keep if inlist(time, 3, 6, 12)

forval i = 1/10 {
	di "`i'"
	assert round(prob_`i',.01) <= round(uci_`i',.01)
	assert round(prob_`i',.01) >= round(lci_`i',.01) | missing(lci_`i')
	
}

drop area_prob*
drop base
drop lab_pos*

desc

* sort out labelling etc
reshape long prob_ lci_ uci_ lab, i(index_symptom male age smoker time) j(n)

gen lab2 = ""
replace lab2 = "breast" if lab == "Breast"
replace lab2 = "gynae" if lab == "Gynaecological"
replace lab2 = "lung" if lab == "Lung"
replace lab2 = "ugi" if lab == "Upper GI"
replace lab2 = "lgi" if lab == "Lower GI"
replace lab2 = "uro" if lab == "Urological"
replace lab2 = "prostate" if lab == "Prostate"
replace lab2 = "haem" if lab == "Haematological"
replace lab2 = "other" if lab == "Other cancer"
replace lab2 = "death" if lab == "Death"

* non-used outcomes, no event
drop if missing(lab)

assert !missing(lab2)
drop n lab

reshape wide prob_ lci_ uci_, i(index_symptom male age smoker time) j(lab2) string

order time index_symptom male smoker age ///
			prob_breast lci_breast uci_breast /// 
			prob_gynae lci_gynae uci_gynae /// 
			prob_lung lci_lung uci_lung /// 
			prob_ugi lci_ugi uci_ugi /// 
			prob_lgi lci_lgi uci_lgi /// 
			prob_uro lci_uro uci_uro /// 
			prob_prostate lci_prostate uci_prostate /// 
			prob_haem lci_haem uci_haem /// 
			prob_other lci_other uci_other /// 
			prob_death lci_death uci_death

sort time index_symptom male smoker age 
compress
			
* save data
save results/ci_inc_all, replace

