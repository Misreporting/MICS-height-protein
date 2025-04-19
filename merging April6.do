use "/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/MICS-strata.dta"

sort sample cluster hhno

save "/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/MICS-strata.dta", replace

use "/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/mics-height-protein-4countries.dta"

sort sample cluster hhno

merge m:1 sample cluster hhno using "/Users/jerosenbaum/Library/CloudStorage/OneDrive-DownstateMedicalCenter/projects/MICS height nutrition/MICS-strata.dta"

 tab sample _merge
 
 tab1 sample _merge
 
 
 replace bmizwho=. if bmizwho>=95

summ bmizwho
histogram bmizwho, width(0.1)

* (2,959 real changes made, 2,959 to missing)
replace hazwho=. if hazwho>=95
* (2,633 real changes made, 2,633 to missing)
replace wazwho=. if wazwho>=95

summ hazwho wazwho

drop if hazwho==.
drop if agech==99

drop if agech==0

tab sample

gen female=sexch==2

gen urban_bin = urban==1

* Merge with household data to get the strata in?
 
* Information how to merge https://mics.ipums.org/mics/linking.shtml


* This seems to be the correct weighting command but imicsstratum isn't available. I asked on the MICS forum why not.
*svyset imicscluster [pweight= weightch], strata(IMICSSTRATUM) singleunit(certainty)

*codebook ateliver atemeat ateegg atefish atebeans atecheese ateyogurt ateyogurtnum drankmilk drankmilknum

gen liver_yesterday = ateliver==1
replace liver_yesterday=. if ateliver>=7
tab liver_yesterday ateliver

gen meat_yesterday=atemeat==1
replace meat_yesterday=. if atemeat>=7

gen egg_yesterday=ateegg==1
replace egg_yesterday=. if ateegg>=7
tab ateegg egg_yesterday

gen fish_yesterday=atefish==1
replace fish_yesterday=. if atefish>=7

gen beans_yesterday=atebeans==1
replace beans_yesterday=. if atebeans>=7

gen yogurt_yesterday=ateyogurt==1
replace yogurt_yesterday=. if ateyogurt>=7
tab yogurt_yesterday sample, missing


gen yogurt_num=ateyogurtnum if yogurt_yesterday==1
replace yogurt_num=2 if ateyogurtnum>2 & yogurt_yesterday==1
replace yogurt_num=0 if ateyogurt==0
replace yogurt_num=. if ateyogurt>=7 | ateyogurtnum==98
tab yogurt_num sample, missing

gen milk_yesterday=drankmilk==1
replace milk_yesterday=. if drankmilk>=7

gen milk_num=drankmilknum  if milk_yesterday==1
replace milk_num=3 if drankmilknum>3 & drankmilknum<97 & milk_yesterday==1
replace milk_num=. if drankmilk==7 | drankmilk==8 | drankmilk==9 | drankmilknum ==98 | drankmilknum ==97 | drankmilknum ==99
replace milk_num=0 if drankmilk==0

tab milk_num


* Cheese not asked in some of the countries
gen cheese_yesterday=atecheese==1 
replace cheese_yesterday=. if atecheese>=7
tab cheese_yesterday sample, missing

gen num_animal_protein=egg_yesterday + meat_yesterday + liver_yesterday + fish_yesterday 
gen num_animal_protein_dairy=egg_yesterday + meat_yesterday + liver_yesterday + fish_yesterday + milk_yesterday + yogurt_yesterday + cheese_yesterday 
replace num_animal_protein_dairy=egg_yesterday + meat_yesterday + liver_yesterday + fish_yesterday + milk_yesterday + yogurt_yesterday  if cheese_yesterday==.

replace num_animal_protein_dairy=egg_yesterday + meat_yesterday + liver_yesterday + fish_yesterday + milk_yesterday + cheese_yesterday if yogurt_yesterday==.


gen num_protein=egg_yesterday + meat_yesterday + liver_yesterday + fish_yesterday + milk_yesterday + yogurt_yesterday + cheese_yesterday + beans_yesterday
replace num_protein=egg_yesterday + meat_yesterday + liver_yesterday + fish_yesterday + milk_yesterday + yogurt_yesterday + beans_yesterday if cheese_yesterday ==.
replace num_protein=egg_yesterday + meat_yesterday + liver_yesterday + fish_yesterday + milk_yesterday + cheese_yesterday + beans_yesterday if  yogurt_yesterday==.

