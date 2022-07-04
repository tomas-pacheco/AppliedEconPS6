 /* 	Economia Aplicada 
		 Problem Set # 6
			Panel Data
			
Capriata, Giordano, Jan y Pacheco 
	Universidad de San Andrés
		   Octubre 2020	 			*/



cd "G:\Mi unidad\UdeSA\Economía Aplicada\Tutoriales\Tutorial6\Tutorial6\input"

use crime.dta, clear

* PUNTO 1 * 

*** TABLA A1 *** 

mat def B=J(8,4,.)

* Fila blocks:
qui tab blockid if barrio == "Belgrano"
mat B[1,1] = `r(r)'
qui tab blockid if barrio == "V. Crespo"
mat B[1,2] = `r(r)'
qui tab blockid if barrio == "Once"
mat B[1,3] = `r(r)'

* Como no tenemos los datos de las instituciones, los agregamos a mano:
mat B[3,1] = 7
mat B[3,2] = 13
mat B[3,3] = 17

mat B[4,1] = 2
mat B[4,2] = 1
mat B[4,3] = 5

mat B[2,1] = B[3,1] + B[4,1]
mat B[2,2] = B[3,2] + B[4,2]
mat B[2,3] = B[3,3] + B[4,3]


* Robos de auto por barrio

* Belgrano:
qui summ carthef if barrio == "Belgrano"
mat B[5,1] = `r(sum)'
qui summ carthef if barrio == "Belgrano" & ( month == 4 | month == 5 | month == 6 | month == 72)
mat B[6,1] = `r(sum)'
qui summ carthef if barrio == "Belgrano" & ( month == 73)
mat B[7,1] = `r(sum)'
qui summ carthef if barrio == "Belgrano" & ( month == 8 | month == 9 | month == 10 | month == 11 | month == 12)
mat B[8,1] = `r(sum)'


* Villa Crespo:
qui summ carthef if barrio == "V. Crespo"
mat B[5,2] = `r(sum)'
qui summ carthef if barrio == "V. Crespo" & ( month == 4 | month == 5 | month == 6 | month == 72)
mat B[6,2] = `r(sum)'
qui summ carthef if barrio == "V. Crespo" & ( month == 73)
mat B[7,2] = `r(sum)'
qui summ carthef if barrio == "V. Crespo" & ( month == 8 | month == 9 | month == 10 | month == 11 | month == 12)
mat B[8,2] = `r(sum)'

* Once: 
qui summ carthef if barrio == "Once"
mat B[5,3] = `r(sum)'
qui summ carthef if barrio == "Once" & ( month == 4 | month == 5 | month == 6 | month == 72)
mat B[6,3] = `r(sum)'
qui summ carthef if barrio == "Once" & ( month == 73)
mat B[7,3] = `r(sum)'
qui summ carthef if barrio == "Once" & ( month == 8 | month == 9 | month == 10 | month == 11 | month == 12)
mat B[8,3] = `r(sum)'

* Columna de Totales:
forvalues j = 1(1)8{
mat B[`j',4] = B[`j',1] + B[`j',2] + B[`j',3] 
}

*Exportamos la tabla:
frmttable using TableA1, statmat(B) sdec(0,0,0,0) rtitle("Blocks" \ "Institutions" \ "   Inside" \ "   Boundaries" \ "Car thefts" \ "   April 1 - July 17" \ "   July 18 - July 31"\ "   August 1 - December 31") ctitle(" ", "Belgrano", "Villa", "Once" "Total"\ " " ," " , "Crespo") tex frag replace


 
*** TABLA 2 ***

use crime.dta, clear

* Generamos variables para hacer las diferencias de medias:
gen colE = 1 if inst == 1
replace colE = 2 if dist > 2
gen colF = 1 if dist == 1
replace colF = 2 if dist > 2
gen colG = 1 if dist == 2
replace colG = 2 if dist > 2

* Cambiamos los nombres de los meses para que nos queden en orden:
replace month = month + 1 if (month >= 8 & month<=12 )
drop if month == 7
replace month = 7 if month == 72
replace month = 8 if month == 73

