cd "S:/ECHO_IHI_CPRD/Matt/ACED4_SymptomPPVWork/"

collect clear
frames reset


/******************************************************************************/
/* Fit models - men */
use ../../Data/Matt/ACED4_Data/analysis_file_prepped_men_major_alternative, clear

forval i = 1/8 {
	cap frame working: clear
	cap frame drop working
	
	local name : variable label state_`i'
	di _newline "`i' of 8, `name'"
	
	frame put _* age_spl* smoker symptom_* if _trans == `i', into(working)
	 
	frame working {

		#delimit ;
			stmerlin 
			age_spl1 age_spl2 age_spl3 age_spl4 age_spl5
			smoker 
			symptom_1
			symptom_2  
			symptom_3  
			symptom_4  
			symptom_5  
			symptom_6  
			symptom_7  
			symptom_8  
			symptom_9  
			symptom_10  
			symptom_11  
			symptom_12  
			symptom_14  
			symptom_15  
			if _trans == `i' 
			, 	distribution(rp) 
				df(3)  
				tvc(  
					symptom_1
					symptom_2  
					symptom_3  
					symptom_4  
					symptom_5  
					symptom_6  
					symptom_7  
					symptom_8  
					symptom_9  
					symptom_10  
					symptom_11  
					symptom_12  
					symptom_14  
					symptom_15 
				)  
				dftvc(1)
			;
		#delimit cr
	}
	estimates store m_trans_`i'
	estimates save models/m_trans_`i', replace
	
	cap frame working: clear
	cap frame drop working
}



/******************************************************************************/
/* Fit models - women */
use ../../Data/Matt/ACED4_Data/analysis_file_prepped_women_major_alternative, clear

forval i = 1/9 {
	cap frame working: clear
	cap frame drop working

	local name : variable label state_`i'
	di _newline "`i' of 9, `name'"
		
	frame put _* age_spl* smoker symptom_* if _trans == `i', into(working)
	
	frame working {
		
		#delimit ;
		stmerlin 
			age_spl1 age_spl2 age_spl3 age_spl4 age_spl5
			smoker 
			symptom_1
			symptom_2  
			symptom_3  
			symptom_4  
			symptom_5  
			symptom_6  
			symptom_7  
			symptom_8  
			symptom_9  
			symptom_10  
			symptom_11  
			symptom_12  
			symptom_13
			symptom_14  
			symptom_15  
			if _trans == `i' 
			, 	distribution(rp) 
				df(3)  
				tvc(  
					symptom_1
					symptom_2  
					symptom_3  
					symptom_4  
					symptom_5  
					symptom_6  
					symptom_7  
					symptom_8  
					symptom_9  
					symptom_10  
					symptom_11  
					symptom_12  
					symptom_13
					symptom_14  
					symptom_15 
				)  
				dftvc(1)
			;
		#delimit cr
		
	}
	estimates store f_trans_`i'
	estimates save models/f_trans_`i', replace
	
	cap frame working: clear
	cap frame drop working
}



