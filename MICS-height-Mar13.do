** Anna Bolgrien, Elizabeth Heger Boyle, Matthew Sobek, and Miriam King. IPUMS MICS Data Harmonization Code. Version 1.2 [Stata syntax]. IPUMS: Minneapolis, MN. , 2024. https://doi.org/10.18128/D082.V1.2

** Users should also cite the MICS source data appropriately for each sample you have used. Please see the country specific reports for citation details. In general, the country partnerships with UNICEF are formatted according to the following framework:

* use "/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/mics-height-nutrition.dta"

use "/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/mics-height-protein-4countries-strata.dta"

*use "/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/mics-height-protein-4countries-Apr6.dta"

** SAMPLE identifies the survey in which the case was recorded. It is a composite code. The first 3 digits are the country ISO code, the fourth digit is the MICS round, and the last digit distinguishes between multiple surveys taken in the same country-year. A "0" in the last digit indicates a national sample; other values indicate subnational samples.

** STRATUM and IMICSSTRATUM are not available for any samples in our cart. Why not?**

** STRATUM identifies the sampling stratum for the household. Although stratification is typically based on regional and administrative divisions and urban-rural status, some samples employ a different stratification strategy (see below). For most samples, enumeration areas are selected systematically from each stratum, and clusters are then drawn from those areas.

** IMICSSTRATUM is an identifying number unique to the sampling strata in a given sample. This variable is a concatenation of SAMPLE (which uniquely identifies each country- and year-specific sample) and STRATUM(which identifies the strata number - typically, groups of geographically similar areas, from which primary sampling units are drawn). This variable should be used when pooling samples.

** The correct svyset command for estimates will depend on that particular survey's sampling method and the specific analysis that you want to run. Generally, the correct strata variable to use with IPUMS MICS is IMICSSTRATUM and the correct PSU variable is IMICSPSU; both are available for the Argentina 2019 sample on the household characteristics unit of analysis record. This Linking Guide explains how to merge the data from the household characteristics unit (HH) onto the files with child and household member records.

** Since the primary sampling unit is generally the same as the sampling cluster, IMICSCLUSTER can be used in place of IMICSPSU when the latter is unavailable. Note that IMICSSTRUM is identical to STRATUM except in that it combines the unique sample identifier SAMPLE such that the strata values are unique even when you have pooled multiple samples together. The same is true for IMICSPSU/PSU and IMICSCLUSTER/CLUSTER. I am not finding any documentation suggesting to use HH6 (URBAN) for your strata. The Designing and Selecting the Sample guide available on the MICS4 tools page might be helpful in familiarizing yourself with the general sampling procedure for the MICS surveys.


 log using "/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/mics-analysis-Mar28.txt" , text
 
gen num_animal_protein_cat = .
replace num_animal_protein_cat = 0 if num_animal_protein_dairy==0
replace num_animal_protein_cat = 1 if num_animal_protein_dairy==1
replace num_animal_protein_cat = 2 if num_animal_protein_dairy>=2 & num_animal_protein_dairy!=.


gen any_animal_protein = num_animal_protein>=1 & num_animal_protein!=.
replace any_animal_protein=. if num_animal_protein==.
tab num_animal_protein_dairy any_animal_protein, missing

gen any_animal_protein_dairy = num_animal_protein_dairy>=1 & num_animal_protein_dairy!=.
replace any_animal_protein_dairy=. if num_animal_protein_dairy==.

gen nursing_now = bfnow==1
replace nursing_now=. if bfnow>=7

* Truncate at 5 
* (151,947 real changes made, 151,947 to missing)
* Truncate at 5: (364 real changes made, 364 to missing)
replace bmizwho=. if bmizwho>=95
replace bmizwho=. if bmizwho>=5 | bmizwho<-5

summ bmizwho
histogram bmizwho, width(0.1)

gen car2010=(sample==14040)
gen ghana2011=(sample==28840)
gen mali2009=(sample==46640)
gen sierraleone2017=(sample==69460)

gen mom_lessprimary = (edlevelmom==10)
gen momprimary=(edlevelmom==20)
gen mom_lowsecondary=(edlevelmom==30)
gen mom_secondary=(edlevelmom==40)


tab sample, missing
tab1 car2010 ghana2011 mali2009 sierraleone2017, missing

svyset imicspsu [pweight= weightch], strata(imicsstratum) singleunit(certainty)


