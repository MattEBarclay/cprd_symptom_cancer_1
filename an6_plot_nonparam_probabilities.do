cd "S:\ECHO_IHI_CPRD\Matt\ACED4_SymptomPPVWork"

collect clear
frames reset

set scheme s1color

local max_age = 85
local labopts msymb(none) mlabsize(tiny)

local areaopts lw(0)


/******************************************************************************/
/* Load Aalen-Johansen estimates and plot */
foreach male in 0 1 {
	foreach smoker in 0 1 {
		
		if `male' == 1 {
			use results/nonparam_men_smoke`smoker'.dta, clear
		}
		else if `male' == 0 {
			use results/nonparam_women_smoke`smoker'.dta, clear
		}
		
		index_symptom_reorder2
		label define index_symptom_new 0 "Reference group", modify
		
		gen smoker = `smoker'
		sort male smoker index_symptom time

		if `male' == 0 {
			local sex "Women"
			
			* plot death as a separate line rather than area
			forval i = 1/10 {
				replace area_prob_`i' = area_prob_`i' - prob_10
			}
		}
		if `male' == 1 {
			local sex "Men"
			
			* plot death as a separate line rather than area
			forval i = 1/9 {
				replace area_prob_`i' = area_prob_`i' - prob_9
			}
		}
		
		if `smoker' == 0 {
			local smoking_status "non-smokers"
		}
		if `smoker' == 1 {
			local smoking_status "smokers"
		}
		
		local if smoker == `smoker' & male == `male'
					
		/* plot for women */
		if `male' == 0 {
			#delimit ;
			twoway 	(rarea base			area_prob_9  time if `if', `areaopts' col("166 206 227") )
					(rarea area_prob_9 	area_prob_8  time if `if', `areaopts' col("31 120 180" ) )
					(rarea area_prob_8 	area_prob_7  time if `if', `areaopts' col("51 160 44"  ) )
					(rarea area_prob_7 	area_prob_6  time if `if', `areaopts' col("251 154 153") )
					(rarea area_prob_6 	area_prob_5  time if `if', `areaopts' col("227 26 28"  ) )
					(rarea area_prob_5 	area_prob_4  time if `if', `areaopts' col("253 191 111") )
					(rarea area_prob_4 	area_prob_3  time if `if', `areaopts' col("84 39 136"  ) )
					(rarea area_prob_3 	area_prob_2  time if `if', `areaopts' col("153 142 195") )
					(line prob_10					 time if `if',            col(gs0          ) ) 
					,	by(index_symptom
							,	legend(on pos(6))
								yrescale
								note("")
								title("`sex', `smoking_status'", pos(11) size(medsmall))
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
						ylabel(0(0.03)0.15, angle(h) grid format(%03.2f) labsize(small) tl(0) )
						ysc(noline r(0 0.25))
						ytick(0, grid glcolor(gs0) tl(0) )
						subtitle(, fcolor(gs0) color(gs16) pos(11) lstyle(none) size(vsmall))
						xsc(r(0 12))
						xlabel(0(3)12)
						xtitle("Months after index")
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
			twoway 	(rarea base     	area_prob_8  time if `if', `areaopts' col("166 206 227") )
					(rarea area_prob_8 	area_prob_7  time if `if', `areaopts' col("31 120 180" ) )
					(rarea area_prob_7 	area_prob_6  time if `if', `areaopts' col("178 223 138") )
					(rarea area_prob_6 	area_prob_5  time if `if', `areaopts' col("51 160 44"  ) )
					(rarea area_prob_5 	area_prob_4  time if `if', `areaopts' col("251 154 153") )
					(rarea area_prob_4 	area_prob_3  time if `if', `areaopts' col("227 26 28"  ) )
					(rarea area_prob_3 	area_prob_2  time if `if', `areaopts' col("253 191 111") )
					(line  prob_9					 time if `if',            col(gs0          ) ) 
					,	by(index_symptom
							,	legend(on pos(6))
								yrescale
								note("")
								title("`sex', `smoking_status'", pos(11) size(medsmall))
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
						ylabel(0(0.03)0.15, angle(h) grid format(%03.2f) labsize(small) tl(0) )
						ysc(noline r(0 0.25))
						ytick(0, grid glcolor(gs0) tl(0) )
						subtitle(, fcolor(gs0) color(gs16) pos(11) lstyle(none) size(vsmall))
						xsc(r(0 12))
						xlabel(0(3)12)
						xtitle("Months after index")
						plotregion(margin(b=0 l=0) lstyle(none) ) ///
						title("`symp_label'", size(small) pos(11)) ///
						name(plot_`index', replace)
						xsize(4)
						ysize(6)
				;
			#delimit cr
		}
		
		local todaydate: display %tdCCYY-NN-DD =daily("`c(current_date)'","DMY")
		graph export results/nonparam_updated_male`male'_smoke`smoker'_`todaydate'.png, width(1000) replace
	}			
}


