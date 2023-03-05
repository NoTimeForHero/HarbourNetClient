
#define WM_COPYDATA           74
#define CDM_RUNCMD         52888 // 0xCE98
#define WM_DROPFILES         563 // 0x0233

//------------------------------------------------------------------------------*
Function MyEvents ( hWnd, nMsg, wParam, lParam )
   //------------------------------------------------------------------------------*
   Local nCargo, cCmd

   do case
      case nMsg == WM_COPYDATA
         cCmd := GetMessageData( lParam, @nCargo )
         OnWmCopyData(cCmd)
      //otherwise
      //   Events ( hWnd, nMsg, wParam, lParam )
   endcase

Return Events ( hWnd, nMsg, wParam, lParam )



#pragma BEGINDUMP

#include <mgdefs.h>
#include <hbapi.h>
#include <shlobj.h>
#include <time.h>
#include <windows.h>
#include "hbwinuni.h"

#ifndef __XHARBOUR__
   #define ISBYREF( n )          HB_ISBYREF( n )
#endif

HB_FUNC( TERMINATEPROCESS ) {
  hb_retni( (BOOL) TerminateProcess( (HANDLE) hb_parni(1),0) );
}

HB_FUNC( UNIXTIME ) {
    hb_retnl(time(NULL));
}


HB_FUNC( SENDMESSAGEDATA )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )  
   {
      COPYDATASTRUCT cds;

      cds.dwData = ( ULONG_PTR ) hb_parni( 3 ) ;
      cds.cbData = hb_parclen( 2 );
      cds.lpData = ( char * ) hb_parc( 2 );      

      SendMessage( hwnd, WM_COPYDATA, 0, ( LPARAM ) &cds );
   }
}

HB_FUNC(TESTWINDOW)
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );
   hb_retnl(IsWindow(hwnd));
}


HB_FUNC( GETMESSAGEDATA )
{
   PCOPYDATASTRUCT pcds = ( PCOPYDATASTRUCT ) HB_PARNL( 1 );

   hb_retc_null();

   if( pcds )
   {
      if( pcds->lpData )
      {
         hb_retclen(  pcds->lpData, pcds->cbData );
      }

      if( HB_ISBYREF( 2 ) )
      {
         hb_stornl( pcds->dwData, 2 );
      }
   }
}

HB_FUNC ( FINDWINDOW )
{
	hb_retnl( ( LONG ) FindWindow( 0, hb_parc( 1 ) ) );
}

#pragma ENDDUMP