dtable bmizwho hazwho wazwho i.edlevelmom i.windex5 i.urban_bin i.female i.birthcert i.milk_yesterday i.yogurt_yesterday  i.cheese_yesterday i.liver_yesterday i.meat_yesterday i.egg_yesterday i.fish_yesterday i.beans_yesterday i.num_animal_protein i.num_animal_protein_dairy i.num_protein agechmo i.agech  i.yogurt_num  i.milk_num , svy by(sample, nototals tests) column(by(hide))  sample(, place(seplabels)) nformat(%3.2f) note(Mean (Standard deviation): p-value from a pooled t-test.) note(Frequency (Percent%): p-value from Pearson test.) export("/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/Table1-MICS.docx", replace)

* Pairwise associations
*oneway QuantResponseVar CategExplanatoryVar, sidak
*pwmean QuantResponseVar, over(CategExplanatoryVar) mcompare(tukey) effects
*tabchi CategResponseVar CategExplanatoryVar, adj


pwmean bmizwho, over(sample) mcompare(tukey) effects
pwmean hazwho, over(sample) mcompare(tukey) effects
pwmean wazwho, over(sample) mcompare(tukey) effects

svy: pwcompare

tabchi edlevelmom sample, adj

dtable bmizwho hazwho wazwho i.edlevelmom i.windex5 i.urban_bin i.female i.birthcert i.milk_yesterday i.yogurt_yesterday  i.cheese_yesterday i.liver_yesterday i.meat_yesterday i.egg_yesterday i.fish_yesterday i.beans_yesterday i.num_animal_protein i.num_animal_protein_dairy i.num_protein agechmo i.agech  i.yogurt_num  i.milk_num, svy by(any_animal_protein, nototals tests) column(by(hide))  sample(, place(seplabels)) note(Mean (Standard deviation): p-value from a pooled t-test.) note(Frequency (Percent%): p-value from Pearson test.) export("/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/Table1b-MICS.docx", replace)

dtable bmizwho hazwho wazwho i.edlevelmom i.windex5 i.urban_bin i.female i.birthcert i.milk_yesterday i.yogurt_yesterday  i.cheese_yesterday i.liver_yesterday i.meat_yesterday i.egg_yesterday i.fish_yesterday i.beans_yesterday i.num_animal_protein i.num_animal_protein_dairy i.num_protein agechmo i.agech  i.yogurt_num  i.milk_num, svy by(any_animal_protein_dairy, nototals tests) column(by(hide))  sample(, place(seplabels)) note(Mean (Standard deviation): p-value from a pooled t-test.) note(Frequency (Percent%): p-value from Pearson test.) export("/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/Table1c-MICS.docx", replace)


dtable bmizwho hazwho wazwho i.edlevelmom i.windex5 i.urban_bin i.female i.birthcert i.milk_yesterday i.yogurt_yesterday  i.cheese_yesterday i.liver_yesterday i.meat_yesterday i.egg_yesterday i.fish_yesterday i.num_animal_protein i.num_animal_protein_dairy i.num_protein agechmo i.agech  i.yogurt_num  i.milk_num, svy by(beans_yesterday, nototals tests) column(by(hide))  sample(, place(seplabels)) note(Mean (Standard deviation): p-value from a pooled t-test.) note(Frequency (Percent%): p-value from Pearson test.) export("/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/Table1beans-MICS.docx", replace)



* Previous unweighted table: 
*table1_mc , by(sample) vars( bmizwho contn %4.3f \ hazwho contn %4.3f \ wazwho contn %4.3f \  edlevelmom cat \ windex5 cat \ birthcert cat \ num_animal_protein cat \ num_animal_protein_dairy cat \ num_protein cat \ agechmo contn \ agech cat  \urban_bin bin \ female bin \ liver_yesterday bin \ meat_yesterday bin \ egg_yesterday bin \ fish_yesterday bin \ beans_yesterday bin \ yogurt_yesterday bin \ yogurt_num contn %4.1f\ milk_yesterday bin \ milk_num contn %4.1f \ cheese_yesterday bin \  ) nospace percent onecol missing clear    
*table1_mc_dta2docx using "MICS-table4.docx", replace






svy: mean bmizwho, over(milk_yesterday) 
svy: mean bmizwho, over(meat_yesterday)

* 

*  Ridgeway, Greg et al. "Propensity Score Analysis with Survey Weighted Data." Journal of causal inference 3.2 (2015): 237–249. PMC. Web. 11 June 2018. https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5802372/


cem female urban_bin agech edlevelmom windex5 sample imicspsu weightch imicsstratum, tr(milk_yesterday)

Matching Summary:
-----------------
Number of strata: 3947
Number of matched strata: 67

               0      1      .
      All  28878   6785   4817
  Matched   2246    454     89
Unmatched  26632   6331   4728




gen new_wt = weightch*cem_weights
svyset imicspsu [pweight= new_wt], strata(imicssttabratum) singleunit(certainty)


svy: regress hazwho female urban_bin i.agech i.edlevelmom i.windex5 i.sample 



