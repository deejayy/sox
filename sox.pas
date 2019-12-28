{$O-}
{ VERSION 0.38, last modify: 2002/10/19 }
unit sox;

interface

procedure delay( ms: longword );
procedure f_error( str: string );

function  initwsa: longint;
function  createsocket: longint;
function  connect( socket: longint; host: string; port: integer ): longint; overload;
function  connect( socket: longint; host: longint; port: integer ): longint; overload;

function  sendstr( socket: longint; s: string ): longint;
function  sendbuf( socket: longint; buf: pointer; size: longint ): longint;

procedure disconnect( socket: longint );
function  closewsa: longint;

implementation

uses winsock, windows;

procedure delay( ms: longword );
  var

     firsttickcount: longword;

  begin

    firsttickcount := GetTickCount;
    repeat
    until gettickcount - firsttickcount >= ms;

  end;

procedure f_error( str: string );
  begin
    messagebox( 0, pchar( str ), 'error', 0 );
    closewsa;
    exitprocess( 1 );
  end;

function initwsa: longint;

  var

    wsadata: twsadata;

  begin
    result := WSAStartup( $0101, wsadata );
  end;


function createsocket: longint;
  begin
    result := socket( 2, 1, 0 );
  end;

function connect( socket: longint; host: string; port: integer ): longint;
  var

    he: phostent;
    sin: sockaddr_in;

  begin

    he := gethostbyname( pchar( host ) );

    sin.sin_family := 2;
    sin.sin_port := htons( port );
    asm
        mov     eax, [he]
        mov     eax, [eax+12]
        mov     eax, [eax]
        mov     eax, [eax]
        mov     sin.sin_addr.s_addr, eax
    end;

    result := winsock.connect( socket, sin, $10 );
  end;

function connect( socket: longint; host: longint; port: integer ): longint;
  var

    sin: sockaddr_in;

  begin

    sin.sin_family := 2;
    sin.sin_port := htons( port );
    sin.sin_addr.s_addr := host;
    result := winsock.connect( socket, sin, $10 );

  end;

function sendstr( socket: longint; s: string ): longint;
  begin
    result := send( socket, s[1], length( s ), 0 );
  end;

function  sendbuf( socket: longint; buf: pointer; size: longint ): longint;
  begin
    result := send( socket, buf^, size, 0 );
  end;

procedure disconnect( socket: longint );
  begin
    winsock.closesocket( socket );
  end;

function closewsa: longint;
  begin
    result := WSACleanup;
  end;

end.
