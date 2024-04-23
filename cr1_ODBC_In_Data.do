cd "S:\ECHO_IHI_CPRD\Matt\ACED4_SymptomPPVWork"

/* 
	Load data into memory.
	Identify eligible patients
	
		-after the latest of
		-- date patient was registered to the practice for at least one year (CRD + 1 year)
		-- date practice's uts
		-before the earliest of
		-- practice's last collection date
		-- patient's transfer out date
		-- patient's death 
		-between 30y and 99y old (inclusive)
		### this should possibly be narrowed? UKB has narrower range. But OK.
		
		-- Before first cancer diagnosis (we know about)
		
	Identify "new-onset" symptoms to use as index (three years clear)
	
	Keep random sample separate?
	
	Create analysis dataset

*/

log using creation_log.smcl, replace

* For choosing cancer to keep
set seed 1052


/******************************************************************************/
/* Create frames to store data in convenient memory */
frames reset

frame create cancers
frame create clinical
frame create clinical_random
frame create smoking



/******************************************************************************/
/* Load in cancer cohort data */
frame change cancers
odbc load, exec("select * from allsx_cas") clear dsn(matt)
drop if cancer_site_desc == "Non cancerous ICD10"
  
desc 
list in 1/5


* group cancers matching biobank - might want to relax these?
/*
label define new_cancer	 0 "All" /// /* for use later */
						 1 "Breast" ///
						 2 "Prostate" ///
						 3 "Colorectal" ///
						 4 "Lung" ///
						 5 "Melanoma" ///
						 6 "NHL" ///
						 7 "Kidney" ///
						 8 "Upper GI" ///
						 9 "Bladder" ///
						10 "Uterine" ///
						99 "Other" ///
						, replace
						
gen byte new_cancer = .
replace new_cancer =  1 if inlist(cancer_site_desc, "Breast", "Breast (in-situ)")
replace new_cancer =  2 if inlist(cancer_site_desc, "Prostate")
replace new_cancer =  3 if inlist(cancer_site_desc, "Colon", "Rectum")
replace new_cancer =  4 if inlist(cancer_site_desc, "Lung", "Mesothelioma")
replace new_cancer =  5 if inlist(cancer_site_desc, "Melanoma")
replace new_cancer =  6 if inlist(cancer_site_desc, "Non-hodgkin lymphoma")
replace new_cancer =  7 if inlist(cancer_site_desc, "Kidney")
replace new_cancer =  8 if inlist(cancer_site_desc, "Stomach", "Oesophagus")
replace new_cancer =  9 if inlist(cancer_site_desc, "Bladder", "Bladder (in-situ)")
replace new_cancer = 10 if inlist(cancer_site_desc, "Uterus")
replace new_cancer = 99 if missing(new_cancer)
*/

* broader groups
#delimit ;
label define new_cancer	 1 "Breast" 
						 2 "Gynaecological"
						 3 "Lung"
						 4 "Upper GI"
						 5 "Lower GI"
						 6 "Urological"
						 7 "Prostate"
						 8 "Haematological"
						 9 "Other cancer"
	;
#delimit cr

gen byte new_cancer = .
replace new_cancer =  6 if cancer_site_desc == "Bladder"
replace new_cancer =  6 if cancer_site_desc == "Bladder (in-situ)"
replace new_cancer =  9 if cancer_site_desc == "Brain"
replace new_cancer =  9 if cancer_site_desc == "Meninges"
replace new_cancer =  9 if cancer_site_desc == "Other CNS and intracranial"
replace new_cancer =  1 if cancer_site_desc == "Breast"
replace new_cancer =  1 if cancer_site_desc == "Breast (in-situ)"
replace new_cancer =  9 if cancer_site_desc == "Unknown primary"
replace new_cancer =  2 if cancer_site_desc == "Cervix"
replace new_cancer =  2 if cancer_site_desc == "Cervix (in-situ)"

replace new_cancer =  5 if cancer_site_desc == "Colon"
replace new_cancer =  5 if cancer_site_desc == "Rectum"
replace new_cancer =  9 if cancer_site_desc == "Larynx"
replace new_cancer =  9 if cancer_site_desc == "Oral cavity"
replace new_cancer =  9 if cancer_site_desc == "Oropharynx"
replace new_cancer =  9 if cancer_site_desc == "Thyroid"
replace new_cancer =  9 if cancer_site_desc == "Non-specific head and neck"
replace new_cancer =  9 if cancer_site_desc == "Other head and neck"
replace new_cancer =  8 if cancer_site_desc == "Hodgkin lymphoma"
replace new_cancer =  8 if cancer_site_desc == "Non-hodgkin lymphoma"