* Loop:
mat def A=J(11,14,.)
local z = 1
forvalues k = 4(1)13 {
qui summ carthef if (month == `k' & dist > 2)
mat A[`z', 1] = `r(mean)'
mat A[`z', 2] = `r(sd)'
qui summ carthef if (month == `k' & inst == 1)
mat A[`z', 3] = `r(mean)'
mat A[`z', 4] = `r(sd)'
qui summ carthef if (month == `k' & dist == 1)
mat A[`z', 5] = `r(mean)'
mat A[`z', 6] = `r(sd)'
qui summ carthef if (month == `k' & dist == 2)
mat A[`z', 7] = `r(mean)'
mat A[`z', 8] = `r(sd)'
qui ttest cartheft if month == `k', by(colE) unequal
mat A[`z', 9] = `r(mu_2)' - `r(mu_1)'
mat A[`z', 10]= `r(se)'
qui ttest cartheft if month == `k', by(colF) unequal
mat A[`z', 11] = `r(mu_2)' - `r(mu_1)'
mat A[`z', 12]= `r(se)'
qui ttest cartheft if month == `k', by(colG) unequal
mat A[`z', 13] = `r(mu_2)' - `r(mu_1)'
mat A[`z', 14]= `r(se)'
local z = `z' + 1
}

* Insertamos los numeros de blocks:
qui tab blockid if dist > 2
mat A[11,1] = `r(r)'
qui tab blockid if inst == 1
mat A[11,3] = `r(r)'
qui tab blockid if dist == 1
mat A[11,5] = `r(r)'
qui tab blockid if dist == 2
mat A[11,7] = `r(r)'


* Volvemos a los nombres originales de los meses:
replace month = 73 if month == 8
replace month = 72 if month == 7
replace month = month - 1 if (month >=9  & month<=13 )


* Exportamos la tabla:
frmttable using Table2, statmat(A) substat(1) sdec(4,4,4,4,4,4) rtitle( "April" \ " "\ "May" \ " " \ "June" \ " " \ "July (1-17)" \ " " \ "July (18-31)" \ " "\  "August" \ " " \ "September" \ " "\ "October" \ " "\ "November" \ " " \ "December" \ " " \ "Number of blocks") ctitle(" ", "More than two ", " ", "One block", "Two blocks ", " ", " ", " "\ " " , "blocks from", " Jewish", "from nearest", "from nearest ", " ", " ", " "\ " ", "nearest Jewish ", "institution on", "Jewish ", "Jewish", "Difference ", "Difference ", "Difference "\ " ", "institution", "the block ", "institution ", "institution ", "(E) =", "(F) =  ", "(G) = "\  "Month ", "(A) ", " (B)", "(C) ", "(D) ", "(B) - (A) ", "(C) - (A) ", "(D) - (A) ") tex frag replace


*** Monthly version of Figure 2
use crime.dta, clear

drop if month == 7

* Generamos variables que vamos a utilizar: 
gen inst2 = 1 if dist == 2
replace inst2 = 0 if inst2 ==. 
gen instm2 = 1 if dist >2
replace instm2 = 0 if instm2 ==.

* Hacemos el collapse:
collapse (sum) cartheft, by(inst inst1 inst2 instm2 month)

* Generamos una variable de fecha:
gen fecha = "01apr1994" if month == 4
replace fecha = "01may1994" if month == 5
replace fecha = "01jun1994" if month == 6
replace fecha = "17jul1994" if month == 72
replace fecha = "31jul1994" if month == 73
replace fecha = "01aug1994" if month == 8
replace fecha = "01sep1994" if month == 9
replace fecha = "01oct1994" if month == 10
replace fecha = "01nov1994" if month == 11
replace fecha = "01dec1994" if month == 12

* Le damos formato:
gen fecha2 = daily(fecha, "DMY")
format fecha2 %td
drop fecha

* Generamos una variable que toma valor 1 antes del atentado y valor 0 luego del 31 de agosto:
sort fecha2
gen aten = 0 if fecha2<=fecha2[16]
replace aten = 1 if fecha2>=fecha2[20]

* Generamos variables con las medias:
foreach var of varlist inst inst1 inst2 instm2{
bysort aten: egen m`var' = mean(carthef) if `var' == 1
}

* Ordenamos:
sort inst fecha2

* Graficamos:
#delimit;
twoway 
line (cartheft fecha2) if (inst == 1), lcolor(black) lwidth(medthick) yaxis(1) || 

line (carthef fecha2) if (inst1== 1),lcolor(black) lwidth(medthin) yaxis(1)||

line (carthef fecha2) if (inst2== 1), lcolor(black)lpattern(dash_dot) yaxis(1)||

line (carthef fecha2) if (instm2== 1), lcolor(black)lpattern(dot) yaxis(1)||

line (minst fecha2) if inst == 1 & aten == 0, yaxis(2) lpattern(solid ) lwidth(medthick) lcolor(erose)||

line (minst fecha2) if inst == 1 & aten == 1, yaxis(2) lpattern(solid) lcolor(erose) lwidth(medthick)||

line (minst1 fecha2) if inst1 == 1 & aten == 0, yaxis(2) lcolor(erose) lpattern(solid ) lwidth(medthin)|| 

line (minst1 fecha2) if inst1 == 1 & aten == 1, yaxis(2) lcolor(erose) 	lpattern(solid ) lwidth(medthin)||

line (minst2 fecha2) if inst2 == 1 & aten == 0, yaxis(2) lcolor(erose) lpattern(dash_dot)||

line (minst2 fecha2) if inst2 == 1 & aten == 1, yaxis(2) lcolor(erose) lpattern(dash_dot)||
 
line (minstm2 fecha2) if instm2 == 1 & aten == 0, yaxis(2) lcolor(erose) lpattern(dot)||

line (minstm2 fecha2) if instm2 == 1 & aten == 1, yaxis(2) ytitle(man) lcolor(erose) lpattern(dot) 

, tlabel(01apr1994 "April" 01may1994 "May" 01jun1994 "June" 01jul1994 "July"  01aug1994 "August" 01sep1994 "September" 01oct1994 "October" 01nov1994 "November"01dec1994 "December") ysize(6) xsize(11) tline(17jul1994 31jul1994, lcolor(black)) ytitle(" ") ysc(r(0 65))

ttext(60 16jun1994 "Terrorist Attack - July 18") ttext(60 04aug1994 "July 31", place(e)) xtitle("") title("Monthly Evolution of Car Thefts")

legend( rows(4) subtitle("By Month (Left Axis)                             Means (Right Axis)") order(1 5 2 7 3 9 4 11)
	label(1 Jewish Institution in the Block)
	label(2 One Block from Nearest Jewish Institution) 
	label(3 Two Blocks from Nearest Jewish Institution) 
	label(4 More than Two Blocks from Nearest Jewish Institution)
	label(5 Pre and Post Means for Jewish Institution in the Block)
	label(6 Pre and Post Means for Jewish Institution in the Block)
	label(7 Pre and Post Means for One Block from Nearest Jewish Institution)
	label(8 Pre and Post Means for One Block from Nearest Jewish Institution)
	label(9 Pre and Post Means for Two Blocks from Nearest Jewish Institution)
	label(10 Pre and Post Means for Two Blocks from Nearest Jewish Institution)
	label(11 Pre and Post Means for More than Two Blocks from Nearest Jewish Institution)
	label(12 Pre and Post Means for More than Two Blocks from Nearest Jewish Institution))
	legend(size(vsmall))
	
scheme(s1color)
;


* PUNTO 2

*** TABLA 3 ***
use crime.dta, clear

* Generamos variables que vamos a utilizar: 
gen inst2 = 1 if dist == 2
replace inst2 = 0 if inst2 ==. 
gen instm2 = 1 if dist >2
replace instm2 = 0 if instm2 ==.
gen inst2p = inst2 * post

* Borramos observaciones:
drop if month==73 | month == 72

* Corremos las regresiones

* Columna A
xtreg cartheft instp month*, fe i(blockid) robust 

outreg2 using table3.tex, tex(frag) bdec(3) se rdec(3) ctitle("A") keep(instp) nocons noni cttop("ja" ) addtext(Block fixed effect, Yes, Month Fixed effect, Yes) replace

* Columna B
xtreg cartheft instp inst1p month*, fe i(blockid) robust

outreg2 using table3.tex, tex(frag) bdec(3) se rdec(3) ctitle("B") keep(instp inst1p) nocons addtext(Block fixed effect, Yes, Month Fixed effect, Yes) append

* Columna C

xtreg cartheft instp inst1p inst2p month*, fe i(blockid) robust

outreg2 using table3.tex, tex(frag) bdec(3) se rdec(3) ctitle("C") keep(instp inst1p inst2p) addtext(Block fixed effect, Yes, Month Fixed effect, Yes) nocons append

* Columna D
* preserve

forvalues k = 4(1)7{
drop if month== `k'
}


tab blockid, gen (calle_)

reg cartheft instp inst1p inst2p calle_*, robust 

outreg2 using table3.tex, tex(frag) bdec(3) se rdec(3) ctitle("D") keep(instp inst1p inst2p) addtext(Block fixed effect, No, Month Fixed effect, Yes) nocons append
*restore

* Columna E

use crime.dta, clear

* Generamos variables que vamos a utilizar: 
gen inst2 = 1 if dist == 2
replace inst2 = 0 if inst2 ==. 
gen instm2 = 1 if dist >2
replace instm2 = 0 if instm2 ==.
gen inst2p = inst2 * post

* Borramos observaciones:
drop if month==73 | month == 72


gen cartheftTS=cartheft
replace cartheftTS=cartheft*(30/17) if month==7
replace cartheftTS=cartheft*(30/31) if month==5
replace cartheftTS=cartheft*(30/31) if month==8
replace cartheftTS=cartheft*(30/31) if month==10
replace cartheftTS=cartheft*(30/31) if month==12
tab blockid, gen (calle_)

reg cartheftTS instp inst1p inst2p calle_* if (inst==1 | inst1==1 | inst2==1), robust 

outreg2 using table3.tex, tex(frag) bdec(3) se rdec(3) ctitle("E") keep(instp inst1p inst2p) addtext(Block fixed effect, Yes, Month Fixed effect, No) nocons append





* PUNTO 3 * 

* TABLA 7

use crime.dta, clear

* Volvemos a crear las variables que necesitamos

gen inst2 = 1 if dist == 2
replace inst2 = 0 if inst2 ==. 
gen combi = 1 if (bank == 1) | (public == 1) | (station == 1)
replace combi = 0  if combi==.

gen inst2p = inst2 * post

drop if  month == 73 | month == 72

local j = 1
foreach var of varlist bank public station combi{
gen prim`j' = instp*(1-`var')
label var prim`j' "Same-Block Police $\times$ (1- Protection)"
gen sec`j' = instp* `var'
label var sec`j' "Same-Block Police $\times$ Protection"
gen ter`j'=inst1p*(1-`var')
label var ter`j' "One-Block Police $\times$ (1- Protection)"
gen cuar`j'=inst1p*`var'
label var cuar`j' "One-Block Police $\times$ Protection"
gen quin`j'=inst2p*(1-`var')
label var quin`j' "Two-block Police $\times$ (1- Protection)"
gen sex`j'=inst2p*`var'
label var sex`j' "Two-block Police $\times$ Protection"

rename prim`j' prim1
rename sec`j' sec1
rename ter`j' ter1
rename cuar`j' cuar1
rename quin`j' quin1
rename sex`j' sex1

areg cartheft prim1 sec1 ter1 cuar1 quin1 sex1 month5-month12, absorb(blockid) robust

outreg2 using Table7.tex, addtext(F-stat, `e(F)', Block fixed effect, Yes, Month fixed effect, Yes) tex(frag) bdec(5) se rdec(3) ctitle(`var')  drop(month*) nocons label append

drop prim1 sec1 ter1 cuar1 quin1 sex1

local j = `j' + 1
}


