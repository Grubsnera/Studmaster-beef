use sm3data
do while !eof()
   cls
   @5, 5 say recno()
   if SM3DATA->oogpig > 0 .and. SM3DATA->oogpig < 100 .and. SM3DATA->eyepig = ""
      SM3DATA->eyepig = alltrim(str(SM3DATA->oogpig))
   endif
   skip
enddo
use
quit
