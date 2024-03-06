global path "/Users/pranjalimaneriker/Documents/Econ643"

use "$path/Empirical project/input/oreopoulos-resume-study-replication-data-file.dta", clear

**********************************
*Prelinimary data prep
**********************************

*define labels for sex and Resume_type
label define sex 0 "Male" 1 "Female"
label values female sex
label define typelabel 0 "Type 0" 1 "Type 1" 2 "Type 2" 3 "Type 3" 4 "Type 4"
label values type typelabel
rename name_ethnicity name_ethnicity_temp

*generate variable to combine British and Canadian names as English names
gen name_ethnicity = name_ethnicity_temp
replace name_ethnicity = "English" if name_ethnicity_temp == "British" | name_ethnicity_temp == "Canada"

***********************************
*RESHAPING DATA
***********************************

preserve

keep callback type firmid name 

reshape wide callback type, i(firmid) j(name) string

restore

/***********************************
*RESHAPING DATA (Alternate method)
***********************************
preserve

drop additional_credential language_skills accreditation reference legal listedaccreditation ma female certificate ba_quality exp_highquality interview second_callback extracurricular_skills chinese indian british pakistani Chn_Cdn same_exp name_ethnicity_temp

reshape wide callback name_ethnicity type, i(firmid) j(name) string
reshape long callback name_ethnicity type, i(firmid) j(name) string

restore
*/
**********************************
*TABLE 2- SUMMARY STATISTICS
**********************************

*Replication of Table 2A- Number of resumes sent by resume type and ethnicity
table (name_ethnicity female name) (type), nototals
collect title "Number of resumes sent by resume type and ethnicity"
collect export "Table2_Summary_Resumes.docx", replace

*Replication of Table 2B- Number of callbacks received by resume type and ethnicity
table (name_ethnicity female name) (type), statistic(sum callback) nototals
collect title "Number of callbacks received by resume type and ethnicity"
collect export "Table2_Summary_Statistics.docx", replace

**********************************
*TABLE 5- REGRESSION MODELS
**********************************

drop if name_ethnicity_temp=="British" | name_ethnicity_temp=="Chn-Cdn" | name_ethnicity_temp=="Greek"

replace same_exp=0 if same_exp==.
replace reference = 0 if reference==.
replace accreditation=0 if accreditation==.
replace legal=0 if legal==.

eststo m1: reg callback i.type i.fall_data, robust
eststo m2: reg callback i.type female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data, robust

eststo m3: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 0, robust
eststo m4: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal  i.fall_data if type == 1, robust
eststo m5: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 2, robust
eststo m6: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 3, robust
eststo m7: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 4, robust

label variable female "Resume characteristic female"
label variable ba_quality "Top 200 world ranking university"
label variable extracurricular_skills "List extracurricular activities"
label variable language_skills "Fluent in French and other languages"
label variable ma "Canadian master's degree"
label variable same_exp "Multinational firm work experience"
label variable exp_highquality "High quality work experience"
label variable reference "List Canadian references"
label variable accreditation "Accreditation of foreign education"
label variable legal "Permanent resident indicated"

esttab m1 m2 using "$path/Empirical project/output/table2_Panel_A.rtf", replace drop(*fall_data female ba_quality extracurricular_skills language_skills ma same_exp exp_highquality reference accreditation legal) b(a2) title(Panel A. Callback rate differences with and without controls) nonumbers mtitles ("Callback rate and unconditional callback difference between other resume types" "Callback difference after conditioning on all resume characteristics")
esttab m3 m4 m5 m6 m7 using "$path/Empirical project/output/table2_Panel_B.rtf", drop(*fall_data) replace title(Panel B. Resume characteristic effects on callback rate by type) nonumbers mtitles("Type 0" "Type 1" "Type 2" "Type 3" "Type 4") label b(a2) 
*************************************
*BAR GRAPH
*************************************
graph bar callback, over(type) blabel(bar, format(%9.2gc)) title("Callback rates by Resume type")


************************************
*Authors Notes
************************************
/*
drop additional_credential language_skills listedaccreditation ma female certificate ba_quality exp_highquality interview second_callback extracurricular_skills chinese indian british pakistani Chn_Cdn same_exp
*/


/*drop observations with canadian accrediations, canadaian references and canadian permanent residency status

drop if accreditation==1 | reference==1 | legal==1


/*If data is missing for same firm experience, Canadian reference, Canadian acrreditation and Canadian permanent residency status, replace with 0
*/

replace same_exp = 0 if same_exp == .
replace reference = 0 if reference == .
replace accreditation = 0 if accreditation == .
replace legal=0 if legal == .

