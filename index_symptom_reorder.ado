* Just shuffles the symptoms around so they are in the right order
* for the plot

program define index_symptom_reorder
	gen     new_index =  1 if index_symptom ==  1
	replace new_index =  2 if index_symptom ==  2
	replace new_index =  3 if index_symptom == 14
	replace new_index =  4 if index_symptom ==  4
	replace new_index =  5 if index_symptom ==  5
	replace new_index =  6 if index_symptom ==  6
	replace new_index =  7 if index_symptom == 11
	replace new_index =  8 if index_symptom ==  7
	replace new_index =  9 if index_symptom == 10
	replace new_index = 10 if index_symptom ==  9
	replace new_index = 11 if index_symptom ==  8
	replace new_index = 12 if index_symptom == 12 
	replace new_index = 13 if index_symptom == 15
	replace new_index = 14 if index_symptom ==  3
	replace new_index = 15 if index_symptom == 13
	
	label define index_symptom_new	 1 "Abdominal pain" ///
									 2 "Abdominal bloating" /// 
									 3 "Rectal bleeding" /// 
									 4 "Change in bowel habit" /// 
									 5 "Dyspepsia" /// 
									 6 "Dysphagia" /// 
									 7 "Jaundice" /// 
									 8 "Dyspnoea" /// 
									 9 "Haemoptysis" /// 
									10 "Haematuria" /// 
									11 "Fatigue" /// 
									12 "Night sweats" /// 
									13 "Weight loss" /// 
									14 "Breast lump" /// 
									15 "Post-menopausal bleed" /// 
									, replace
									
	replace index_symptom = new_index
	label values index_symptom index_symptom_new
	drop new_index
end