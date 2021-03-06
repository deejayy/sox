{$O-}
{ VERSION 0.38, last modify: 2002/10/19 }
{ VERSION 0.39, last modify: 2003/03/17 }
{ VERSION 0.45, last modify: 2003/03/19 }
{ VERSION 0.56, last modify: 2004/03/26 }
{ VERSION 0.72, last modify: 2004/03/30 }
unit sox;

interface

const

  recvbufsize   = 1024*16;

procedure f_error( str: string );
procedure delay( ms: longword );

function  initwsa: longint;
function  createsocket: longint;
function  connect( socket: longint; host: string; port: integer ): longint; overload;
function  connect( socket: longint; host: longint; port: integer ): longint; overload;
function  listen( socket, port: longint ): longint;
function  accept( socket: longint ): longint;

function  sendstr( socket: longint; s: string ): longint;
function  sendbuf( socket: longint; buf: pointer; size: longint ): longint;

function  receivestr( socket: longint; var s: string ): longint;
function  receivebuf( socket: longint; buf: pointer ): longint;

procedure disconnect( socket: longint );
function  closewsa: longint;

implementation

uses winsock, windows;

procedure f_error( str: string );
  begin
    messagebox( 0, pchar( str ), 'error', 0 );
    closewsa;
    exitprocess( 1 );
  end;

procedure delay( ms: longword );
  var

     firsttickcount: longword;

  begin

    firsttickcount := GetTickCount;
    repeat
    until gettickcount - firsttickcount >= ms;

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


function  listen( socket, port: longint ): longint;
  var
    sin: sockaddr_in;
  begin
    sin.sin_family := 2;
    sin.sin_port := htons( port );
    sin.sin_addr.s_addr := $0100007F;

    result := winsock.bind( socket, sin, sizeof(sin) );
    if result = 0 then winsock.listen( socket, 0 );
  end;


function  accept( socket: longint ): longint;
 begin
   result := winsock.accept( socket, nil, nil );
 end;
  
function sendstr( socket: longint; s: string ): longint;
  begin
    result := send( socket, s[1], length( s ), 0 );
  end;

function  sendbuf( socket: longint; buf: pointer; size: longint ): longint;
  begin
    result := send( socket, buf^, size, 0 );
  end;

function  receivestr( socket: longint; var s: string ): longint;
  var

    ch: char;
    e : integer;
    k : string;

  begin
    k := '';
    repeat
      recv( socket, ch, 1, 0 );
      if ch <> #$0A then k := k + ch;
    until (ch = #$0A);
    result := length( k );
    s := k;
  end;

function  receivebuf( socket: longint; buf: pointer ): longint;
  var

    tmp: array of byte;
  begin
    setlength( tmp, recvbufsize );
    result := recv( socket, tmp, recvbufsize, 0 );
    move( tmp, buf, result );
  end;

procedure disconnect( socket: longint );
  begin
    winsock.shutdown( socket, 0 );
    winsock.shutdown( socket, 1 );
    winsock.closesocket( socket );
  end;

function closewsa: longint;
  begin
    result := WSACleanup;
  end;

end.