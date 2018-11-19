// IDGENER.PRG
// Program to remove generation from id number
// 01-04-24 10:36

use sm3data
do while !(eof())

   // Remove blank id number
   if trim(sm3data->idnr) == "0"
      delete
   endif
   if trim(sm3data->idvaar) == "0"
      sm3data->idvaar := ""
   endif
   if trim(sm3data->idmoer) == "0"
      sm3data->idmoer := ""
   endif

   // Verander die generasie
   if sm3data->generasie == "F1"
      sm3data->generasie := "A "
   elseif sm3data->generasie == "F2"
      sm3data->generasie := "B "
   elseif sm3data->generasie == "F3"
      sm3data->generasie := "C "
   elseif sm3data->generasie == "F4"
      sm3data->generasie := "D "
   elseif sm3data->generasie == "F5"
      sm3data->generasie := "E "
   elseif trim(sm3data->generasie) $ "AzBzCzDzE"
      //
   else
      sm3data->generasie := "  "
   endif

   // Verwyder die generasie uit die kuddekenmerkletter
   cData := trim(sm3data->generasie)
   if cData == right(trim(sm3data->kuddek),1)
      sm3data->kuddek := left(sm3data->kuddek,len(trim(sm3data->kuddek))-1)
   endif

   skip

enddo
