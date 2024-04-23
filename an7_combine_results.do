cd "S:\ECHO_IHI_CPRD\Matt\ACED4_SymptomPPVWork"

clear


foreach male in 0 1 {
	local first = 1
	
	if  `male' {
		local outcomes = 8
	}
	if !`male' {
		local outcomes = 9
	}
	
	forval symp = 0/15 {
		foreach smoke in 0 1 {
			foreach age in 30 35 40 45 50 55 60 65 70 75 80 85 90 95 {
				
				if `first' {
					use results_run2/run2_male`male'_age`age'_smoker`smoke'_symptom`symp'.dta, clear
					local first = 0
				}
				if !`first' {
					cap append using results_run2/run2_male`male'_age`age'_smoker`smoke'_symptom`symp'
				}
			}
		}
	}


	* data processing for plotting
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

	* extra vars for plot
	local outcome_mod1 = `outcomes'+1
	local outcome_mod2 = `outcomes'-1

	gen area_prob_`outcome_mod1' = prob_`outcome_mod1'
	forval i = 1/`outcome_mod2' {
		local j = `outcome_mod1'-`i'
		local j_old = `outcome_mod1'-`i'+1
		gen area_prob_`j' = prob_`j' + area_prob_`j_old'
	}

	if  `male' {
		
		label var area_prob_9  "Death"
		label var area_prob_8  "Other cancer"
		label var area_prob_7  "Haematological"
		label var area_prob_6  "Prostate"
		label var area_prob_5  "Urological"
		label var area_prob_4  "Lower GI"
		label var area_prob_3  "Upper GI"
		label var area_prob_2  "Lung"

	}
	if !`male' {
			
		label var area_prob_10 "Death"
		label var area_prob_9  "Other cancer"
		label var area_prob_8  "Haematological"
		label var area_prob_7  "Urological"
		label var area_prob_6  "Lower GI"
		label var area_prob_5  "Upper GI"
		label var area_prob_4  "Lung"
		label var area_prob_3  "Gynaecological"
		label var area_prob_2  "Breast"

	}

	* label positions
	gen base = 0
	gen lab_pos_`outcome_mod1' = (area_prob_`outcome_mod1'-base)/2
	forval i = 1/`outcome_mod2' {
		local j = `outcome_mod1'-`i'
		local j_old = `outcome_mod1'-`i'+1
		gen lab_pos_`j' = area_prob_`j_old' + (area_prob_`j'-area_prob_`j_old')/2
	}

	* labels
	forval i = 2/`outcome_mod1' {
		local label_string : var label area_prob_`i'
		gen lab`i' = "`label_string'"
	}
			
	* sort 
	sort male index_symptom age smoker time

	compress
	save results_run2/inc_combined_male`male'.dta, replace
}

use results_run2/inc_combined_male0.dta, clear
append using results_run2/inc_combined_male1.dta
save results_run2/inc_combined.dta, replace
