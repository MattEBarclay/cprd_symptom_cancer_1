/*
-- Extract for multi-symptom/cancer time-to-event

*/

-- --------------------------------------------------------------------------------
	-- Section A) Create Symptom event file
-- --------------------------------------------------------------------------------
/*
Using a join to the CPRD patient-level file, and practice-level file, 
relevant symptom records occurring at any date in the ‘clinical’ file were selected, 
between 2007 and 2014
*/

drop temporary table if exists matt.initial_sx;
create temporary table matt.initial_sx as (
	select c.d_cprdclin_key, c.e_patid, c.eventdate, c.medcode, l.event_type
	from 18_299_Lyratzopoulos_e2.cprd_clinical c
	inner join matt.phenotypes_medcode l on c.medcode = l.medcode
	where l.type = "Symptom"
); 

drop table if exists matt.allsx;
create table matt.allsx
(
	select d.d_cprdclin_key, d.e_patid, p.gender, d.eventdate, d.medcode, d.event_type as eventtype, p.yob, p.mob, prac.uts, p.crd, prac.lcd, p.tod, p.deathdate, imd.imd2015_10
	from matt.initial_sx d
	inner join  18_299_Lyratzopoulos_e2.cprd_patient p ON d.e_patid = p.e_patid
	inner join  18_299_Lyratzopoulos_e2.cprd_linkage_eligibility_gold link ON d.e_patid = link.e_patid
	inner join  18_299_Lyratzopoulos_e2.cprd_practice prac ON link.e_pracid = prac.e_pracid
	left  join  18_299_Lyratzopoulos_e2.imd_2015 imd ON imd.e_patid = d.e_patid
	WHERE 
		d.eventdate >= makedate(2007, 1)
	AND d.eventdate <= makedate(2017, 365)
)
;
CREATE INDEX `eventdate` ON matt.allsx (`eventdate`);

/* identify 'random sample'/reference group patients */
drop table if exist matt.allsx_random;
create table matt.allsx_random
(
	selectr d.e_patid, p.gender, p.yob, p.mob, prac.uts, p.crd, prac.lcd, p.tod, p.deathdate, imd.imd2015_10
	from 18_299_Lyratzopoulos_e2.cprd_random_sample d
	inner join  18_299_Lyratzopoulos_e2.cprd_patient p ON d.e_patid = p.e_patid
	inner join  18_299_Lyratzopoulos_e2.cprd_linkage_eligibility_gold link ON d.e_patid = link.e_patid
	inner join  18_299_Lyratzopoulos_e2.cprd_practice prac ON link.e_pracid = prac.e_pracid
	left  join  18_299_Lyratzopoulos_e2.imd_2015 imd ON imd.e_patid = d.e_patid
)
;

-- --------------------------------------------------------------------------------------------
-- ... Identify smoking-related codes
-- --------------------------------------------------------------------------------

drop table if exists matt.allsx_smoking;
create table matt.allsx_smoking
(
	select c.e_patid, c.eventdate, c.medcode, l.smokingcat 
    from 18_299_Lyratzopoulos_e2.cprd_clinical c
	inner join matt.smoking l on c.medcode = l.medcode
)
;


-- -----------------------------------------------------------------------
-- C) Select cancers for this cohort
-- --------------------------------------------------------------------------------
/*
all cancer diagnoses were selected from the Cancer Registry file, 
regardless of the date of occurrence. 
for all patients in our extract
*/

drop table if exists  matt.allsx_cas;
create table matt.allsx_cas
(
	select d.e_patid, d.diagnosisdatebest as diagnosisdate, l2.*, l2.cancer_site_number as eventtype
	from 18_299_Lyratzopoulos_e2.cancer_registration_tumour d
	inner join 18_299_Lyratzopoulos.lookup_core_cancersite l2 
	on d.site_icd10_o2 = l2.icd10_4dig
)
;
CREATE INDEX `e_patid` ON matt.allsx_cas (`e_patid`);

-- -----------------------------------------------------------------------
-- Continue in Stata to apply other restrictions (see cr1_ODBC_In_Data.do)
-- -----------------------------------------------------------------------