replace new_cancer =  6 if cancer_site_desc == "Kidney"
replace new_cancer =  6 if cancer_site_desc == "Other and unspecified urinary"
replace new_cancer =  8 if cancer_site_desc == "Acute myeloid leukaemia"
replace new_cancer =  8 if cancer_site_desc == "Chronic lymphocytic leukaemia"
replace new_cancer =  8 if cancer_site_desc == "Other leukaemia"
replace new_cancer =  8 if cancer_site_desc == "Other haematological"
replace new_cancer =  4 if cancer_site_desc == "Liver"
replace new_cancer =  3 if cancer_site_desc == "Lung"
replace new_cancer =  9 if cancer_site_desc == "Melanoma"
replace new_cancer =  3 if cancer_site_desc == "Mesothelioma"

replace new_cancer =  8 if cancer_site_desc == "Multiple myeloma"
replace new_cancer =  4 if cancer_site_desc == "Oesophagus"
replace new_cancer =  9 if cancer_site_desc == "Other malignant neoplasms"
replace new_cancer =  2 if cancer_site_desc == "Ovary"
replace new_cancer =  4 if cancer_site_desc == "Pancreas"
replace new_cancer =  7 if cancer_site_desc == "Prostate"
replace new_cancer =  9 if cancer_site_desc == "Bone sarcoma"
replace new_cancer =  9 if cancer_site_desc == "Connective and soft tissue sarcoma"
replace new_cancer =  4 if cancer_site_desc == "Stomach"
replace new_cancer =  9 if cancer_site_desc == "Testis"

replace new_cancer =  2 if cancer_site_desc == "Uterus"
replace new_cancer =  2 if cancer_site_desc == "Vulva"

label values new_cancer new_cancer

* keep first cancer in each patient
desc

gen random_number = runiform()
sort e_patid diagnosisdate random_number
format diagnosisdate %tdCCYY-NN-DD
by e_patid: keep if _n == 1

count

drop random_number

keep e_patid diagnosisdate new_cancer cancer_site_number cancer_site_desc
label var e_patid "Patient ID"
label var diagnosisdate "Cancer diagnosis date"
rename diagnosisdate date_cancer
label var new_cancer "Cancer site"
compress


/******************************************************************************/
/* Load in smoking information */
frame change smoking
odbc load, exec("select * from allsx_smoking") clear dsn(matt)

tab smokingcat

gen byte ever_smoker = inlist(smokingcat, "Ex smoker", "Ex/current smoker", "Current smoker")
collapse (mean) ever_smoker = ever_smoker (max) ever_smoker_m = ever_smoker, by(e_patid) fast
tab ever_smoker_m
drop ever_smoker_m



/******************************************************************************/
/* Load in random sample data and link in cancers and smoking to create 
	the analysis dataset */
frame change clinical_random

odbc load, exec("select * from allsx_random") clear dsn(matt)

gen start = .
gen end = .
format start end %td

replace start = crd+365
replace start = uts if start < uts
replace start = date("2007-01-01", "YMD") if start < date("2007-01-01", "YMD") 

replace end = lcd
replace end = tod if tod < end
replace end = deathdate if deathdate < end
replace end = date("2017-12-31", "YMD") if date("2017-12-31", "YMD") < end

gen dob = date(strofreal(yob) + "-06-01", "YMD")
gen date30 = dob+30*365.25
gen date99 = dob+99*365.24
format date30 date99 dob %td
replace start = date30 if start < date30
replace end = date99 if date99 < end

*assert start < end
count
count if start > end
gen chk = start > end
tab yob if chk
* typically younger patients
drop chk
drop if start > end

gen random = runiform()
gen index_date = floor(start + random*(end-start))
format index_date %td

keep   e_patid gender dob index_date end deathdate imd2015_10 
order  e_patid gender dob index_date end deathdate imd2015_10 

* Before first cancer diagnosis (we know about)
frlink m:1 e_patid, frame(cancers)
frget date_cancer new_cancer cancer_site_number cancer_site_desc, from(cancers)

drop if index_date > date_cancer

* male breast -> other
replace new_cancer =  9 if new_cancer == 1 & gender == 1

* get rid of mismatched sex cancers
gen byte site_problem = 0
replace site_problem = 1 if gender == 1 & inlist(new_cancer, ///
									2 /* gynaecological */ /// 
									)
replace site_problem = 1 if gender == 2 & inlist(new_cancer, ///
									7 /* prostate */ /// 
									/* let's ignore testicular for now... */ /// 
									)
sort e_patid site_problem
by e_patid: replace site_problem = site_problem[_N]

drop if site_problem