********* Entropy balancing

tab num_animal_protein_dairy


svy: regress hazwho any_animal_protein


tab num_animal_protein_dairy num_animal_protein_cat

*  imicspsu imicsstratum edlevelmom mom_lowsecondary 
ebalance any_animal_protein female urban_bin agech mom_lessprimary momprimary mom_secondary windex5 car2010 ghana2011 mali2009 sierraleone2017 weightch , targets(1) gen(entropy_wt2)

gen new_wt2 = weightch*entropy_wt2
svyset imicspsu [pweight= new_wt2], strata(imicsstratum) singleunit(certainty)

svy: regress hazwho any_animal_protein female urban_bin i.agech i.edlevelmom i.windex5 i.sample 

svy: regress wazwho any_animal_protein female urban_bin i.agech i.edlevelmom i.windex5 i.sample 


* Milk

ebalance milk_yesterday female urban_bin agech mom_lessprimary momprimary mom_secondary windex5 car2010 ghana2011 mali2009 sierraleone2017 weightch, targets(1) gen(entropy_wt)

gen new_wt = weightch*entropy_wt
svyset imicspsu [pweight= new_wt], strata(imicsstratum) singleunit(certainty)

svy: regress hazwho milk_yesterday female urban_bin i.agech i.edlevelmom i.windex5 i.sample 

svy: regress wazwho milk_yesterday female urban_bin i.agech i.edlevelmom i.windex5 i.sample 

* BEANS

ebalance beans_yesterday female urban_bin agech mom_lessprimary momprimary mom_secondary windex5 car2010 ghana2011 mali2009 sierraleone2017 weightch , targets(1) gen(entropy_wt3)

gen new_wt3 = weightch*entropy_wt3
svyset imicspsu [pweight= new_wt3], strata(imicsstratum) singleunit(certainty)

svy: regress hazwho beans_yesterday female urban_bin i.agech i.edlevelmom i.windex5 i.sample 

svy: regress wazwho beans_yesterday female urban_bin i.agech i.edlevelmom i.windex5 i.sample 


* Specify the treatment and matching variables
* And then in targets() specify which moments to match
* 1 for means, 2 for variances, 3 for skew
* Let's do means and variances for our continuous variables
* and just means for our binary matching variable (leg_democrat)
* and store the resulting weights in wt
ebalance leg_black medianhhincom blackpercent leg_democrat, targets(2 2 1) gen(wt)

* Use pweight = wt to adjust estimates
regress responded leg_black [pw = wt]


* After entropy balancing on median hh income and black percent and whether the legislator is a Democrat, a Black legislator is 9.1 percentage points more likely to respond to a non-constituent than a non-Black legislator (Coef. 9.1 percentage points, 95% CI (-0.01, 19.1), p=0.08).

poisson responded leg_black [pw = wt], irr robust

* After matching on median hh income and black percent and whether the legislator is a Democrat, a Black legislator is 30% more likely to respond to a non-constituent than a non-Black legislator (IRR = 1.30, 95% CI (0.95, 1.78), p=0.1).



 

* This is column percentages
dtable i.sample i.agech agechmo urban_bin female i.nursing_now bmizwho hazwho wazwho i.edlevelmom i.windex5 i.birthcert i.num_animal_protein i.num_animal_protein_dairy i.num_protein  liver_yesterday meat_yesterday egg_yesterday fish_yesterday beans_yesterday yogurt_yesterday i.yogurt_num i.cheese_yesterday, svy by(milk_yesterday, nototals tests) note(Mean (Standard deviation): p-value from a survey-weighted regression.) note(Frequency (Percent%): p-value from survey-weighted Pearson test.) export("/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/Table2-MICS.docx", replace)



dtable bmizwho hazwho wazwho i.edlevelmom i.windex5 i.birthcert i.num_animal_protein i.num_animal_protein_dairy i.num_protein agechmo i.agech urban_bin female liver_yesterday meat_yesterday egg_yesterday fish_yesterday beans_yesterday yogurt_yesterday i.yogurt_num milk_yesterday i.milk_num i.cheese_yesterday, svy by(sample, nototals tests) column(by(hide))  sample(, place(seplabels)) note(Mean (Standard deviation): p-value from a pooled t-test.) note(Frequency (Percent%): p-value from Pearson test.) export("/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/Table1-MICS.docx", replace)



* table1 mc works better I think. total(before) 
* Can't use [aw=weightch]

table1_mc , by(milk_yesterday) vars( bmizwho contn  \ country cat  \ year cat  \ agech cat  \ nursing_now cat \ ) nospace percent onecol missing clear  catrowperc  


table1_mc_dta2docx using "MICS-table.docx", replace

