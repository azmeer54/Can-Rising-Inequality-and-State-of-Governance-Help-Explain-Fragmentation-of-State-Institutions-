set more off
clear all 

// Importing the Dataset 
use "https://github.com/azmeer54/Can-Rising-Inequality-and-State-of-Governance-Help-Explain-Fragmentation-of-State-Institutions-/blob/main/factionalized_institutes_data.dta?raw=true"

//Starting Texdoc 
texdoc init "ElitePowerPaper.tex", force cmdstrip nooutput replace

//setting Matrix Size
set matsize 10000

//encoding variables for analysis
encode WBCountry, gen(Country)
encode WBIncomegroup, gen(IncomeGroup) //Four IncomeGroup
encode WBRegion , gen(Region) //Don't do regional analysis, it has low number of obs
encode FIWStatus, gen(FreedomStatus) //Three FreedomStatus

//renaming Year Variable
rename WBYear Year 

//Declaring Panel Dataset
xtset Country Year, yearly

//Creating Lagged Variables
sort Country Year
by Country: gen L1FSIC2FactionalizedElites = L1.FSIC2FactionalizedElites


//renaming the variables in the model 
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rename FSIC2FactionalizedElites FactionalizedElite
rename L1FSIC2FactionalizedElites L1FactionalizedElite
rename FSIE2EconomicInequality EconInequality
rename PPIAROExclusionbysocioecon ExcluSocioEcon
rename PPIEDREqualityofopportunity EqualOpp 
rename FSIC3GroupGrievance GroupGrievance
rename PPIAROGenderInequality GenderEqual
rename PPIGRNLawtosupportequaltr LawSupportEqual
rename FIWElectoralProcess ElectProcess
rename PPIWFGGovernmenteffectiveness GovEffective
rename FIWRuleofLaw RuleofLaw 
rename FSIP1StateLegitimacy StatePopRel
rename FSIP2PublicServices PubServ
rename PPIEDRAccesstopublicServic AccesstoPubServ
rename PPIEDRInequalityadjustedlif IneqAdjustLifeExp
rename PPIFFIIndividualsusingtheI IndUsingInternet
rename PPILowLevelsofCorruption LowLevelCorruption


//Keeping important variables
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
keep FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ IneqAdjustLifeExp IndUsingInternet LowLevelCorruption Year Region Country FreedomStatus IncomeGroup 

by Country: gen FactionalizedElite2= FactionalizedElite*FactionalizedElite
by Country: gen L1FactionalizedElite2= L1FactionalizedElite*L1FactionalizedElite
by Country: gen EconInequality2= EconInequality*EconInequality
by Country: gen GenderEqual2= GenderEqual*GenderEqual
by Country: gen EqualOpp2= EqualOpp*EqualOpp
by Country: gen LawSupportEqual2= LawSupportEqual*LawSupportEqual
by Country: gen ExcluSocioEcon2= ExcluSocioEcon*ExcluSocioEcon
by Country: gen GroupGrievance2= GroupGrievance*GroupGrievance
by Country: gen ElectProcess2= ElectProcess*ElectProcess
by Country: gen GovEffective2= GovEffective*GovEffective
by Country: gen RuleofLaw2= RuleofLaw*RuleofLaw
by Country: gen StatePopRel2= StatePopRel*StatePopRel
by Country: gen PubServ2= PubServ*PubServ
by Country: gen AccesstoPubServ2= AccesstoPubServ*AccesstoPubServ
by Country: gen LowLevelCorruption2= LowLevelCorruption*LowLevelCorruption
by Country: gen IneqAdjustLifeExp2= IneqAdjustLifeExp*IneqAdjustLifeExp
by Country: gen IndUsingInternet2= IndUsingInternet*IndUsingInternet 


//summary table of all the variables in the model 
xtsum FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ
outreg2 using summarytable.tex, replace sum(log) keep(FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ)


//Global Panel
xtabond2 FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year i.Region, gmm(L1FactionalizedElite) iv(GenderEqual AccesstoPubServ i.Year) twostep nodiffsargan robust
estimates store m1, title(Global) 

margins 
margins Region
margins Region#Year
margins, dydx(*)
margins, eyex(L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ)

