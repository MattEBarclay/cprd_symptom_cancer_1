# Cancer  incidence and competing mortality risk following 15 presenting symptoms in primary care: a population-based cohort study using electronic healthcare records

Contains the major analysis scripts used for the analysis, and the main results files. Almost all in Stata format.

Note - this repository does not include any source data, which must be requested from CPRD.

Note - the code here will require minor editing to run, as the repository does not quite match the structure of the folder within our secure data environment.

## Abstract

### Objectives: 
To provide a comprehensive assessment of risk of cancer diagnosis and non-cancer mortality following primary care consultation for 15 new-onset symptoms. 

### Design: 
Cohort study.

### Setting: 
UK primary care, 2007 –  2017.

### Participants: 
Among patients aged 18-99 registered at a general practice included in CPRD Gold, data were analysed from a randomly selected cohort of 1M patients, and from symptomatic cohorts of patients presenting with 15 new onset symptoms (abdominal pain, abdominal bloating, rectal bleed, change in bowel habit, dyspepsia, dysphagia, dyspnoea, haemoptysis, haematuria, fatigue, night sweats, weight loss, jaundice, breast lump, post-menopausal bleed).

### Main outcome measures: 
Risk of cancer diagnosis and risk of death in the 12 months following index consultation. Time-to-event models were used to estimate outcome-specific hazards for site-specific cancer diagnosis and non-cancer mortality; results were combined using the latent failure time approach to estimate 3-, 6- and 12-month risk post-consultation.

### Results: 
Data were analysed on 1,622,419 patients, of whom 36,802 had a cancer diagnosis and 28,857 died without a cancer diagnosis within 12 months of first consultation. Absolute non-cancer mortality risk exceeded cancer diagnosis risk in the (random sample) reference group and in symptomatic cohorts with five symptoms (dyspnoea, dysphagia, weight loss, fatigue, or jaundice); absolute cancer risk exceeded mortality risk for patients with breast lump or post-menopausal bleed; for other symptoms the risk of a cancer diagnosis and non-cancer mortality were similar.

Ever-smoking was associated with substantially raised cause-specific hazard for lung cancer (e.g., HR for women 4.8, 95%CI 4.2-5.6), and slightly raised hazards for upper GI and urological cancers. System-specific symptoms (e.g. respiratory) were strongly associated with cancers of corresponding organs (e.g. lung), but non-organ-specific symptoms tended to be similarly associated with cancers of different systems.

In patients with red-flag symptoms, the risk of specific cancers exceeded the UK urgent referral risk threshold of 3% from a relatively young age (e.g., for male smokers with haemoptysis the risk of lung cancer exceeded 3% from age 55). For non-organ-specific symptoms (such as loss of weight, or fatigue), while the risk of any cancer often exceeded 3%, the risk of any individual cancer type either did not reach this threshold at any age, or reached it only in older patients.

### Conclusions: 
In patients with new-onset symptoms in primary care the risk of cancer diagnosis and of non-cancer mortality are often comparable. Smoking-status is highly informative for cancer risk, both for respiratory and non-organ-specific symptoms. A holistic approach to risk assessment that includes the risk of multiople different cancer types alongside the risk of mortality due to consequential illnesses other than cancer, especially among older patients, is needed to inform management of symptomatic patients in primary care, particularly for patients with non-organ-specific symptoms.

## Contents - analysis scripts

### sql/cohort_identification.sql
Creates initial MySQL tables of potential symptomatic patients as well as the reference group.

### cr1_ODBC_In_Data.do
Imports data from MySQL tables, applies inclusion/exclusion rules, and creates an initial analysis flat file (for e.g. calculating counts etc).

### cr2_prep_multiendpoint.do
Converts flat files into a format suitable for multi-endpoint (i.e., multistate) modelling.

### an1_table1.do
Creates a 'table 1' of cohort statistics from the flat file

### an2_nonparam.do
Aalen-Johansen non-parametric estimation of cumulative incidence of the different cancer sites (and death), by sex and smoking status.

### an3_param.do
Outcome-specific Royston-Parmar models of the hazards of the different outcomes.

### an4_simulate_probs_men.do and an5_simulate_probs_women.do
Simulates from the outcome-specific models to estimate the age-sex-smoking-specific cumulative incidence of the different cancer sites (and death).

### an6_plot_nonparam_probablities
Plots the cumulative incidence estimates produced in an2_nonparam.do

### an7_combine_results.do
Combines the simulated probabilities produced in an4... and an5...

### an8_better_plot_states.do
Plots the simulated cumulative incidence probabilities, working from the combined file produced in an7...

### an9_fit_check.do
Some very quick comparisons of observed and modelled outcomes, to ensure the approach gives sensible numbers.

### an10_CIs.do
Try to calculate confidence intervals for the simulated probabilities - noting that the effort is indicative at best due to computational limitations.
I also had some slightly different code running in the high performance cluster, but this did not solve the problem.

### an11_combine.do
Combine the various outputs of the confidence interval calculations into a single file.

### an12_nonparam_combos.do
Quickly estimate the risk of cancer for patients with multiple symptoms at index (vs those with only one symptom).

## Contents - ado files

### index_symptom_reorder.ado and index_symptom_reorder2.ado
Convenience files for changing symptom ordering, primarily for plots and tables.

### sim_outcomes.ado
Program for simulating outcome probabilities, to simplify loops in analytical scripts.

### sim_outcomes_ci.ado
Program for simulating outcome probabilities with confidence intervals, to simplify loops in analytical scripts.

## Contents - results files

### ci_inc_all.dta
Point estimates and confidence intervals for cancer and mortality risk at 12 months in symptomatic and reference groups, sex and smoking-status specific, at five-year intervals of age.

### inc_combined.dta
Point estimates of cancer and mortality risk in symptomatic and reference groups, sex and smoking-status specific, at five-year intervals of age. Includes estimates of cumulative risk up to each month in the first year (and each 10th of each month).

### nonparam_[---].dta
Non-parametric estimates of cancer and mortality risk in symptomatic and reference groups, sex and smoking-status specific. Includes estimates of cumulative risk up to each month in the first year.