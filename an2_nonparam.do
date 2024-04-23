cd "S:\ECHO_IHI_CPRD\Matt\ACED4_SymptomPPVWork"

collect clear
frames reset

/******************************************************************************/
/* Non-parametric analysis - men */

foreach smoke in 0 1 2 {
	
	use ../../Data/Matt/ACED4_Data/analysis_file_prepped_men_major_alternative, clear
	if `smoke' != 2 {
	    keep if smoker == `smoke'
	}
	
	forval symp = 0/15 {
		if `symp' == 13 {
			// do nothing
			// pm bleed in men
		}
		else {			
			msaj if index_symptom == `symp', cr exit(12)
			
			frame put _t P_AJ_*, into(paj_`symp')
			frame paj_`symp' {
				cap keep if !missing(P_AJ_1)
				rename (_*) (*)
				rename (P_AJ*) (p_aj*)
				
				gen index_symptom = `symp'
				gen male = 1
				order index_symptom male t p_aj*
			}
			drop P_AJ_*
		}
	}

	* get into a single frame
	forval i = 0/15 {
		tempfile temp_paj_`i'
		
		if `i' != 13 {
			frame paj_`i' {
				keep index_symptom male t p_aj*
				duplicates drop
				save `temp_paj_`i''
			}
			
		}
	}

	cap frame plot_frame_np: clear
	cap frame drop plot_frame_np
	frame create plot_frame_np
	frame plot_frame_np {
		use `temp_paj_0', clear
		forval i = 1/15 {
			cap append using `temp_paj_`i''
		}
	}
	
	forval i = 0/15 {
	    cap frame paj_`i': clear
		cap frame drop paj_`i'
	}
	
	frame plot_frame_np: desc
	frame plot_frame_np {
		cap drop time_row time_string
		cap rename (pr_*) (prob_*)
		
			
		#delimit ;
		label define symptom 	 0 "Reference cohort"
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
								16 "Abdominal lump"
								17 "Constipation"
								18 "Cough"
								19 "Diarrhoea"
								20 "Pelvic pain"
								21 "Nausea / vomiting"
								, replace
								;
		#delimit cr
		label values index_symptom symptom
		
		* male
		label define male 0 "Women" 1 "Men", replace
		label values male male
		
		rename (p_aj_*) (prob_*)
		
		* extra vars for plot
		gen area_prob_9 = prob_9
		forval i = 1/8 {
			local j = 9-`i'
			local j_old = 9-`i'+1
			gen area_prob_`j' = prob_`j' + area_prob_`j_old'
		}

		label var area_prob_9 "Death"
		/*label var area_prob_10 "Stroke"
		label var area_prob_9  "MI"*/
		label var area_prob_8  "Other cancer"
		label var area_prob_7  "Haematological"
		label var area_prob_6  "Prostate"
		label var area_prob_5  "Urological"
		label var area_prob_4  "Lower GI"
		label var area_prob_3  "Upper GI"
		label var area_prob_2  "Lung"
		
		gen base = 0
		gen lab_pos_9 = (area_prob_9-base)/2
		forval i = 1/7 {
			local j = 9-`i'
			local j_old = 9-`i'+1
			gen lab_pos_`j' = area_prob_`j_old' + (area_prob_`j'-area_prob_`j_old')/2
		}
		
		forval i = 2/9 {
			local label_string : var label area_prob_`i'
			gen lab`i' = "`label_string'"
		}
		
		* sort 
		rename t time
		sort male index_symptom time
		by male index_symptom: gen byte labplot = _n == _N
	}

	* save the results
	frame plot_frame_np : desc
	frame plot_frame_np : list in 1
	
	if `smoke' != 2 {
		frame plot_frame_np : save results/nonparam_men_smoke`smoke', replace
	}
	if `smoke' == 2 {
	    frame plot_frame_np : save results/nonparam_men, replace
	}
	
}



/******************************************************************************/
/* Non-parametric analysis - women */
foreach smoke in 0 1 2 {
	
	use ../../Data/Matt/ACED4_Data/analysis_file_prepped_women_major_alternative, clear
	if `smoke' != 2 {
	    keep if smoker == `smoke'
	}

	forval symp = 0/15 {
		msaj if index_symptom == `symp', cr exit(12)
		
		frame put _t P_AJ_*, into(paj_`symp')
		frame paj_`symp' {
			cap keep if !missing(P_AJ_1)
			rename (_*) (*)
			rename (P_AJ*) (p_aj*)
			
			gen index_symptom = `symp'
			gen male = 0
			order index_symptom male t p_aj*
		}
		drop P_AJ_*
	}

	* get into a single frame
	forval i = 0/15 {
		tempfile temp_paj_`i'
		
		frame paj_`i' {
			keep index_symptom male t p_aj*
			duplicates drop
			save `temp_paj_`i''
		}
	}

	cap frame plot_frame_np: clear
	cap frame drop plot_frame_np
	frame create plot_frame_np
	frame plot_frame_np {
		use `temp_paj_0', clear
		forval i = 2/15 {
			cap append using `temp_paj_`i''
		}
	}
	
		
	forval i = 0/15 {
	    cap frame paj_`i': clear
		cap frame drop paj_`i'
	}

	frame plot_frame_np: desc
	frame plot_frame_np {
		cap drop time_row time_string
		cap rename (pr_*) (prob_*)
		
			
		#delimit ;
		label define symptom 	 0 "Reference cohort"
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
								, replace
								;
		#delimit cr
		label values index_symptom symptom
		
		* male
		label define male 0 "Women" 1 "Men", replace
		label values male male
		
		rename (p_aj_*) (prob_*)
		
		* extra vars for plot
		gen area_prob_10 = prob_10
		forval i = 1/8 {
			local j = 10-`i'
			local j_old = 10-`i'+1
			gen area_prob_`j' = prob_`j' + area_prob_`j_old'
		}


		label var area_prob_10 "Death"
		label var area_prob_9  "Other cancer"
		label var area_prob_8  "Haematological"
		label var area_prob_7  "Urological"
		label var area_prob_6  "Lower GI"
		label var area_prob_5  "Upper GI"
		label var area_prob_4  "Lung"
		label var area_prob_3  "Gynaecological"
		label var area_prob_2  "Breast"
		
		gen base = 0
		gen lab_pos_10 = (area_prob_10-base)/2
		forval i = 1/8 {
			local j = 10-`i'
			local j_old = 10-`i'+1
			gen lab_pos_`j' = area_prob_`j_old' + (area_prob_`j'-area_prob_`j_old')/2
		}

		forval i = 2/10 {
			local label_string : var label area_prob_`i'
			gen lab`i' = "`label_string'"
		}
		
		* sort 
		rename t time
		sort male index_symptom time
		by male index_symptom : gen byte labplot = _n == _N
	}

	* save the results
	frame plot_frame_np : desc
	frame plot_frame_np : list in 1
	
	if `smoke' != 2 {
		frame plot_frame_np : save results/nonparam_women_smoke`smoke', replace
	}
	if `smoke' == 2 {
	    frame plot_frame_np : save results/nonparam_women, replace
	}

}
