cd "S:\ECHO_IHI_CPRD\Matt\ACED4_SymptomPPVWork"

set trace off
set tracedepth 2

forval symp = 1/15 {
	
	* flip so start at latest symptom
	local symp = 15-`symp'+1
	
	foreach age in 90 80 70 60 50 40 30 {
		foreach male in 0 1 {
			foreach smoke in 0 1 {
				
				cap confirm file "tempfiles/rf_male`male'_age`age'_smoker`smoke'_symptom`symp'.dta"
				if _rc {
					
					sim_outcomes_ci, male(`male') ages(`age') smoking(`smoke') symptoms(`symp')
					
				}	
			}
		}
	}
}

exit 1

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
						append using all_cis/rf_male`male'_age`age'_smoker`smoke'_symptom`symp'
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


* save data
save results/ci_inc_nothpc, replace
	