* get smoking info
frlink 1:1 e_patid, frame(smoking)
frget ever_smoker, from(smoking)
replace ever_smoker = 0 if missing(ever_smoker)
drop smoking

compress
replace ever_smoker = ceil(ever_smoker)
compress

* get IMD info
drop if missing(imd2015_10)

gen imd = ceil( imd2015_10/2 )
drop imd2015_10

gen male = gender == 1

rename deathdate date_death

rename index_date index_symptom_date
gen index_symptom = 0

gen age = datediff_frac(dob, index_symptom_date, "year")

rename ever_smoker smoker

gen byte present_n = 0

keep  e_patid present_n male age smoker imd index_symptom index_symptom_date date_death date_cancer new_cancer cancer_site_number cancer_site_desc
order e_patid present_n male age smoker imd index_symptom index_symptom_date date_death date_cancer new_cancer cancer_site_number cancer_site_desc

destring e_patid, replace
compress

tempfile random_pats
save `random_pats'

/******************************************************************************/
/* Load in symptom data and link in cancers and smoking to create 
	the analysis dataset */
frame change clinical

odbc load, exec("select * from allsx") clear dsn(matt)

tostring yob, replace
gen dob = date(yob + "-06-01", "YMD")
format eventdate dob uts crd lcd tod deathdate %tdCCYY-NN-DD

rename (dob uts crd lcd tod) d_=

gen byte eligible = 1

* not one of the 15 original selection symptoms
replace eligible = 0 if eventtype == "Abdominal lump"
replace eligible = 0 if eventtype == "Constipation"
replace eligible = 0 if eventtype == "Cough"
replace eligible = 0 if eventtype == "Diarrhoea"
replace eligible = 0 if eventtype == "Pelvic pain"
replace eligible = 0 if eventtype == "Stomach disorders" /*"Nausea / vomiting"*/

count if eligible

* after date patient was registered to the practice for at least one year (CRD + 1 year)
replace eligible = 0 if datediff_frac(d_crd, eventdate, "year") < 1

* after date practice's uts
replace eligible = 0 if eventdate < d_uts

* before practice's last collection date 
replace eligible = 0 if eventdate > d_lcd

* before patient's transfer out date
replace eligible = 0 if eventdate > d_tod

* before patient's death 
replace eligible = 0 if eventdate > deathdate

* between 30y and 99y old (inclusive)
gen age_temp = datediff_frac(d_dob, eventdate, "year")
replace eligible = 0 if age_temp <  30
replace eligible = 0 if age_temp >= 99
drop age_temp

drop d_uts d_crd d_lcd d_tod

* sex restrictions
replace eligible = 0 if gender == 1 & inlist(eventtype, ///
												"Post-menopausal bleeding" ///
											)

										
* Before first cancer diagnosis (we know about)
frlink m:1 e_patid, frame(cancers)
frget date_cancer new_cancer cancer_site_number cancer_site_desc, from(cancers)

* male breast -> other
replace new_cancer =  9 if new_cancer == 1 & gender == 1

* get rid of mismatched sex cancers
gen byte site_problem = 0
replace site_problem = 1 if gender == 1 & inlist(new_cancer, ///
									2 /* gynaecological */ /// 
									)
replace site_problem = 1 if gender == 2 & inlist(new_cancer, ///
									7 /* prostate */ /// 
									/* let's ignore testicular for now... */ /// 
									)
sort e_patid site_problem
by e_patid: replace site_problem = site_problem[_N]

replace eligible = 0 if site_problem

replace eligible = 0 if date_cancer <= eventdate

tab eligible

* discard ineligible consultations
drop if !eligible

* Identify first or new onset consultations
gen random_number = runiform()
sort e_patid eventdate random_number

/*
by e_patid: gen first = _n == 1
by e_patid: replace first = first[_n-1] if eventdate == eventdate[_n-1]
*/

preserve
tempfile first_or_new
keep e_patid eventdate
duplicates drop
sort e_patid eventdate
by e_patid: gen first = _n == 1
by e_patid: gen new_onset = (first | eventdate[_n]-eventdate[_n-1] > (365*3))

gen present_n = new_onset
by e_patid: replace present_n = sum(present_n) if new_onset

compress
save `first_or_new'
restore

