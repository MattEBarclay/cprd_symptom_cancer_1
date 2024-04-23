cd "S:\ECHO_IHI_CPRD\Matt\ACED4_SymptomPPVWork"

collect clear
frames reset


/******************************************************************************/
/* Load prepared dataset */
use ../../Data/Matt/ACED4_Data/analysis_file_prepped_women, clear


/******************************************************************************/
/* Load fit models into memory */
forval i = 1/11 {
	estimates use models/f_trans_`i'
	estimates store f_trans_`i'
}


/******************************************************************************/
/* Simulate probabilities of each state */
gen timevar = .
replace timevar = (_n-1)/10 if _n <= 121
summ timevar

foreach predict_age in 50 60 70 {
	
	qui forval i = 1/5 {
		summ age_spl`i' if age == `predict_age', meanonly
		local age`i' = r(mean)
	}

	foreach predict_smoking in 0 1 {

		forval symp = 1/15 {
			
			forval i = 1/15 {
				local s`i' = (`symp' == `i')
			}
			
			nois display "Age `predict_age', smoker `predict_smoking', symptom `symp'"
			
			#delimit ;
			predictms 
				, 	cr
					probability 
					timevar(timevar)
					simulate
					latent
					n(100000)
					at1(
						age_spl1 `age1' 
						age_spl2 `age2' 
						age_spl3 `age3'
						age_spl4 `age4' 
						age_spl5 `age5'
						smoker `predict_smoking'
						symptom_1  `s1'
						symptom_2  `s2'
						symptom_3  `s3'
						symptom_4  `s4'
						symptom_5  `s5'
						symptom_6  `s6'
						symptom_7  `s7'
						symptom_8  `s8'
						symptom_9  `s9'
						symptom_10 `s10'
						symptom_11 `s11'
						symptom_12 `s12'
						symptom_13 `s13'
						symptom_14 `s14'
						symptom_15 `s15'
					)  
					models( 
						f_trans_1  
						f_trans_2  
						f_trans_3  
						f_trans_4  
						f_trans_5  
						f_trans_6  
						f_trans_7  
						f_trans_8  
						f_trans_9  
						f_trans_10  
						f_trans_11 
					)
				;
			#delimit cr

			cap frame plot_frame`symp': clear
			cap frame drop plot_frame`symp'

			frame put timevar _prob*, into(plot_frame`symp'_`predict_age'_`predict_smoking')
			frame plot_frame`symp'_`predict_age'_`predict_smoking' {
				cap keep if !missing(timevar)
				rename (_*) (*)
				rename (prob_at1_1_*) (prob_*)
				rename timevar time
				
				gen index_symptom = `symp'
				gen age = `predict_age'
				gen smoker = `predict_smoking'
				gen male = 0
				
				order index_symptom male smoker age time prob_*
				
			}
		}
	}
}

* get into a single frame
cap frame plot_frame: clear
cap frame drop plot_frame
frame create plot_frame
frame plot_frame {
	foreach predict_age in 50 60 70 {
	    foreach predict_smoking in 0 1 {
		    forval symp = 1/15 {

				tempfile tempdata
				
				if `predict_age' == 50 & `predict_smoking' == 0 & `symp' == 1 {
					frame plot_frame`symp'_`predict_age'_`predict_smoking': save `tempdata', replace
					use `tempdata'
				}
				else {
					frame plot_frame`symp'_`predict_age'_`predict_smoking': save `tempdata', replace
					append using `tempdata'
				}

			}
		}
	}
}

* clean up data frames
foreach predict_age in 50 60 70 {
	foreach predict_smoking in 0 1 {
		forval symp = 1/15 {
			cap frame plot_frame`symp'_`predict_age'_`predict_smoking': clear
			cap frame drop plot_frame`symp'_`predict_age'_`predict_smoking'
		}
	}
}

* data processing for plotting
frame plot_frame {
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
	gen area_prob_12 = prob_12
	forval i = 1/10 {
	    local j = 12-`i'
		local j_old = 12-`i'+1
		gen area_prob_`j' = prob_`j' + area_prob_`j_old'
	}


	label var area_prob_12 "Death"
	label var area_prob_11 "Stroke"
	label var area_prob_10 "MI"
	label var area_prob_9  "Other cancer"
	label var area_prob_8  "Haematological"
	label var area_prob_7  "Urological"
	label var area_prob_6  "Lower GI"
	label var area_prob_5  "Upper GI"
	label var area_prob_4  "Lung"
	label var area_prob_3  "Gynaecological"
	label var area_prob_2  "Breast"
	
	* label positions
	gen base = 0
	gen lab_pos_12 = (area_prob_12-base)/2
	forval i = 1/10 {
	    local j = 12-`i'
		local j_old = 12-`i'+1
		gen lab_pos_`j' = area_prob_`j_old' + (area_prob_`j'-area_prob_`j_old')/2
	}

	* labels
	forval i = 2/12 {
	    local label_string : var label area_prob_`i'
		gen lab`i' = "`label_string'"
	}

	* sort 
	sort male index_symptom age smoker time
}

frame plot_frame: save results/women_incidence_estimates.dta, replace