reg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year i.Region, robust
estimates store m1r, title(Global OLS)

xtreg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year i.Region, fe robust
estimates store m1fe, title(Global FE)

//Income Group Decomposition
// High Income Panel 
xtabond2 FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if IncomeGroup==1, gmm(L1FactionalizedElite) iv(GenderEqual AccesstoPubServ GroupGrievance ExcluSocioEcon  i.Year) twostep nodiffsargan robust
estimates store i1, title(High Income)

reg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if IncomeGroup==1,  robust
estimates store i1r, title(High Income OLS)

xtreg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if IncomeGroup==1,  robust
estimates store i1fe, title(High Income FE)

//Low Income Panel
xtabond2 FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if IncomeGroup==2, gmm(L1FactionalizedElite) iv(GenderEqual AccesstoPubServ GroupGrievance GovEffective) twostep nodiffsargan robust
estimates store i2, title(Low Income)

reg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if IncomeGroup==2, robust
estimates store i2r, title(Low Income OLS)

xtreg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if IncomeGroup==2, fe robust
estimates store i2fe, title(Low Income FE)

//Lower Middle Income Panel
xtabond2 FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if IncomeGroup==3, gmm(L1FactionalizedElite) iv(GenderEqual GroupGrievance EconInequality) twostep nodiffsargan robust
estimates store i3, title(Lower Middle Income)

reg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if IncomeGroup==3,  robust
estimates store i3r, title(Lower Middle Income OLS)

xtreg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if IncomeGroup==3, fe robust
estimates store i3fe, title(Lower Middle Income FE)

//Upper Middle Income Panel
xtabond2 FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if IncomeGroup==4, gmm(L1FactionalizedElite) iv(GroupGrievance ElectProcess i.Year) twostep nodiffsargan robust
estimates store i4, title(Upper Middle Income)

reg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if IncomeGroup==4,  robust
estimates store i4r, title(Upper Middle Income OLS)

xtreg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if IncomeGroup==4, fe robust
estimates store i4fe, title(Upper Middle Income FE)

//Freedom Status Decompsotion
//Free Panel
xtabond2 FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==1, gmm(L1FactionalizedElite) iv(IneqAdjustLifeExp  LowLevelCorruption LowLevelCorruption2 L1FactionalizedElite2  IneqAdjustLifeExp2 EconInequality StatePopRel) twostep nodiffsargan robust
estimates store f1, title(Free)

reg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==1,  robust
estimates store f1r, title(Free OLS)

xtreg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==1, fe robust
estimates store f1fe, title(Free FE)

//Not Free Panel 
xtabond2 FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==2, gmm(L1FactionalizedElite) iv(i.Region  IndUsingInternet EconInequality EqualOpp LowLevelCorruption2 L1FactionalizedElite2 GovEffective RuleofLaw) twostep nodiffsargan robust
estimates store f2, title(Not Free) 

reg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==2, robust
estimates store f2r, title(Not Free OLS) 

xtreg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==2, fe robust
estimates store f2fe, title(Not Free FE) 

//Partially Free Panel
xtabond2 FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==3, gmm(L1FactionalizedElite) iv(IndUsingInternet LowLevelCorruption2 L1FactionalizedElite2 RuleofLaw IneqAdjustLifeExp ExcluSocioEcon EqualOpp GenderEqual) twostep nodiffsargan robust
estimates store f3, title(Partially Free)

reg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==3, robust
estimates store f3r, title(Partially Free OLS)

xtreg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==3, fe robust
estimates store f3fe, title(Partially Free FE)


esttab m1 i2 i3 i4 i1 f2 f3 f1, nogaps onecell se mtitles compress longtable nonumbers nogaps title(2-Step System-GMM Estimation Results) addnotes("Yearly and regional fixed effetcs have been removed for this table." "A number of appropriate instrumental variables have been utilized including their squared terms as well as yearly and regional fixed effects.")  scalars(hansen hansen_df hansenp ar2 ar2p) order( L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ) drop(*Year *Region)