merge m:1 e_patid eventdate using `first_or_new'
assert inlist(_merge, 3)
drop _merge

sort e_patid eventdate random_number

* remove duplicate symptom events
sort e_patid eventdate eventtype random_number
by e_patid eventdate eventtype: gen first_oftype = _n == 1
keep if first_oftype
drop first_oftype


* identify co-occurring symptoms happening within 30 days of index
gen multi30 = .
summ present_n
local max_events = r(max)
forval event_n = 1/`max_events' {
	preserve
	tempfile first_day
	keep if present_n == `event_n'
	keep e_patid eventdate
	duplicates drop
	rename eventdate first_event
	save `first_day'
	restore
	
	merge m:1 e_patid using `first_day'
	assert inlist(_merge, 1, 3)
	drop _merge
	
	gen fup_limit = first_event + 30
	sort e_patid present_n random_number
	by e_patid present_n: gen first_symptom = eventtype[1]
	replace multi30 = eventdate >= first_event & eventdate <= fup_limit & eventtype != first_symptom if present_n == `event_n'
	drop first_event fup_limit first_symptom
}
rename multi30 m
egen multi30 = max(m), by(e_patid present_n)
drop m

keep if first | new_onset

* reshape to keep co-presenting symptoms
sort e_patid present_n eventdate random_number
by e_patid present_n eventdate: gen ordering = _n

keep  e_patid gender imd2015_10 eventdate eventtype d_dob deathdate date_cancer new_cancer cancer_site_number cancer_site_desc ordering multi30 present_n

* check number of symptoms to deal with
summ ordering, meanonly
local cosymptoms = r(max)

reshape wide eventtype eventdate, i(e_patid present_n) j(ordering)

forval i = 2/`cosymptoms' {
	assert eventdate1 == eventdate`i' | missing(eventdate`i')
	drop eventdate`i'
}

by e_patid present_n: keep if _n == 1

gen byte cancer = datediff_frac(eventdate, date_cancer, "year") <= 1
gen byte death  = datediff_frac(eventdate, deathdate  , "year") <= 1
tab cancer death

gen male = gender == 1

rename eventdate1 index_symptom_date
rename eventtype1 index_symptom

* rename co-symptoms
rename (eventtype*) (symptom*)

rename deathdate date_death
gen age = datediff_frac(d_dob, index_symptom_date, "year")

keep  e_patid present_n male age imd2015_10 index_symptom index_symptom_date date_death date_cancer new_cancer cancer_site_number cancer_site_desc symptom* multi30

* get smoking info
frlink m:1 e_patid, frame(smoking)
frget ever_smoker, from(smoking)
replace ever_smoker = 0 if missing(ever_smoker)
drop smoking

* get IMD info
drop if missing(imd2015_10)

gen imd = ceil( imd2015_10/2 )
drop imd2015_10

label define imd 1 "Least deprived" 5 "Most deprived"
label values imd imd 

keep  e_patid present_n male age ever_smoker imd index_symptom index_symptom_date date_death date_cancer new_cancer cancer_site_number cancer_site_desc symptom* multi30
order e_patid present_n male age ever_smoker imd index_symptom index_symptom_date symptom* multi30 date_death date_cancer new_cancer cancer_site_number cancer_site_desc

compress
replace ever_smoker = ceil(ever_smoker)
compress

label var e_patid "Patient ID"
label var male "Male"
label var age "Age (years)"
rename ever_smoker smoker
label var smoker "Any record of smoking"
label var imd "IMD fifth"
label var index_symptom "Index symptom"
label var index_symptom_date "Index symptom date"
label var date_death "Date of death"
label var date_cancer "Date of cancer"
label var new_cancer "Site of cancer"
label var cancer_site_desc "Specific cancer site"

* fix symptom labelling *
#delimit ;
label define symptom 	 0 "Random sample"
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

foreach var of varlist index_symptom symptom* {
	rename `var' `var'_str
	replace `var'_str = "Nausea / vomiting" if `var'_str == "Stomach disorders"
	encode `var'_str, gen(`var') label(symptom)
	drop `var'_str
}

order e_patid present_n male age smoker imd index_symptom index_symptom_date symptom* multi30 date_death date_cancer new_cancer cancer_site_number cancer_site_desc

/* Finalise and save */
destring e_patid, replace

desc
compress

/* Exclude random sample */
/*
frlink 1:1 e_patid, frame(clinical_random)
drop if !missing(clinical_random)
drop clinical_random
*/

/* Add in random sample */
append using `random_pats' 

sort e_patid present_n

save ../../Data/Matt/ACED4_Data/analysis_file_landmark, replace

use ../../Data/Matt/ACED4_Data/analysis_file_landmark, clear

* exclude second and higher order presentations
drop if present_n >= 2

duplicates report e_patid
duplicates report e_patid present_n

* drop from symptomatic cohort if in random sample
egen min_presentation = min(present_n), by(e_patid)
keep if present_n == min_presentation
drop present_n min_presentation

save ../../Data/Matt/ACED4_Data/analysis_file_major_alternative, replace

frames reset

log close
