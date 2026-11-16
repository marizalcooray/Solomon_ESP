/*==============================================================================
Solomon Islands
Household data
-------------------------------------------------------------------------------
Rolando Gonzales
This script uses the tablabs command, which can be downloaded here:
https://github.com/rogon666/tablabs
==============================================================================*/

********************************************************************************
**# (0) Loading data
use "Z:\UpWork\UpWork2022\Solomon\db\HH_2021.dta", clear

********************************************************************************
**# (1) Cleaning
	count
	//125
	
	* 1.1 cleaning practice survey
	tablabs practice
	drop if practice == 1 // Dropping practice surveys
	count
	//120

	* 1.3 Dropping variables without information on gender
	clonevar sex = sex_respondent
	tab sex ar07_1, m
	drop if sex_respondent == .
	count 
	//119

	* Winsorizing
	foreach var of varlist ks01_grain_rice ks01_grain_others ks01_tubers ks01_fish_fresh ks01_meats ks01_eggs ks01_milk ks01_vegetables ks01_legumes ks01_fruits ks01_oil ks01_beverages ks01_other_ready_meal ks01_beverage_non_alco ks01_other_beverage_alco ks01_tobacco_lekona ks01_tobacco_cigarettes ks01_tobacco_betelnut{
		winsor2 `var', cuts(1 98) suffix(_w)
	}
	
	foreach var of varlist ks06a_housing ks06a_housing_mobile ks06a_miscellaneous_medical ks06a_miscellaneous_education ks06a_miscellaneous_transport ks06a_clothing ks06a_durable_goods ks06a_tax ks06a_levy ks06a_health_insurance ks06a_ritual{
		winsor2 `var', cuts(1 98) suffix(_w)
	}
	
	* Cleaning province
	clonevar province = province_name
	tab province, m
	*graph bar (count), over(province)
	replace province = "Honiara" if province == "HONIARA"
	replace province = "Honiara" if province == "HONIARA"
	replace province = "Isabel"  if province == "Isabel Province"
	replace province = "Isabel"  if province == "Isabel province"
	replace province = "Isabel"  if province == "isabel"
	replace province = "Isabel"  if province == "Babel"
	replace province = "Malaita"  if province == "Malaita province"
	replace province = "Malaita"  if province == "Malaita Province"
	tab province sex, m
	*graph bar (count), over(province)
	
	* Age
	clonevar age = ar04a_1
	replace age = . if ar04a_1 == 0
	ta age sex, m
	
	* Keeping only household heads 
	tablabs ar02_1
	keep if ar02_1 == 1
	ta ar02_1 sex
	
********************************************************************************	
**# Changes in prices
	tablabs ks06b_housing
/*
---------------------------------------------------------------------------------------------
                                                                                 |  Frequency
---------------------------------------------------------------------------------+-----------
KS06b_housing overall household consumption – Electricity bills, gas bills, kero |           
  1: We spent about the same amount for one month as we did 12 months ago        |        100
  2: The amount we spend has increased for one month since 12 months ago         |         60
  3: Amount has decreased (avg) since 12 months ago                              |         39
  4: Selected 'Did not spend' in the 'last month' question                       |        129
  .                                                                              |        151
  Total                                                                          |        479

*/
	tab province ks06b_housing
	tab ks06b_housing sex
	