//Exporting the Dynamic Panel Regression Table into LaTeX format
esttab m1 i2 i3 i4 i1 f2 f3 f1 using "2Step_System_GMM.tex", se onecell mtitles compress longtable nonumbers nogaps title(2-Step System-GMM Estimation Results) addnotes("Yearly and regional fixed effetcs have been removed for this table." "A number of appropriate instrumental variables have been utilized including their squared terms as well as yearly and regional fixed effects.") scalars(hansen hansen_df hansenp ar2 ar2p) order( L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ) drop(*Year *Region) replace


// Exporting OLS and FE estimates of lagged independent variable 
esttab m1r m1fe i2r i2fe using "OLSFE.tex", keep(L1FactionalizedElite) mtitles compress nonumbers nogaps noobs nonotes title(OLS and Fixed Effect Lagged Variable Results) replace 


esttab i3r i3fe i4r i4fe using "OLSFE.tex", keep(L1FactionalizedElite) mtitles compress nonumbers nogaps noobs  nonotes append

esttab i1r i1fe f2r f2fe using "OLSFE.tex", keep(L1FactionalizedElite) mtitles compress nonumbers nogaps noobs nonotes append


esttab f3r f3fe f1r f1fe using "OLSFE.tex", keep(L1FactionalizedElite) mtitles compress nonumbers nogaps noobs append


//Reference 
// FreedomStatus 1==free , 2==not , 3==partial
// IncomeGroup 1==high, 2== low income, 3== lower middle , 4== upper middle income 


//Transitional Group Analysis

//Free and High Income 
xtreg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==1 & IncomeGroup==1, fe robust
estimates store t1fe, title(Free and High Income FE)

reg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==1 & IncomeGroup==1, robust
estimates store t1ols, title(Free and High Income OLS)

xtabond2 FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==1 & IncomeGroup==1, gmm(L1FactionalizedElite) iv(IndUsingInternet IneqAdjustLifeExp EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon StatePopRel PubServ i.Region) twostep nodiffsargan robust
estimates store t1, title(Free and High Income)


//Partially free and Lower Middle income
xtabond2 FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==3 & IncomeGroup==3, gmm(L1FactionalizedElite GroupGrievance) iv(LawSupportEqual RuleofLaw StatePopRel LowLevelCorruption ) twostep nodiffsargan robust
estimates store t2, title(Partially Free and Lower Middle income)

reg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==3 & IncomeGroup==3, robust
estimates store t2ols, title(Partially Free and Lower Middle income OLS)

xtreg FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year if FreedomStatus==3 & IncomeGroup==3, fe robust
estimates store t2fe, title(Partially Free and Lower Middle income FE)

esttab t1ols t1fe t2ols t2fe using "OLSFE.tex", keep(L1FactionalizedElite) mtitles compress nonumbers nogaps noobs append

esttab t1 t2 using "transitional.tex", se mtitles onecell compress longtable nonumbers nogaps title(2-Step System-GMM Estimation Results for Two Groups)  addnotes("Yearly fixed effetcs have been removed for this table." "Appropriate instrumental variables have been utilized including PCA reduced variables") scalars(hansen hansen_df hansenp ar2 ar2p) order( L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ) drop(*Year) replace

//Marginal Analysis
xtabond2 FactionalizedElite L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year i.Region, gmm(L1FactionalizedElite) iv(GenderEqual AccesstoPubServ i.Year) twostep nodiffsargan robust

texdoc stlog "margins"
margins 
texdoc stlog close 

texdoc stlog "marginsRegion"
margins Region
texdoc stlog close 

texdoc stlog "marginsRegionYear"
margins Region#Year
texdoc stlog close 

texdoc stlog "marginsMarginalEffect"
margins, dydx(*)
texdoc stlog close 

texdoc stlog "marginsElasticity"
margins, eyex(L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ)
texdoc stlog close 

// Exporting the Fixed Effects using "fixedeffects.tex" 
esttab m1 i2 i3 i4 i1 f2 f3 f1 t1 t2 using "fixedeffects.tex", nogaps onecell se mtitles compress longtable nonumbers nogaps title(2-Step System-GMM Yearly and Regional Fixed Effects)  order (*Year *Region) drop( L1FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ) replace 

texdoc close 
clear all
