cd "S:\ECHO_IHI_CPRD\Matt\ACED4_SymptomPPVWork"

collect clear
frames reset

/******************************************************************************/
/* Something really simply to explore multiple symptoms */
use ../../Data/Matt/ACED4_Data/analysis_file_major_alternative, clear

* exclude control group
drop if index_symptom == 0

* multi symptomatic
gen byte multi = !missing(symptom2)
label var multi "Co-presenting symptoms?"
label define multi	0	"No other recorded symptom" ///
					1	"One or more other symptom at index" ///
					, replace
label values multi multi

gen diff = date_cancer - index_symptom_date
summ diff

* note: pre-symptom cancers removed anyway
gen cancer = diff <= 365 & diff >= 0
tab cancer

table (index_symptom multi) (), statistic(freq) statistic(sum cancer) command(r(proportion) r(lb) r(ub): ci proportions cancer, wilson) 

collect
collect preview

index_symptom_reorder2

collect export multi_symptom_table.docx, replace

cd "S:\ECHO_IHI_CPRD\Matt\ACED4_SymptomPPVWork"

collect clear
frames reset

/******************************************************************************/
/* Something really simply to explore multiple symptoms */
use ../../Data/Matt/ACED4_Data/analysis_file_major_alternative, clear

* exclude control group
drop if index_symptom == 0

* multi symptomatic
gen byte multi = !missing(symptom2)
label var multi "Co-presenting symptoms?"
label define multi	0	"No other recorded symptom" ///
					1	"One or more other symptom at index" ///
					, replace
label values multi multi

gen diff = date_cancer - index_symptom_date
summ diff

* note: pre-symptom cancers removed anyway
gen cancer = diff <= 365 & diff >= 0
tab cancer

*keep if multi30 & !multi

index_symptom_reorder2

* no co-occurring symptom
table (index_symptom) () if !multi          , statistic(freq) statistic(sum cancer) command(r(proportion) r(lb) r(ub): ci proportions cancer, wilson)

* co-occurring symptom
table (index_symptom) () if  multi          , statistic(freq) statistic(sum cancer) command(r(proportion) r(lb) r(ub): ci proportions cancer, wilson)

* no-co-occurring symptom but one happens within 30 days
table (index_symptom) () if !multi & multi30, statistic(freq) statistic(sum cancer) command(r(proportion) r(lb) r(ub): ci proportions cancer, wilson)