********************************************************************************
**# Household situation

	tab province sex, m
	
	ta age sex, m
	
	* Education
	ta ar12_1 sex
	

	* Activity status
	ta ar09_1 sex
	
	tablabs ar10_1
	ta ar09_1 ar10_1
	tablabs ar09_1
	recode ar09_1 (1 = 1 "Employed") (2 = 2 "Unemployed") (3/95 = 3 "Other"), gen(act_sts)
	lab var act_sts "Activity status"
	ta act_sts ar09_1
	
	* Sector
	ta ar11_1 sex
	clonevar sector = ar11_1
	ta sector ar09_1, m
	
	ta ar16 ar09_1, m
	
	
	* Additional job
	tablabs ar16
	ta ar16, m
	ta ar16a, m
	/*
		1. due to a rising cost of living where I live
		2. due to my financial circumstances changing in the past 12 months
		3.  due to not being paid enough by my main employer
		4. all of the above
		5. none of the above
	*/
	table (sex act_sts) ar16, nototal
	
	* Assets
	tablabs ar02_1
	gen hhhead = (ar02_1 == 1)
	tab hhhead ar02_1
	
	desc hr31_*
	foreach var of varlist hr31_*{
		tablabs `var'
		replace `var' = 0 if `var' == 2
		tablabs `var'
	}
	* hr31*: Does this household have these assets, which values at least SBD 5,000? 
	* Solomon Islands Dollar (SBD) 

	egen assets = rowtotal(hr31_*) if hhhead == 1
	tab  assets sex, m
	
********************************************************************************
**# Food security
	tab ks01b sex	
	
	tab ks03 sex, m
	// ks03: Anyone living in the household has not eaten for up to a day in the past 6 months
	ta ks04 sex, m
	ta ks05 sex, m
	
	ta ks06 sex
	
	* food access:
	des ks01_grain_rice_op ks01_grain_others_op ks01_tubers_op ks01_fish_fresh_op ks01_meats_op ks01_eggs_op ks01_milk_op ks01_vegetables_op ks01_legumes_op ks01_fruits_op ks01_oil_op ks01_beverages_op ks01_other_ready_meal_op ks01_beverage_non_alco_op ks01_beverage_alco_op ks01_tobacco_lekona_op ks01_tobacco_cigarettes_op ks01_tobacco_betelnut_op
	

	* Change in eating habits:
	ta ks01b sex, m
	ta ks01c sex, m
	
	* Expenses in food with alcohol and tobacco
	egen food_exp = rowtotal(ks01_grain_rice ks01_grain_others ks01_tubers ks01_fish_fresh ks01_meats ks01_eggs ks01_milk ks01_vegetables ks01_legumes ks01_fruits ks01_oil ks01_beverages ks01_other_ready_meal ks01_beverage_non_alco ks01_other_beverage_alco ks01_tobacco_lekona ks01_tobacco_cigarettes ks01_tobacco_betelnut)
	ta food_exp, m
	
	* Expenses in food with alcohol and tobacco
	egen food_nac = rowtotal(ks01_grain_rice ks01_grain_others ks01_tubers ks01_fish_fresh ks01_meats ks01_eggs ks01_milk ks01_vegetables ks01_legumes ks01_fruits ks01_oil ks01_beverages ks01_other_ready_meal ks01_beverage_non_alco )
	ta food_nac, m

	foreach var of varlist ks01_grain_rice ks01_grain_others ks01_tubers ks01_fish_fresh ks01_meats ks01_eggs ks01_milk ks01_vegetables ks01_legumes ks01_fruits ks01_oil ks01_beverages ks01_other_ready_meal ks01_beverage_non_alco ks01_other_beverage_alco ks01_tobacco_lekona ks01_tobacco_cigarettes ks01_tobacco_betelnut{
		summ `var'
	}
	
	foreach var of varlist ks01_grain_rice ks01_grain_others ks01_tubers ks01_fish_fresh ks01_meats ks01_eggs ks01_milk ks01_vegetables ks01_legumes ks01_fruits ks01_oil ks01_beverages ks01_other_ready_meal ks01_beverage_non_alco ks01_other_beverage_alco ks01_tobacco_lekona ks01_tobacco_cigarettes ks01_tobacco_betelnut{
		summ `var' if sex == 1 // Male
	}
	
	foreach var of varlist ks01_grain_rice ks01_grain_others ks01_tubers ks01_fish_fresh ks01_meats ks01_eggs ks01_milk ks01_vegetables ks01_legumes ks01_fruits ks01_oil ks01_beverages ks01_other_ready_meal ks01_beverage_non_alco ks01_other_beverage_alco ks01_tobacco_lekona ks01_tobacco_cigarettes ks01_tobacco_betelnut{
		summ `var' if sex == 2 // Female
	}	
	foreach var of varlist ks01_grain_rice_w ks01_grain_others_w ks01_tubers ks01_fish_fresh_w ks01_meats_w ks01_eggs_w ks01_milk_w ks01_vegetables_w ks01_legumes_w ks01_fruits_w ks01_oil_w ks01_beverages_w ks01_other_ready_meal_w ks01_beverage_non_alco_w{
		summ `var'
	}
	
	* Household expenses
	egen hh_exp = rowtotal(ks06a_housing ks06a_housing_mobile ks06a_miscellaneous_medical ks06a_miscellaneous_education ks06a_miscellaneous_transport ks06a_clothing ks06a_durable_goods ks06a_tax ks06a_levy ks06a_health_insurance ks06a_ritual)
	summ hh_exp, d
	ta hh_exp, m
	
	* Total expenses
	gen toth_exp = food_exp + hh_exp // total household expenses
	
	gen foop_nac =  (food_nac/toth_exp)*100
	summ foop_nac
	summ foop_nac if sex == 2 // Female
	summ foop_nac if sex == 1 // Male
	
	egen nutrient = rowtotal(ks01_vegetables ks01_legumes ks01_fruits)
	gen  foon_exp = (nutrient/food_exp)*100
	summ foon_exp	
	summ foon_exp if sex == 2 // Female
	summ foon_exp if sex == 1 // male
	
	egen highcaloric = rowtotal(ks01_fish_fresh ks01_meats ks01_eggs ks01_milk ks01_grain_rice ks01_tubers ks01_grain_others ks01_tubers ks01_oil)
	gen  fooh_exp =  (highcaloric/food_exp)*100
	summ fooh_exp
	summ fooh_exp if sex == 2 // Female
	summ fooh_exp if sex == 1 // male

	
********************************************************************************
**# HH debts	
desc bh*
	tab bh01a sex, m
	ta bh01b sex, m
	
	ta hr35 sex, m
	
	ta sv01 sex, m

********************************************************************************
**# Savings and NPF funds

	gen 	npf = 0
	replace npf = 1 if npf_k == 1 
	replace npf = 1 if npf_l != . 
	replace npf = 1 if npf_ma > 0 & npf_ma != .
	ta npf sex, m
	
	clonevar savs = sv03a
	egen sv03a_p99 = pctile(sv03a), p(99)
	replace savs = . if savs >= sv03a_p99	
	
********************************************************************************
* Difficulties
* Has this household ever experienced [...] that cause financial difficulties 
* during the last 12 months?
	tablabs ge01_death_hh_head
	tablabs ge01_death_other 
	tablabs ge01_hh_head_hospitalization 
	tablabs ge01_hh_other_hospitalization
	tablabs ge01_loss 
	tablabs ge01_production_loss 
	tablabs ge01_income_loss 
	tablabs ge01_other

	gen 	soc_diff = 0
	replace soc_diff = 1 if ge01_death_hh_head == 1 | ge01_death_other == 1 | ///
							ge01_hh_head_hospitalization == 1 | ///
							ge01_hh_other_hospitalization == 1
	lab define diff_labs 1 "With difficulties" 0 "Without difficulties"
	lab values soc_diff diff_labs
	
	gen 	eco_diff = 0
	replace eco_diff = 1 if ge01_loss == 1 | ge01_production_loss == 1 | ///
							ge01_income_loss == 1
			// ge01_loss: Losses due to fire, earthquake or other disasters
			// ge01_production_loss: production slowdown/harvest failure/business loss 
			// ge01_income_loss: Reduction in household income due to job loss (wage worker)
	lab values eco_diff diff_labs
	
	gen 	both_diff = 0
	replace both_diff = 1 if soc_diff == 1 & eco_diff == 1
	lab 	values both_diff diff_labs
	
	tablabs soc_diff eco_diff
	ta soc_diff sex
	ta eco_diff sex
	ta both_diff sex

	* Production loss
	replace production_loss_text = "." if production_loss_text == "N/A" | ///
										  production_loss_text == "NA"   
	tablabs production_loss_text

	
	*****
	* PENDING: COVID-19, REMITANCES, WEALTH, YOUSAVE, INCOME LOSS

	ta ge03_income_loss sex
	ta ar15 sex
********************************************************************************
**# COVID-19
	ta sec_ge_t 
	ta sec_ge_u
	
********************************************************************************
**# Receive help from the government
	tab yousave_sf
	tablabs yousave_sf
	
* Wealth index (PCA)
	pca hr05a_radio hr31_tv hr05a_phone hr05a_landline hr05a_refrigerator hr05a_bicycle hr05a_row hr05a_motorcycle hr05a_car hr05a_motorboat hr02_customary_land hr02_alienated_land, components(1)
	predict wealth_pca, score
	ta wealth_pca, m
	
	egen minpca = min(wealth_pca)
	gen wealth = wealth_pca + (minpca*-1)
	
	xtile quintile = wealth, nq(5)
	ta province quintile 
	bys sex: ta province quintile 
	bys sex: ta quintile 