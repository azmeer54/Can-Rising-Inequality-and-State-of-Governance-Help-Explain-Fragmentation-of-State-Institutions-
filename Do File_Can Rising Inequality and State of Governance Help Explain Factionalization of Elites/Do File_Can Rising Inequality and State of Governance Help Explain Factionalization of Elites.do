log using "C:\Users\ASUS\Desktop\Elite Power Paper\Elite_Power.smcl", replace


//Importing the dataset for analysis
import excel "C:\Users\ASUS\Desktop\Elite Power Paper\Final Cleaned Data\Cleaned Data.xlsx", sheet("Sheet1") firstrow

//installing xtserial package for testing serial correlation
//net install st0039.pkg
//installing xttset3 for testing heteroskedasticity
//findit xtest3
//ssc install xttest3

//setting Matrix Size
set matsize 4000

//encoding variables for analysis
encode WBCountry, gen(Country)
encode WBIncomegroup, gen(IncomeGroup)
encode WBRegion , gen(Region)

//renaming Year Variable
rename WBYear Year 

//Declaring Panel Dataset
xtset Country Year, yearly


//Dropping unimportant variables
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drop WBCountry WBIncomegroup WBRegion PPICountry PPIYear FIWYear
drop FSICountry FSIYear FSIRank FSITotal FIWCountry FIWRegion FIWEdition FIWStatus 

//renaming the variables in the model 
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rename FSIC2FactionalizedElites FactionalizedElite
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



//Creating Lagged Variables
sort Country Year
by Country: gen L1FactionalizedElite =L1.FactionalizedElite
by Country: gen L2FactionalizedElite =L2.FactionalizedElite
by Country: gen L1EconInequality =L1.EconInequality
by Country: gen L2EconInequality =L2.EconInequality
by Country: gen L1GenderEqual=L1.GenderEqual
by Country: gen L2GenderEqual=L2.GenderEqual
by Country: gen L1EqualOpp =L1.EqualOpp
by Country: gen L2EqualOpp =L2.EqualOpp
by Country: gen L1LawSupportEqual =L1.LawSupportEqual
by Country: gen L2LawSupportEqual =L2.LawSupportEqual
by Country: gen L1ExcluSocioEcon =L1.ExcluSocioEcon
by Country: gen L2ExcluSocioEcon =L2.ExcluSocioEcon
by Country: gen L1GroupGrievance =L1.GroupGrievance
by Country: gen L2GroupGrievance =L2.GroupGrievance
by Country: gen L1ElectProcess =L1.ElectProcess
by Country: gen L2ElectProcess =L2.ElectProcess
by Country: gen L1GovEffective =L1.GovEffective
by Country: gen L2GovEffective =L2.GovEffective
by Country: gen L1RuleofLaw =L1.RuleofLaw
by Country: gen L2RuleofLaw =L2.RuleofLaw
by Country: gen L1StatePopRel =L1.StatePopRel
by Country: gen L2StatePopRel =L2.StatePopRel
by Country: gen L1PubServ =L1.PubServ
by Country: gen L2PubServ =L2.PubServ
by Country: gen L1AccesstoPubServ =L1.AccesstoPubServ
by Country: gen L2AccesstoPubServ =L2.AccesstoPubServ


//summary table of all the variables in the model 
sum FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ
outreg2 using summary_table.tex, replace sum(log) keep(FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ)



//Inequality model buidling
//%%%%%%%%%%%%%%%%%%%%%%%%%
//Checking for Serial Correlation
xtserial FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance
//Decision: Serial Correlation Present 

//fixed effect model
xtreg FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance, fe
estimates store n1, title(Inequality FE Model)
//checking for Heteroskedasticity
xttest3 //Decision: Heteroskedasticity Present
//Checking for Contemporaneous Cross-sectional Correlation
xtcsd, pesaran abs //Decision: No Cross Sectional Dependence (Correlation)

//random effect model
xtreg FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance, re
estimates store n2, title(Inequality RE Model)

//pooled model
reg FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance
estimates store n3, title(Inequality Pooled Model)


//Governance model building
//%%%%%%%%%%%%%%%%%%%%%%%%%
//fixed effect model
xtreg FactionalizedElite ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ, fe
estimates store g1, title(Governance FE Model)
//checking for Heteroskedasticity
xttest3 //Decision: Heteroskedasticity Present
//Checking for Contemporaneous Cross-sectional Correlation
xtcsd, pesaran abs //Decision: There is Cross Sectional Dependence (Correlation) 

//random effect model
xtreg FactionalizedElite ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ, re
estimates store g2, title(Governance RE Model)

//pooled model
reg FactionalizedElite ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ
estimates store g3, title(Governance Pooled Model)

//Checking for Serial Correlation
xtserial FactionalizedElite ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ
//Decision: Serial Correlation Present 

esttab n1 n2 n3 g1 g2 g3, se r2 ar2 mtitles

//Exporting the Static Panel Regression Table into LaTeX format
esttab n1 n2 n3 g1 g2 g3 using "Initial_Static_panel.tex", se r2 ar2 mtitles replace


//Final Model Building
//%%%%%%%%%%%%%%%%%%%%
//fixed effect model
xtreg FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ, fe
estimates store f1, title(Overall FE Model)
//checking for Heteroskedasticity
xttest3 //Decision: Heteroskedasticity Present 
//checking for multicollinearity
estat vce, corr //Decision: No major multicollinearity issue.
//Checking for Contemporaneous Cross-sectional Correlation
xtcsd, pesaran abs //Decision: There is Cross Sectional Dependence (Correlation)

