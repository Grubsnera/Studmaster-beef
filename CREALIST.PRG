clear
delete file stdlist.tdb
use stdfiel.tdb
pack
sort on fldlist to stdlist.sor
use stdlist.sor
delete for fldlist <= 0
pack

append blank
replace fldbesk with "Algemene inligting"
replace flddesc with "General information"
replace fldlist with 998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldlist with 999

append blank
replace fldlist with 1497
append blank
replace fldbesk with "Stamboom inligting"
replace flddesc with "Pedigree information"
replace fldlist with 1498
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldlist with 1499

append blank
replace fldlist with 1997
append blank
replace fldbesk with "Ander inligting"
replace flddesc with "Other information"
replace fldlist with 1998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldlist with 1999

append blank
replace fldlist with 2997
append blank
replace fldbesk with "Nageslag inligting"
replace flddesc with "Progeny information"
replace fldlist with 2998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldlist with 2999

append blank
replace fldlist with 3997
append blank
replace fldbesk with "Fase A & B inligting"
replace flddesc with "Phase A & B information"
replace fldlist with 3998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldlist with 3999

append blank
replace fldlist with 4997
append blank
replace fldbesk with "Fase C & D inligting"
replace flddesc with "Phase C & D information"
replace fldlist with 4998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldlist with 4999

append blank
replace fldlist with 5997
append blank
replace fldbesk with "Liggaamsmates"
replace flddesc with "Body measurements"
replace fldlist with 5998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldlist with 5999

append blank
replace fldlist with 6997
append blank
replace fldbesk with "Verkope"
replace flddesc with "Sales"
replace fldlist with 6998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldlist with 6999

append blank
replace fldlist with 7997
append blank
replace fldbesk with "Teelwaardes"
replace flddesc with "Breeding values"
replace fldlist with 7998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldlist with 7999

append blank
replace fldlist with 8997
append blank
replace fldbesk with "Aankope"
replace flddesc with "Purchases"
replace fldlist with 8998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldlist with 8999

index on fldlist to stdlist
copy to stdlist.tdb fields dbfname,fldbesk,flddesc,fldname,fldtype,fldleng,flddeci,fldlist
use
delete file stdlist.sor
delete file stdlist.ndx
delete file stdlist.idx
clear
quit
