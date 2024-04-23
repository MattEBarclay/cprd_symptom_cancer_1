/* Edited 2023-01-24 to save age/sex/smoking specific results as it goes */

program define sim_outcomes_ci
	syntax, male(int) ages(numlist) smoking(numlist) symptoms(numlist)

	* empty memory
	frames reset


	/******************************************************************************/
	/* Load prepared dataset */
	if !`male' {
		use ../../Data/Matt/ACED4_Data/analysis_file_prepped_women_major_alternative, clear
	}
	if  `male' {
		use  ../../Data/Matt/ACED4_Data/analysis_file_prepped_men_major_alternative, clear
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

			foreach symp in `symptoms' {
				
				forval i = 1/15 {
					local s`i' = (`symp' == `i')
				}
				
				if `symp' == 13 & `male' {
					// do nothing, not considered
					// post-menopausal bleed in men?
				}
				if `symp' != 13 | !`male' {
					
					nois display as text _col(5) "Male `male', age `predict_age', smoker `predict_smoking', symptom `symp'"
					
					#delimit ;
					predictms 
						, 	cr
							probability 
							timevar(timevar)
							simulate
							latent ci m(30)
							n(1000)
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
					
					/* Put symptom-specific results into new frame to work with */
					cap frame results_frame_`symp': clear
					cap frame drop results_frame_`symp'

					frame put timevar _prob*, into(results_frame_`symp')
					frame results_frame_`symp' {
						cap keep if !missing(timevar)
						rename (_*) (*)
						rename (prob_*_lci) (lci_*)
						rename (prob_*_uci) (uci_*)
						rename (prob_at1_1_*) (prob_*)
						rename (lci_at1_1_*) (lci_*)
						rename (uci_at1_1_*) (uci_*)
						rename timevar time
						
						gen index_symptom = `symp'
						gen age = `predict_age'
						gen smoker = `predict_smoking'
						gen male = `male'
						
						order index_symptom male smoker age time prob_* lci_* uci_*

						save tempfiles/rf_male`male'_age`predict_age'_smoker`predict_smoking'_symptom`symp'
					}
				}
			}
		}
	}

end
	