eststo m1: reg callback i.type i.fall_data, robust
eststo m2: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 0, robust
eststo m3: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal  i.fall_data if type == 1, robust
eststo m4: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 2, robust
eststo m5: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 3, robust
eststo m6: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 4, robust

esttab m1
esttab m2 m3 m4 m5 m6



/**drop observations with  British, Chinese Canadian and Greek sounding names 
drop if name_ethnicity=="British" | name_ethnicity=="Chn-Cdn" | name_ethnicity=="Greek"

/*If data is missing for same firm experience, Canadian reference, Canadian acrreditation and Canadian permanent residency status, replace with 0
*/

replace same_exp=0 if same_exp==.
replace reference = 0 if reference==.
replace accreditation=0 if accreditation==.
replace legal=0 if legal==.

/* Regressions
Model 1: Regress Callbacks on Resume type and resume collection period
Model 2 to 6: Regress Callbacks on Sex, Bachelor's degree quality, Extracurricular skills listed, Language skills listed, Master's degree listed, Same firm experience listed, Large firm experience listed, Candian reference listed, Canadian education listed, Canadian permanent residency status listed and resume collection period for Resume types 0, 1, 2, 3 and 4.
*/

eststo m1: reg callback i.type i.fall_data, robust
eststo m2: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 0, robust
eststo m3: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal  i.fall_data if type == 1, robust
eststo m4: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 2, robust
eststo m5: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 3, robust
eststo m6: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 4, robust

esttab m1
esttab m2 m3 m4 m5 m6

drop additional_credential language_skills listed accreditation ma female certificate ba_quality exp_highquality interview second_callback extracurricular_skills chinese indian british pakistani Chn_Cdn same_exp name_ethnicity_temp

reshape wide callback name_ethnicity type, i(firmid) j(name) string

/*
drop additional_credential language_skills listedaccreditation ma female certificate ba_quality exp_highquality interview second_callback extracurricular_skills chinese indian british pakistani Chn_Cdn same_exp
*/


/*drop observations with canadian accrediations, canadaian references and canadian permanent residency status

drop if accreditation==1 | reference==1 | legal==1


/*If data is missing for same firm experience, Canadian reference, Canadian acrreditation and Canadian permanent residency status, replace with 0
*/

replace same_exp = 0 if same_exp == .
replace reference = 0 if reference == .
replace accreditation = 0 if accreditation == .
replace legal=0 if legal == .

eststo m1: reg callback i.type i.fall_data, robust
eststo m2: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 0, robust
eststo m3: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal  i.fall_data if type == 1, robust
eststo m4: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 2, robust
eststo m5: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 3, robust
eststo m6: reg callback female ba_quality extracurricular_skills language_skills ma same_exp exp_highqual reference accreditation legal i.fall_data if type == 4, robust

esttab m1
esttab m2 m3 m4 m5 m6

/**Reshaping data
reshape wide callback name_ethnicity type, i(firmid) j(name) string
reshape long callback name_ethnicity type, i(firmid) j(name) string
*/

xi: reg callback i.type if name_ethnicity=="Indian" | name_ethnicity=="Canada", robust
outreg2 _Itype* using tables, replace bdec(3) aster(se) excel bracket(se)
xi: reg callback i.type if name_ethnicity=="Pakistani" | name_ethnicity=="Canada", robust
outreg2 _Itype* using tables, append bdec(3) aster(se) excel bracket(se)
xi: reg callback i.type if name_ethnicity=="Chinese" | name_ethnicity=="Canada", robust
outreg2 _Itype* using tables, append bdec(3) aster(se) excel bracket(se)
xi: reg callback i.type if name_ethnicity=="Chn-Cdn" | name_ethnicity=="Canada", robust
outreg2 _Itype* using tables, append bdec(3) aster(se) excel bracket(se)
xi: reg callback i.type if name_ethnicity=="British" | name_ethnicity=="Canada", robust
outreg2 _Itype* using tables, append bdec(3) aster(se) excel bracket(se)
xi: reg callback i.type if name_ethnicity=="Greek" | name_ethnicity=="Canada", robust
outreg2 _Itype* using tables, append bdec(3) aster(se) excel bracket(se)
xi: reg callback i.type if name_ethnicity=="Indian" | name_ethnicity=="Chinese" | name_ethnicity=="Pakistani" | name_ethnicity=="Canada", robust
outreg2 _Itype* using tables, append bdec(3) aster(se) seeo excel bracket(se)

reg callback type if type == 0
*/
