clear
delete file stdveld.tdb
use stdfiel.tdb
pack
sort on fldsort to stdveld.sor
use stdveld.sor
delete for fldsort <= 0
pack

append blank
replace fldbesk with "Algemene inligting"
replace flddesc with "General information"
replace fldsort with 998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldsort with 999

append blank
replace fldsort with 1997
append blank
replace fldbesk with "Ander inligting"
replace flddesc with "Other information"
replace fldsort with 1998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldsort with 1999

append blank
replace fldsort with 2997
append blank
replace fldbesk with "Nageslag inligting"
replace flddesc with "Progeny information"
replace fldsort with 2998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldsort with 2999

append blank
replace fldsort with 3997
append blank
replace fldbesk with "Fase A & B inligting"
replace flddesc with "Phase A & B information"
replace fldsort with 3998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldsort with 3999

append blank
replace fldsort with 4997
append blank
replace fldbesk with "Fase C & D inligting"
replace flddesc with "Phase C & D information"
replace fldsort with 4998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldsort with 4999

append blank
replace fldsort with 5997
append blank
replace fldbesk with "Liggaamsmates"
replace flddesc with "Body measurements"
replace fldsort with 5998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldsort with 5999

append blank
replace fldsort with 7997
append blank
replace fldbesk with "Teelwaardes"
replace flddesc with "Breeding values"
replace fldsort with 7998
append blank
replace fldbesk with "--------------------"
replace flddesc with "--------------------"
replace fldsort with 7999

index on fldsort to stdveld
copy to stdveld.tdb fields dbfname,fldbesk,flddesc,fldname,fldtype,fldleng,flddeci,fldsort
use
delete file stdveld.sor
delete file stdveld.ndx
delete file stdveld.idx
clear
quit