//random effect model
xtreg FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ, re
estimates store f2, title(Overall RE Model)

//pooled model
reg FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ
estimates store f3, title(Overall Pooled Model)

//Checking for Serial Correlation
xtserial FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ
//Decision: Serial Correlation Present 

//The Table for Static Panel Data Regression Results
esttab f1 f2 f3 a1, se r2 ar2 mtitles

//Exporting the Static Panel Regression Table into LaTeX format
esttab f1 f2 f3 a1 using "Initial_Second_Static_panel.tex", se r2 ar2 mtitles replace


//Final Decision on these models
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//The Panel Data Models are Heteroskedastic, Serially Correlated and Contemporaneously Cross-sectionally Correlated. 
//Decicion: Use Linear regression with panel-corrected standard errors

//Linear regression with panel-corrected standard errors 
xtpcse FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ, correlation(psar1) rhotype(tscorr)
estimates store a1, title(Panel-corrected SE Model)

//The Final Table for Static Panel Regression Analysis
esttab n1 n2 n3 g1 g2 g3 f1 f2 f3 a1, se r2 ar2 mtitles

//Exporting the Static Panel Regression Table into LaTeX format
esttab n1 n2 n3 g1 g2 g3 f1 f2 f3 a1 using "Static_panel.tex", se r2 ar2 mtitles replace


//Fixed vs Random vs Pooled
//%%%%%%%%%%%%%%%%%%%%%%%%%%%
//Fixed vs Random: Hausman Test
hausman n1 n2 //Decision: Choose FE
hausman g1 g2 //Decision: Choose FE
hausman f1 f2 //Decision: Choose FE
//Random vs Pooled: Breusch-Pagan LM Test
xtreg FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance, re
xttest0 //Decision: We reject null; RE is appropriate
xtreg FactionalizedElite ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ, re
xttest0 //Decision: We reject null; RE is appropriate
xtreg FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ, re
xttest0 //Decision: We reject null; RE is appropriate

//Testing for Time Fixed Effects
xtreg FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year, fe
testparm i.Year //Decision: Time FIxed Effects are not Needed in FE Model 
xtreg FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year, re
testparm i.Year //Decision: Time FIxed Effects are Needed in RE Model 
reg FactionalizedElite EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year
testparm i.Year //Decision: Time FIxed Effects are not Needed in Pooled Model 
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Decision: FE is better than RE or Pooled

//checking for model misspecification in the panel
hausman f1, sigmamore
//Decision: Final FE Model is not correctly spcified

//For better specification of dynamic panel model, FE model residuals being heteroskedastic and serially correlated
//We take resort to 2-step Difference GMM Estimation Method
//Pooled Estimation for the Dynamic Panel Model
reg FactionalizedElite L1FactionalizedElite L2FactionalizedElite EconInequality L1EconInequality L2EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess L1ElectProcess L2ElectProcess GovEffective RuleofLaw L1RuleofLaw L2RuleofLaw StatePopRel L1StatePopRel L2StatePopRel PubServ AccesstoPubServ i.Year
estimates store d1, title(Pooled Estimation for Dynamic Panel Model)
//FE Estimation for the Dynamic Panel Model
xtreg FactionalizedElite L1FactionalizedElite L2FactionalizedElite EconInequality L1EconInequality L2EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess L1ElectProcess L2ElectProcess GovEffective RuleofLaw L1RuleofLaw L2RuleofLaw StatePopRel L1StatePopRel L2StatePopRel PubServ AccesstoPubServ i.Year, fe
estimates store d2, title(FE Estimation for Dynamic Panel Model)
//Two Step Difference GMM
xtabond2 FactionalizedElite L1FactionalizedElite L2FactionalizedElite EconInequality L1EconInequality L2EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess L1ElectProcess L2ElectProcess GovEffective RuleofLaw L1RuleofLaw L2RuleofLaw StatePopRel L1StatePopRel L2StatePopRel PubServ AccesstoPubServ i.Year, gmm(L1FactionalizedElite) iv(L1EconInequality L2EconInequality L1GenderEqual L2GenderEqual L1EqualOpp L2EqualOpp L1LawSupportEqual L2LawSupportEqual L1ExcluSocioEcon L2ExcluSocioEcon L1GroupGrievance L2GroupGrievance L1ElectProcess L2ElectProcess L1GovEffective L2GovEffective L1RuleofLaw L2RuleofLaw L1StatePopRel L2StatePopRel L1PubServ L2PubServ L1AccesstoPubServ L2AccesstoPubServ EconInequality GenderEqual EqualOpp LawSupportEqual ExcluSocioEcon GroupGrievance ElectProcess GovEffective RuleofLaw StatePopRel PubServ AccesstoPubServ i.Year) noleveleq twostep nodiffsargan
estimates store d3, title(2-Step Difference GMM Estimation for Dynamic Panel Model)

//The Table for Dynamic Panel Data Regression Results
esttab d1 d2 d3, se r2 ar2 mtitles

//Exporting the Dynamic Panel Data Regression Results Table into LaTeX format
esttab d1 d2 d3  using "Dynamic_panel.tex", se r2 ar2 mtitles replace 

//Thank you so much for going through the code. 

log close
translate "C:\Users\ASUS\Desktop\Elite Power Paper\Elite_Power.smcl" "C:\Users\ASUS\Desktop\Elite Power Paper\Elite_Power_Stata_Log.pdf", replace
