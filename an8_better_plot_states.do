cd "S:\ECHO_IHI_CPRD\Matt\ACED4_SymptomPPVWork"

/* Separate legend */

collect clear
frames reset

cap program drop index_symptom_reorder2

/******************************************************************************/
/* Load prepared dataset and plot it - men and women */
set scheme s1color

local labopts msymb(none) mlabsize(tiny)
local areaopts lw(0)
/*
foreach male in 1 0 {
	foreach smoker in 0 1 {
		foreach age in 40 50 60 70 80 {
			
			use results_run2/inc_combined.dta ///
				if smoker == `smoker'	  /// 
				&  age == `age'   ///
				&  male == `male'   ///
				, 	clear
			
			index_symptom_reorder2
			
			summ time
			local max_time = r(max)
			
			sort male smoker age index time 
			
			if `male' == 0 {
				local sex "Women"
			}
			if `male' == 1 {
				local sex "Men"
			}
			
			if `smoker' == 0 {
				local smoking_status "non-smokers"
			}
			if `smoker' == 1 {
				local smoking_status "smokers"
			}
			
			local if smoker == `smoker' & age == `age' & male == `male'
			
			/* plot for women */
			if `male' == 0 {
				#delimit ;
				twoway 	(rarea base 		area_prob_10 time if `if', `areaopts' col(gs0          ) ) 
						(rarea area_prob_10	area_prob_9  time if `if', `areaopts' col("166 206 227") )
						(rarea area_prob_9 	area_prob_8  time if `if', `areaopts' col("31 120 180" ) )
						(rarea area_prob_8 	area_prob_7  time if `if', `areaopts' col("51 160 44"  ) )
						(rarea area_prob_7 	area_prob_6  time if `if', `areaopts' col("251 154 153") )
						(rarea area_prob_6 	area_prob_5  time if `if', `areaopts' col("227 26 28"  ) )
						(rarea area_prob_5 	area_prob_4  time if `if', `areaopts' col("253 191 111") )
						(rarea area_prob_4 	area_prob_3  time if `if', `areaopts' col("84 39 136"  ) )
						(rarea area_prob_3 	area_prob_2  time if `if', `areaopts' col("153 142 195") )
						/*(scatter lab_pos_10 time if time == `max_time' & `if', `labopts' mlabel(lab10) mlabcol(gs0          ) )
						(scatter lab_pos_9  time if time == `max_time' & `if', `labopts' mlabel(lab9 ) mlabcol("166 206 227") )
						(scatter lab_pos_8  time if time == `max_time' & `if', `labopts' mlabel(lab8 ) mlabcol("31 120 180" ) )
						(scatter lab_pos_7  time if time == `max_time' & `if', `labopts' mlabel(lab7 ) mlabcol("51 160 44"  ) )
						(scatter lab_pos_6  time if time == `max_time' & `if', `labopts' mlabel(lab6 ) mlabcol("251 154 153") )
						(scatter lab_pos_5  time if time == `max_time' & `if', `labopts' mlabel(lab5 ) mlabcol("227 26 28"  ) )
						(scatter lab_pos_4  time if time == `max_time' & `if', `labopts' mlabel(lab4 ) mlabcol("253 191 111") )
						(scatter lab_pos_3  time if time == `max_time' & `if', `labopts' mlabel(lab3 ) mlabcol("84 39 136"  ) )
						(scatter lab_pos_2  time if time == `max_time' & `if', `labopts' mlabel(lab2 ) mlabcol("153 142 195") )*/
						,	by(index_symptom
								,	legend(on pos(6) )
									yrescale
									note("")
									title("`sex' aged `age', `smoking_status'", pos(11) size(medsmall))
									cols(4)
							)
							legend(
								order(
									9 "Breast"
									8 "Gynaecological"
									7 "Lung"
									6 "Upper GI"
									5 "Lower GI"
									4 "Urological"
									3 "Haematological"
									2 "Other cancer"
									1 "Death"
								)
								region(lstyle(none))
								size(small)
								symxsize(*.5)
								cols(3)
							)
							ylabel(0(0.02)0.1, angle(h) grid format(%03.2f) labsize(small) tl(0) )
							ysc(noline r(0 0.1))
							ytick(0, grid glcolor(gs0) tl(0) )
							subtitle(, fcolor(gs0) color(gs16) pos(11) lstyle(none) size(vsmall))
							xsc(r(0 12))
							xlabel(0(3)12)
							xtitle("Months after index symptom")
							plotregion(margin(b=0 l=0) lstyle(none) ) ///
							title("`symp_label'", size(small) pos(11)) ///
							name(plot_`index', replace)
							xsize(4)
							ysize(6)
					;
				#delimit cr
			}
			
			/* plot for men */
			if `male' == 1 {			
				#delimit ;
				twoway 	(rarea base 		area_prob_9  time if `if', `areaopts' col(gs0          ) ) 
						(rarea area_prob_9 	area_prob_8  time if `if', `areaopts' col("166 206 227") )
						(rarea area_prob_8 	area_prob_7  time if `if', `areaopts' col("31 120 180" ) )
						(rarea area_prob_7 	area_prob_6  time if `if', `areaopts' col("178 223 138") )
						(rarea area_prob_6 	area_prob_5  time if `if', `areaopts' col("51 160 44"  ) )
						(rarea area_prob_5 	area_prob_4  time if `if', `areaopts' col("251 154 153") )
						(rarea area_prob_4 	area_prob_3  time if `if', `areaopts' col("227 26 28"  ) )
						(rarea area_prob_3 	area_prob_2  time if `if', `areaopts' col("253 191 111") )
						/*(scatter lab_pos_9  time if time == `max_time' & `if', `labopts' mlabel(lab9 ) mlabcol(gs0          ) )
						(scatter lab_pos_8  time if time == `max_time' & `if', `labopts' mlabel(lab8 ) mlabcol("166 206 227") )
						(scatter lab_pos_7  time if time == `max_time' & `if', `labopts' mlabel(lab7 ) mlabcol("31 120 180" ) )
						(scatter lab_pos_6  time if time == `max_time' & `if', `labopts' mlabel(lab6 ) mlabcol("178 223 138") )
						(scatter lab_pos_5  time if time == `max_time' & `if', `labopts' mlabel(lab5 ) mlabcol("51 160 44"  ) )
						(scatter lab_pos_4  time if time == `max_time' & `if', `labopts' mlabel(lab4 ) mlabcol("251 154 153") )
						(scatter lab_pos_3  time if time == `max_time' & `if', `labopts' mlabel(lab3 ) mlabcol("227 26 28"  ) )
						(scatter lab_pos_2  time if time == `max_time' & `if', `labopts' mlabel(lab2 ) mlabcol("253 191 111") )*/
						,	by(index_symptom
								,	
									legend(on pos(6))
									yrescale
									note("")
									title("`sex' aged `age', `smoking_status'", pos(11) size(medsmall))
									cols(4)
							)
							legend(
								order(
									8 "Lung"
									7 "Upper GI"
									6 "Lower GI"
									5 "Urological"
									4 "Prostate"
									3 "Haematological"
									2 "Other cancer"
									1 "Death"
								)
								region(lstyle(none))
								size(small)
								symxsize(*.5)
								cols(3)
								holes(8)
							)
							ylabel(0(0.02)0.1, angle(h) grid format(%03.2f) labsize(small) tl(0) )
							ysc(noline r(0 0.1))
							ytick(0, grid glcolor(gs0) tl(0) )
							subtitle(, fcolor(gs0) color(gs16) pos(11) lstyle(none) size(vsmall))
							xsc(r(0 12))
							xlabel(0(3)12)
							xtitle("Months after index symptom")
							plotregion(margin(b=0 l=0) lstyle(none) ) ///
							title("`symp_label'", size(small) pos(11)) ///
							name(plot_`index', replace)
							xsize(4)
							ysize(6)
					;
				#delimit cr
			}
			
			local todaydate: display %tdCCYY-NN-DD =daily("`c(current_date)'","DMY")
			graph export results/inc_male`male'_age`age'_smoke`smoker'_`todaydate'.png, width(1000) replace
				
		}
	}
}
*/

/******************************************************************************/
/* Risk at 3, 6, 12m - men and women */

set scheme s1color

local max_age = 85
local labopts msymb(none) mlabsize(tiny)

local areaopts lw(0)

foreach male in 0 1 {
	foreach smoker in 0 1 {
		foreach plot_time in 3 6 12 {
			
			use results_run2/inc_combined.dta ///
				if smoker == `smoker'	  /// 
				&  time == `plot_time'   ///
				&  male == `male'   ///
				& age <= 85 ///
				, 	clear
			
			index_symptom_reorder2
			label define index_symptom_new 0 "Reference group", modify
			
			sort male smoker age index_symptom time

			if `male' == 0 {
				local sex "Women"
				// exclude young women with PMB from plot
				drop if index_symptom == 15 & age < 45
				
				* plot death as a separate line rather than area
				forval i = 1/10 {
					replace area_prob_`i' = area_prob_`i' - prob_10
					replace lab_pos_`i'   = lab_pos_`i' - prob_10
				}
			}
			if `male' == 1 {
				local sex "Men"
				
				* plot death as a separate line rather than area
				forval i = 1/9 {
					replace area_prob_`i' = area_prob_`i' - prob_9
					replace lab_pos_`i'   = lab_pos_`i' - prob_9
				}
			}
			
			if `smoker' == 0 {
				local smoking_status "non-smokers"
			}
			if `smoker' == 1 {
				local smoking_status "smokers"
			}
			
			local if smoker == `smoker' & time == `plot_time' & male == `male'
			
			
			
			* add in PMB plot for men, that is just blank
			/*
			expand 2 if index_symptom == 14 & male, gen(expanded)
			replace index_symptom = 15 if expanded
			foreach thing of varlist area_prob_* {
				replace `thing' = . if expanded
			}
			drop expanded
			*/
			
			/* plot for women */
			if `male' == 0 {
				#delimit ;
				twoway 	(rarea base			area_prob_9  age if `if', `areaopts' col("166 206 227") )
						(rarea area_prob_9 	area_prob_8  age if `if', `areaopts' col("31 120 180" ) )
						(rarea area_prob_8 	area_prob_7  age if `if', `areaopts' col("51 160 44"  ) )
						(rarea area_prob_7 	area_prob_6  age if `if', `areaopts' col("251 154 153") )
						(rarea area_prob_6 	area_prob_5  age if `if', `areaopts' col("227 26 28"  ) )
						(rarea area_prob_5 	area_prob_4  age if `if', `areaopts' col("253 191 111") )
						(rarea area_prob_4 	area_prob_3  age if `if', `areaopts' col("84 39 136"  ) )
						(rarea area_prob_3 	area_prob_2  age if `if', `areaopts' col("153 142 195") )
						(line prob_10					 age if `if',            col(gs0          ) ) 
						,	by(index_symptom
								,	legend(on pos(6))
									yrescale
									note("")
									title("`sex', `plot_time' months after symptom presentation, `smoking_status'", pos(11) size(medsmall))
									cols(4)
							)
							legend(
								order(
									9 "Death"
									8 "Breast"
									7 "Gynaecological"
									6 "Lung"
									5 "Upper GI"
									4 "Lower GI"
									3 "Urological"
									2 "Haematological"
									1 "Other cancer"
								)
								region(lstyle(none))
								size(small)
								symxsize(*.5)
								cols(3)
							)
							ylabel(0(0.05)0.25, angle(h) grid format(%03.2f) labsize(small) tl(0) )
							ysc(noline r(0 0.25))
							ytick(0, grid glcolor(gs0) tl(0) )
							subtitle(, fcolor(gs0) color(gs16) pos(11) lstyle(none) size(vsmall))
							xsc(r(30 80))
							xlabel(40(10)80)
							xtitle("Age (years)")
							plotregion(margin(b=0 l=0) lstyle(none) ) ///
							title("`symp_label'", size(small) pos(11)) ///
							name(plot_`index', replace)
							xsize(4)
							ysize(6)
					;
				#delimit cr
			}
	
			/* plot for men */
			if `male' == 1 {	
				#delimit ;
				twoway 	(rarea base     	area_prob_8  age if `if', `areaopts' col("166 206 227") )
						(rarea area_prob_8 	area_prob_7  age if `if', `areaopts' col("31 120 180" ) )
						(rarea area_prob_7 	area_prob_6  age if `if', `areaopts' col("178 223 138") )
						(rarea area_prob_6 	area_prob_5  age if `if', `areaopts' col("51 160 44"  ) )
						(rarea area_prob_5 	area_prob_4  age if `if', `areaopts' col("251 154 153") )
						(rarea area_prob_4 	area_prob_3  age if `if', `areaopts' col("227 26 28"  ) )
						(rarea area_prob_3 	area_prob_2  age if `if', `areaopts' col("253 191 111") )
						(line  prob_9					 age if `if',            col(gs0          ) ) 
						,	by(index_symptom
								,	
									legend(on pos(6))
									yrescale
									note("")
									title("`sex', `plot_time' months after symptom presentation, `smoking_status'", pos(11) size(medsmall))
									cols(4)
							)
							legend(
								order(
									8 "Death"
									7 "Lung"
									6 "Upper GI"
									5 "Lower GI"
									4 "Urological"
									3 "Prostate"
									2 "Haematological"
									1 "Other cancer"
								)
								region(lstyle(none))
								size(small)
								symxsize(*.5)
								cols(3)
								holes(8)
							)
							ylabel(0(0.05)0.25, angle(h) grid format(%03.2f) labsize(small) tl(0) )
							ysc(noline r(0 0.25))
							ytick(0, grid glcolor(gs0) tl(0) )
							subtitle(, fcolor(gs0) color(gs16) pos(11) lstyle(none) size(vsmall))
							xsc(r(30 80))
							xlabel(40(10)80)
							xtitle("Age (years)")
							plotregion(margin(b=0 l=0) lstyle(none) ) ///
							title("`symp_label'", size(small) pos(11)) ///
							name(plot_`index', replace)
							xsize(4)
							ysize(6)
					;
				#delimit cr
			}
				
			local todaydate: display %tdCCYY-NN-DD =daily("`c(current_date)'","DMY")
			graph export results/inc_month`plot_time'_male`male'_smoke`smoker'_`todaydate'.png, width(1000) replace
		}			
	}
}



