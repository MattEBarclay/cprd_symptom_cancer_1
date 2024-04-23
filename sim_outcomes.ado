/* Edited 2023-01-24 to save age/sex/smoking specific results as it goes */

program define sim_outcomes
	syntax, male(int) ages(numlist) smoking(numlist) 
	
	* look at all symptoms
	local symptoms 1/15

	* empty memory
	frames reset


	/******************************************************************************/
	/* Load prepared dataset */
	if !`male' {
		use ../../Data/Matt/ACED4_Data/analysis_file_prepped_women, clear
	}
	if  `male' {
		use ../../Data/Matt/ACED4_Data/analysis_file_prepped_men, clear
	}
		

	/******************************************************************************/
	/* Load fit models into memory */
	
	if !`male' {
		
		local outcomes = 9
		forval i = 1/`outcomes' {
			estimates use models/f_trans_`i'
			estimates store f_trans_`i'
		}
		
		#delimit ;
		local model_list 
				f_trans_1  
				f_trans_2  
				f_trans_3  
				f_trans_4  
				f_trans_5  
				f_trans_6  
				f_trans_7  
				f_trans_8  
				f_trans_9  
			;
		#delimit cr
		
	}	
	if  `male' {
				
		local outcomes = 8
		forval i = 1/`outcomes' {
			estimates use models/m_trans_`i'
			estimates store m_trans_`i'
		}
		
		#delimit ;
		local model_list 
				m_trans_1  
				m_trans_2  
				m_trans_3  
				m_trans_4  
				m_trans_5  
				m_trans_6  
				m_trans_7  
				m_trans_8  
			;
		#delimit cr
		
	}


	/******************************************************************************/
	/* Simulate probabilities of each state */
	qui gen timevar = .
	qui replace timevar = (_n-1)/10 if _n <= 121

	foreach predict_age in `ages' {
		
		qui forval i = 1/5 {
			summ age_spl`i' if age == `predict_age', meanonly
			local age`i' = r(mean)
		}

		foreach predict_smoking in `smoking' {

			forval symp = `symptoms' {
				
				forval i = 1/15 {
					local s`i' = (`symp' == `i')
				}
				
				if `symp' == 13 & `male' {
					// do nothing, not considered
					// post-menopausal bleed in men?
				}
				if `symp' != 13 | !`male' {
					
					nois display as text _col(5) "Male `male', age `predict_age', smoker `predict_smoking', symptom `symp'"
					
					if  `male' {
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
									symptom_14 `s14'
									symptom_15 `s15'
								)  
								models( 
									`model_list'
								)
							;
						#delimit cr
					}
					if !`male' {
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
									`model_list'
								)
							;
						#delimit cr
					}
					
					/* Put symptom-specific results into new frame to work with */
					cap frame results_frame_`symp': clear
					cap frame drop results_frame_`symp'

					frame put timevar _prob*, into(results_frame_`symp')
					frame results_frame_`symp' {
						cap keep if !missing(timevar)
						rename (_*) (*)
						rename (prob_at1_1_*) (prob_*)
						rename timevar time
						
						gen index_symptom = `symp'
						gen age = `predict_age'
						gen smoker = `predict_smoking'
						gen male = `male'
						
						order index_symptom male smoker age time prob_*
						
					}
				}
			}
			
			/* Combine symptom-specific results frames */
			cap frame results_frame: clear
			cap frame drop results_frame
			
			local loop_counter = 0
			
			frame create results_frame
			frame results_frame {
				qui forval symp = `symptoms' {
					if `symp' == 13 & `male' {
						// do nothing
						// pm bleed in meb
					}
					else {
						tempfile tempdata
						
						if `loop_counter' == 0 {
							frame results_frame_`symp': save `tempdata', replace
							use `tempdata'
							local loop_counter = 1
						}
						else if `loop_counter' == 1 {
							frame results_frame_`symp': save `tempdata', replace
							append using `tempdata'
						}
					}
					
					* delete frames once combined
					cap frame results_frame_`symp': clear
					cap frame drop results_frame_`symp'
					
				}
			}		
			
			/* Neaten and format results data */
			frame results_frame {
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
			}
			
			* save data
			frame results_frame: nois save results/inc_male`male'_smoke`predict_smoking'_age`predict_age'.dta, replace
				
			* clean up
			cap frame results_frame: clear
			cap frame drop results_frame
		
		}
	}

end
	