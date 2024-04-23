* produce a basic table 1
cd "S:\ECHO_IHI_CPRD\Matt\ACED4_SymptomPPVWork"

use ../../Data/Matt/ACED4_Data/analysis_file_major_alternative, clear

* reshuffle symptoms
index_symptom_reorder2

/* Age etc */
gen age_grp = 10*(floor(age/10))

summ age
label define age_grp 30 "30 to 39" 40 "40 to 49" 50 "50 to 59" 60 "60 to 69" 70 "70 to 79" 80 "80 to 89" 90 "90 to 99", replace
label values age_grp age_grp

label var age_grp "Age at index (grouped)"
label var male "Sex"
label var imd "IMD group"
cap drop gap
gen gap = date_cancer-index_symptom_date

/* Follow-up state matching main analysis */
gen fup_end = min(date_cancer, /*date_mi, date_stroke,*/ date_death, index_symptom_date+365)
format fup_end %tdCCYY-NN-DD

gen byte fup_cancer = new_cancer*(date_cancer == fup_end & !missing(new_cancer))
replace fup_cancer = 0 if missing(fup_cancer)
label values fup_cancer new_cancer
gen byte fup_death = date_death == fup_end

/*
gen byte fup_stroke = (date_stroke == fup_end & !missing(date_stroke))
gen byte fup_mi     = (date_mi     == fup_end & !missing(date_mi))
*/

gen byte fup_state = fup_cancer

/*
replace fup_state = 10 if fup_mi & fup_state == 0
replace fup_state = 11 if fup_stroke & fup_state == 0
*/

* lump all cancers together
replace fup_state = 1 if fup_state > 1
replace fup_state = 10 if fup_death & fup_state == 0

#delimit ;
label define fup_state	 0 "Censored" /* for use later */
						 1 "Cancer"
						10 "Death"
						, replace
	;
#delimit cr
label values fup_state fup_state
tab fup_state



/* New cancer/death indicators */
gen byte cancer   = fup_state == 1
gen byte death_nc = fup_state == 10
gen byte death    = (date_death -index_symptom_date) <= 365





* easy percents
gen pcancer    = 100*cancer
gen pdeath_nc  = 100*death_nc
gen pdeath     = 100*death

cap collect drop table1
collect create table1

gen total = 1
collect: table total        , nototal stat(freq)               stat(sum cancer) stat(mean pcancer) stat(sum death_nc) stat(mean pdeath_nc) stat(sum death) stat(mean pdeath)
collect: table age_grp      , nototal stat(freq) stat(percent) stat(sum cancer) stat(mean pcancer) stat(sum death_nc) stat(mean pdeath_nc) stat(sum death) stat(mean pdeath) append
collect: table male         , nototal stat(freq) stat(percent) stat(sum cancer) stat(mean pcancer) stat(sum death_nc) stat(mean pdeath_nc) stat(sum death) stat(mean pdeath) append
collect: table imd          , nototal stat(freq) stat(percent) stat(sum cancer) stat(mean pcancer) stat(sum death_nc) stat(mean pdeath_nc) stat(sum death) stat(mean pdeath) append
collect: table smoker       , nototal stat(freq) stat(percent) stat(sum cancer) stat(mean pcancer) stat(sum death_nc) stat(mean pdeath_nc) stat(sum death) stat(mean pdeath) append
collect: table index_symptom, nototal stat(freq) stat(percent) stat(sum cancer) stat(mean pcancer) stat(sum death_nc) stat(mean pdeath_nc) stat(sum death) stat(mean pdeath) append
drop total

collect style header total, level(label) title(hide)

collect addtags cohort[freq]    , fortags(result[frequency])
collect addtags cohort[percent] , fortags(result[percent])
collect addtags cancer[freq]    , fortags(var[cancer])
collect addtags cancer[percent] , fortags(var[pcancer])
collect addtags death_nc[freq]     , fortags(var[death_nc])
collect addtags death_nc[percent]  , fortags(var[pdeath_nc])
collect addtags death[freq]     , fortags(var[death])
collect addtags death[percent]  , fortags(var[pdeath])

collect style cell cohort[percent], nformat(%02.1f) sformat("(%s)")
collect style cell cancer[percent], nformat(%02.1f) sformat("(%s)")
collect style cell death_nc[percent] , nformat(%02.1f) sformat("(%s)")
collect style cell death[percent] , nformat(%02.1f) sformat("(%s)")

collect style cell cohort[freq], nformat(%9.0fc)
collect style cell cancer[freq], nformat(%9.0fc)
collect style cell death[freq] , nformat(%9.0fc)
collect style cell death_nc[freq] , nformat(%9.0fc)

collect label levels cohort freq "N", modify
collect label levels cohort percent "(col %)", modify
collect label levels cancer freq "N", modify
collect label levels cancer percent "(row %)", modify
collect label levels death_nc  freq "N", modify
collect label levels death_nc  percent "(row %)", modify
collect label levels death  freq "N", modify
collect label levels death  percent "(row %)", modify

collect label dim cohort "Cohort", modify
collect label dim cancer "Cancers within 12 months", modify
collect label dim death_nc  "Deaths within 12 months, no preceding cancer diagnosis", modify
collect label dim death  "Deaths within 12 months", modify

collect layout (total age_grp male imd smoker index_symptom) (cohort cancer death_nc death)

putdocx clear
putdocx begin
putdocx paragraph
putdocx text ("Table 1")

putdocx paragraph
putdocx collect
local todaydate: display %tdCCYY-NN-DD =daily("`c(current_date)'","DMY")
di "`todaydate'"
putdocx save "results/Table1_`todaydate'.docx", replace