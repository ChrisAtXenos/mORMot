/// curl library direct access classes
// - this unit is a part of the freeware Synopse framework,
// licensed under a MPL/GPL/LGPL tri-license; version 1.18
unit SynCurl;

{
    This file is part of Synopse framework.

    Synopse framework. Copyright (C) 2019 Arnaud Bouchez
      Synopse Informatique - https://synopse.info

  *** BEGIN LICENSE BLOCK *****
  Version: MPL 1.1/GPL 2.0/LGPL 2.1

  The contents of this file are subject to the Mozilla Public License Version
  1.1 (the "License"); you may not use this file except in compliance with
  the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  for the specific language governing rights and limitations under the License.

  The Original Code is Synopse mORMot framework.

  The Initial Developer of the Original Code is Arnaud Bouchez.

  Portions created by the Initial Developer are Copyright (C) 2019
  the Initial Developer. All Rights Reserved.

  Contributor(s):
  - Marcos Douglas B. Santos (mdbs99)
  - Pavel Mashlyakovskii (mpv)


  Alternatively, the contents of this file may be used under the terms of
  either the GNU General Public License Version 2 or later (the "GPL"), or
  the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
  in which case the provisions of the GPL or the LGPL are applicable instead
  of those above. If you wish to allow use of your version of this file only
  under the terms of either the GPL or the LGPL, and not to allow others to
  use your version of this file under the terms of the MPL, indicate your
  decision by deleting the provisions above and replace them with the notice
  and other provisions required by the GPL or the LGPL. If you do not delete
  the provisions above, a recipient may use your version of this file under
  the terms of any one of the MPL, the GPL or the LGPL.

  ***** END LICENSE BLOCK *****

  Version 1.18
  - initial revision

}

{$I Synopse.inc} // define HASINLINE USETYPEINFO CPU32 CPU64 OWNNORMTOUPPER

interface

uses
  {$ifdef MSWINDOWS}
  Windows,
  SynWinSock,
  {$else}
  {$ifdef FPC}
  dynlibs,
  SynFPCSock,
  SynFPCLinux,
  {$endif FPC}
  {$ifdef KYLIX3}
  LibC,
  SynFPCSock,  // shared with Kylix
  SynKylix,
  {$endif KYLIX3}
  {$endif MSWINDOWS}
  SysUtils,
  Classes;

{ -------------- curl library low-level interfaces, constants and types }

const
  /// low-level libcurl library file name, depending on the running OS
  LIBCURL_DLL = {$ifdef Darwin} 'libcurl.dylib'   {$else}
                {$ifdef Linux}  'libcurl.so'      {$else}
                {$ifdef CPU64}  'libcurl-x64.dll' {$else}
                                'libcurl.dll' {$endif}{$endif}{$endif};

{$Z4}
type
  /// low-level exception raised during libcurl library access
  ECurl = class(Exception);

  /// low-level options for libcurl library API calls
  TCurlOption = (
    coPort                 = 3,
    coTimeout              = 13,
    coInFileSize           = 14,
    coLowSpeedLimit        = 19,
    coLowSpeedTime         = 20,
    coResumeFrom           = 21,
    coCRLF                 = 27,
    coSSLVersion           = 32,
    coTimeCondition        = 33,
    coTimeValue            = 34,
    coVerbose              = 41,
    coHeader               = 42,
    coNoProgress           = 43,
    coNoBody               = 44,
    coFailOnError          = 45,
    coUpload               = 46,
    coPost                 = 47,
    coFTPListOnly          = 48,
    coFTPAppend            = 50,
    coNetRC                = 51,
    coFollowLocation       = 52,
    coTransferText         = 53,
    coPut                  = 54,
    coAutoReferer          = 58,
    coProxyPort            = 59,
    coPostFieldSize        = 60,
    coHTTPProxyTunnel      = 61,
    coSSLVerifyPeer        = 64,
    coMaxRedirs            = 68,
    coFileTime             = 69,
    coMaxConnects          = 71,
    coClosePolicy          = 72,
    coFreshConnect         = 74,
    coForbidResue          = 75,
    coConnectTimeout       = 78,
    coHTTPGet              = 80,
    coSSLVerifyHost        = 81,
    coHTTPVersion          = 84,
    coFTPUseEPSV           = 85,
    coSSLEngineDefault     = 90,
    coDNSUseGlobalCache    = 91,
    coDNSCacheTimeout      = 92,
    coCookieSession        = 96,
    coBufferSize           = 98,
    coNoSignal             = 99,
    coProxyType            = 101,
    coUnrestrictedAuth     = 105,
    coFTPUseEPRT           = 106,
    coHTTPAuth             = 107,
    coFTPCreateMissingDirs = 110,
    coProxyAuth            = 111,
    coFTPResponseTimeout   = 112,
    coIPResolve            = 113,
    coMaxFileSize          = 114,
    coFTPSSL               = 119,
    coTCPNoDelay           = 121,
    coFTPSSLAuth           = 129,
    coIgnoreContentLength  = 136,
    coFTPSkipPasvIp        = 137,
    coFile                 = 10001,
    coURL                  = 10002,
    coProxy                = 10004,
    coUserPwd              = 10005,
    coProxyUserPwd         = 10006,
    coRange                = 10007,
    coInFile               = 10009,
    coErrorBuffer          = 10010,
    coPostFields           = 10015,
    coReferer              = 10016,
    coFTPPort              = 10017,
    coUserAgent            = 10018,
    coCookie               = 10022,
    coHTTPHeader           = 10023,
    coHTTPPost             = 10024,
    coSSLCert              = 10025,
    coSSLCertPasswd        = 10026,
    coQuote                = 10028,
    coWriteHeader          = 10029,
    coCookieFile           = 10031,
    coCustomRequest        = 10036,
    coStdErr               = 10037,
    coPostQuote            = 10039,
    coWriteInfo            = 10040,
    coProgressData         = 10057,
    coInterface            = 10062,
    coKRB4Level            = 10063,
    coCAInfo               = 10065,
    coTelnetOptions        = 10070,
    coRandomFile           = 10076,
    coEGDSocket            = 10077,
    coCookieJar            = 10082,
    coSSLCipherList        = 10083,
    coSSLCertType          = 10086,
    coSSLKey               = 10087,
    coSSLKeyType           = 10088,
    coSSLEngine            = 10089,
    coPreQuote             = 10093,
    coDebugData            = 10095,
    coCAPath               = 10097,
    coShare                = 10100,
    coEncoding             = 10102,
    coPrivate              = 10103,
    coHTTP200Aliases       = 10104,
    coSSLCtxData           = 10109,
    coNetRCFile            = 10118,
    coSourceUserPwd        = 10123,
    coSourcePreQuote       = 10127,
    coSourcePostQuote      = 10128,
    coIOCTLData            = 10131,
    coSourceURL            = 10132,
    coSourceQuote          = 10133,
    coFTPAccount           = 10134,
    coCookieList           = 10135,
    coUnixSocketPath       = 10231,
    coWriteFunction        = 20011,
    coReadFunction         = 20012,
    coProgressFunction     = 20056,
    coHeaderFunction       = 20079,
    coDebugFunction        = 20094,
    coSSLCtxtFunction      = 20108,
    coIOCTLFunction        = 20130,
    coInFileSizeLarge      = 30115,
    coResumeFromLarge      = 30116,
    coMaxFileSizeLarge     = 30117,
    coPostFieldSizeLarge   = 30120
  );

  /// low-level result codes for libcurl library API calls
  TCurlResult = (
    crOK, crUnsupportedProtocol, crFailedInit, crURLMalformat, crURLMalformatUser,
    crCouldNotResolveProxy, crCouldNotResolveHost, crCouldNotConnect,
    crFTPWeirdServerReply, crFTPAccessDenied, crFTPUserPasswordIncorrect,
    crFTPWeirdPassReply, crFTPWeirdUserReply, crFTPWeirdPASVReply,
    crFTPWeird227Format, crFTPCantGetHost, crFTPCantReconnect, crFTPCouldNotSetBINARY,
    crPartialFile, crFTPCouldNotRetrFile, crFTPWriteError, crFTPQuoteError,
    crHTTPReturnedError, crWriteError, crMalFormatUser, crFTPCouldNotStorFile,
    crReadError, crOutOfMemory, crOperationTimeouted,
    crFTPCouldNotSetASCII, crFTPPortFailed, crFTPCouldNotUseREST, crFTPCouldNotGetSize,
    crHTTPRangeError, crHTTPPostError, crSSLConnectError, crBadDownloadResume,
    crFileCouldNotReadFile, crLDAPCannotBind, crLDAPSearchFailed,
    crLibraryNotFound, crFunctionNotFound, crAbortedByCallback,
    crBadFunctionArgument, crBadCallingOrder, crInterfaceFailed,
    crBadPasswordEntered, crTooManyRedirects, crUnknownTelnetOption,
    crTelnetOptionSyntax, crObsolete, crSSLPeerCertificate, crGotNothing,
    crSSLEngineNotFound, crSSLEngineSetFailed, crSendError, crRecvError,
    crShareInUse, crSSLCertProblem, crSSLCipher, crSSLCACert, crBadContentEncoding,
    crLDAPInvalidURL, crFileSizeExceeded, crFTPSSLFailed, crSendFailRewind,
    crSSLEngineInitFailed, crLoginDenied, crTFTPNotFound, crTFTPPerm,
    crTFTPDiskFull, crTFTPIllegal, crTFTPUnknownID, crTFTPExists, crTFTPNoSuchUser
  );

  /// low-level information enumeration for libcurl library API calls
  TCurlInfo = (
    ciNone,
    ciLastOne               = 28,
    ciEffectiveURL          = 1048577,
    ciContentType           = 1048594,
    ciPrivate               = 1048597,
    ciRedirectURL           = 1048607,
    ciPrimaryIP             = 1048608,
    ciLocalIP               = 1048617,
    ciResponseCode          = 2097154,
    ciHeaderSize            = 2097163,
    ciRequestSize           = 2097164,
    ciSSLVerifyResult       = 2097165,
    ciFileTime              = 2097166,
    ciRedirectCount         = 2097172,
    ciHTTPConnectCode       = 2097174,
    ciHTTPAuthAvail         = 2097175,
    ciProxyAuthAvail        = 2097176,
    ciOS_Errno              = 2097177,
    ciNumConnects           = 2097178,
    ciPrimaryPort           = 2097192,
    ciLocalPort             = 2097194,
    ciTotalTime             = 3145731,
    ciNameLookupTime        = 3145732,
    ciConnectTime           = 3145733,
    ciPreTRansferTime       = 3145734,
    ciSizeUpload            = 3145735,
    ciSizeDownload          = 3145736,
    ciSpeedDownload         = 3145737,
    ciSpeedUpload           = 3145738,
    ciContentLengthDownload = 3145743,
    ciContentLengthUpload   = 3145744,
    ciStartTransferTime     = 3145745,
    ciRedirectTime          = 3145747,
    ciAppConnectTime        = 3145761,
    ciSSLEngines            = 4194331,
    ciCookieList            = 4194332,
    ciCertInfo              = 4194338,
    ciSizeDownloadT         = 6291464,
    ciTotalTimeT            = 6291506, // (6) can be used for calculation "Content download time"
    ciNameLookupTimeT       = 6291507, // (1) DNS lookup
    ciConnectTimeT          = 6291508, // (2) connect time
    ciPreTransferTimeT      = 6291509, // (4)
    ciStartTransferTimeT    = 6291510, // (5) Time to first byte
    ciAppConnectTimeT       = 6291512  // (3) SSL handshake
  );
  {$ifdef LIBCURLMULTI}
  /// low-level result codes for libcurl library API calls in "multi" mode
  TCurlMultiCode = (
    cmcCallMultiPerform = -1,
    cmcOK = 0,
    cmcBadHandle,
    cmcBadEasyHandle,
    cmcOutOfMemory,
    cmcInternalError,
    cmcBadSocket,
    cmcUnknownOption,
    cmcAddedAlready,
    cmcRecursiveApiCall
  );

  /// low-level options for libcurl library API calls in "multi" mode
  TCurlMultiOption = (
    cmoPipeLining               = 3,
    cmoMaxConnects              = 6,
    cmoMaxHostConnections       = 7,
    cmoMaxPipelineLength        = 8,
    cmoMaxTotalConnections      = 13,
    cmoSocketData               = 10002,
    cmoTimerData                = 10005,
    cmoPipeliningSiteBL         = 10011,
    cmoPipeliningServerBL       = 10012,
    cmoPushData                 = 10015,
    cmoSocketFunction           = 20001,
    cmoTimerFunction            = 20004,
    cmoPushFunction             = 20014,
    cmoContentLengthPenaltySize = 30009,
    cmoChunkLengthPenaltySize   = 30010
  );
  {$endif LIBCURLMULTI}

  /// low-level version identifier of the libcurl library
  TCurlVersion = (cvFirst,cvSecond,cvThird,cvFour);
  /// low-level initialization option for libcurl library API
  // - currently, only giSSL is set, since giWin32 is redundant with WinHTTP
  TCurlGlobalInit = set of (giSSL,giWin32);
  /// low-level message state for libcurl library API
  TCurlMsg = (cmNone, cmDone);

  PAnsiCharArray = array[0..(MaxInt div SizeOf(PAnsiChar))-1] of PAnsiChar;

  /// low-level version information for libcurl library
  TCurlVersionInfo = record
    age: TCurlVersion;
    version: PAnsiChar;
    version_num: cardinal;
    host: PAnsiChar;
    features: longint;
    ssl_version: PAnsiChar;
    ssl_version_num: PAnsiChar;
    libz_version: PAnsiChar;
    protocols: ^PAnsiCharArray;
    ares: PAnsiChar;
    ares_num: longint;
    libidn: PAnsiChar;
  end;
  PCurlVersionInfo = ^TCurlVersionInfo;

  /// low-level access to the libcurl library instance
  TCurl = type pointer;
  /// low-level string list type for libcurl library API
  TCurlSList = type pointer;
  PCurlSList = ^TCurlSList;
  PPCurlSListArray = ^PCurlSListArray;
  PCurlSListArray = array[0..(MaxInt div SizeOf(PCurlSList))-1] of PCurlSList;
  /// low-level access to the libcurl library instance in "multi" mode
  TCurlMulti = type pointer;
  /// low-level access to one libcurl library socket instance
  TCurlSocket = type TSocket;

  /// low-level certificate information for libcurl library API
  TCurlCertInfo = packed record
    num_of_certs: integer;
    {$ifdef CPUX64}_align: array[0..3] of byte;{$endif}
    certinfo: PPCurlSListArray;
  end;
  PCurlCertInfo = ^TCurlCertInfo;

  /// low-level message information for libcurl library API
  TCurlMsgRec = packed record
    msg: TCurlMsg;
    {$ifdef CPUX64}_align: array[0..3] of byte;{$endif}
    easy_handle: TCurl;
    data: packed record case byte of
      0: (whatever: Pointer);
      1: (result: TCurlResult);
    end;
  end;
  PCurlMsgRec = ^TCurlMsgRec;

  /// low-level file description event handler for libcurl library API
  TCurlWaitFD = packed record
    fd: TCurlSocket;
    events: SmallInt;
    revents: SmallInt;
    {$ifdef CPUX64}_align: array[0..3] of byte;{$endif}
  end;
  PCurlWaitFD = ^TCurlWaitFD;

  /// low-level write callback function signature for libcurl library API
  curl_write_callback = function (buffer: PAnsiChar; size,nitems: integer;
    outstream: pointer): integer; cdecl;
  /// low-level read callback function signature for libcurl library API
  curl_read_callback = function (buffer: PAnsiChar; size,nitems: integer;
    instream: pointer): integer; cdecl;

{$Z1}


var
  /// low-level late binding functions access to the libcurl library API
  // - ensure you called LibCurlInitialize or CurlIsAvailable functions to
  // setup this global instance before using any of its internal functions
  // - see also https://curl.haxx.se/libcurl/c/libcurl-multi.html interface
  curl: packed record
    /// hold a reference to the loaded library
    // - PtrInt(Module)=0 before initialization, or PtrInt(Module) = -1
    // on initialization failure, or PtrInt(Module)>0 if loaded
    {$ifdef FPC}
    Module: TLibHandle;
    {$else}
    Module: THandle;
    {$endif FPC}
    /// initialize the library
    global_init: function(flags: TCurlGlobalInit): TCurlResult; cdecl;
    /// finalize the library
    global_cleanup: procedure; cdecl;
    /// returns run-time libcurl version info
    version_info: function(age: TCurlVersion): PCurlVersionInfo; cdecl;
    // start a libcurl easy session
    easy_init: function: pointer; cdecl;
    /// set options for a curl easy handle
    easy_setopt: function(curl: TCurl; option: TCurlOption): TCurlResult; cdecl varargs;
    /// perform a blocking file transfer
    easy_perform: function(curl: TCurl): TCurlResult; cdecl;
    /// end a libcurl easy handle
    easy_cleanup: procedure(curl: TCurl); cdecl;
    /// extract information from a curl handle
    easy_getinfo: function(curl: TCurl; info: TCurlInfo; out value): TCurlResult; cdecl;
    /// clone a libcurl session handle
    easy_duphandle: function(curl: TCurl): pointer; cdecl;
    /// reset all options of a libcurl session handle
    easy_reset: procedure(curl: TCurl); cdecl;
    /// return string describing error code
    easy_strerror: function(code: TCurlResult): PAnsiChar; cdecl;
    /// add a string to an slist
    slist_append: function(list: TCurlSList; s: PAnsiChar): TCurlSList; cdecl;
    /// free an entire slist
    slist_free_all: procedure(list: TCurlSList); cdecl;
    {$ifdef LIBCURLMULTI}
    /// add an easy handle to a multi session
    multi_add_handle: function(mcurl: TCurlMulti; curl: TCurl): TCurlMultiCode; cdecl;
    /// set data to associate with an internal socket
    multi_assign: function(mcurl: TCurlMulti; socket: TCurlSocket; data: pointer): TCurlMultiCode; cdecl;
    /// close down a multi session
    multi_cleanup: function(mcurl: TCurlMulti): TCurlMultiCode; cdecl;
    /// extracts file descriptor information from a multi handle
    multi_fdset: function(mcurl: TCurlMulti; read, write, exec: PFDSet; out max: integer): TCurlMultiCode; cdecl;
    /// read multi stack informationals
    multi_info_read: function(mcurl: TCurlMulti; out msgsqueue: integer): PCurlMsgRec; cdecl;
    /// create a multi handle
    multi_init: function: TCurlMulti; cdecl;
    /// reads/writes available data from each easy handle
    multi_perform: function(mcurl: TCurlMulti; out runningh: integer): TCurlMultiCode; cdecl;
    /// remove an easy handle from a multi session
    multi_remove_handle: function(mcurl: TCurlMulti; curl: TCurl): TCurlMultiCode; cdecl;
    /// set options for a curl multi handle
    multi_setopt: function(mcurl: TCurlMulti; option: TCurlMultiOption): TCurlMultiCode; cdecl varargs;
    /// reads/writes available data given an action
    multi_socket_action: function(mcurl: TCurlMulti; socket: TCurlSocket; mask: Integer; out runningh: integer): TCurlMultiCode; cdecl;
    /// reads/writes available data - deprecated call
    multi_socket_all: function(mcurl: TCurlMulti; out runningh: integer): TCurlMultiCode; cdecl;
    /// return string describing error code
    multi_strerror: function(code: TCurlMultiCode): PAnsiChar; cdecl;
    /// retrieve how long to wait for action before proceeding
    multi_timeout: function(mcurl: TCurlMulti; out ms: integer): TCurlMultiCode; cdecl;
    /// polls on all easy handles in a multi handle
    multi_wait: function(mcurl: TCurlMulti; fds: PCurlWaitFD; fdscount: cardinal; ms: integer; out ret: integer): TCurlMultiCode; cdecl;
    {$endif LIBCURLMULTI}
    /// contains numerical information about the initialized libcurl instance
    info: TCurlVersionInfo;
    /// contains textual information about the initialized libcurl instance
    infoText: string;
  end;

/// initialize the libcurl API, accessible via the curl global variable
// - do nothing if the library has already been loaded
// - will raise ECurl exception on any loading issue
procedure LibCurlInitialize(engines: TCurlGlobalInit=[giSSL]);

/// return TRUE if a curl library is available
// - will load and initialize it, calling LibCurlInitialize if necessary,
// catching any exception during the process
function CurlIsAvailable: boolean;

/// Callback used by libcurl to write data; Usage:
// curl.easy_setopt(fHandle,coWriteFunction,@CurlWriteRawByteString);
// curl.easy_setopt(curlHandle,coFile,@curlRespBody);
// where curlRespBody should be a generic AnsiString/RawByteString, i.e.
// in practice a SockString or a RawByteString
function CurlWriteRawByteString(buffer: PAnsiChar; size,nitems: integer;
  opaque: pointer): integer; cdecl;


implementation

type
  // some internal cross-compiler array of bytes string definition
  SockString = {$ifdef HASCODEPAGE}RawByteString{$else}AnsiString{$endif};
  // some internal cross-compiler PtrInt definition
  {$ifndef FPC} PtrInt = {$ifdef CPU64}Int64{$else}integer{$endif}; {$endif}

function CurlWriteRawByteString(buffer: PAnsiChar; size,nitems: integer;
  opaque: pointer): integer; cdecl;
var storage: ^SockString absolute opaque;
    n: integer;
begin
  if storage=nil then
    result := 0 else begin
    n := length(storage^);
    result := size*nitems;
    SetLength(storage^,n+result);
    Move(buffer^,PPAnsiChar(opaque)^[n],result);
  end;
end;

function CurlIsAvailable: boolean;
begin
 try
   if curl.Module=0 then
     LibCurlInitialize;
   result := PtrInt(curl.Module)>0;
 except
   result := false;
 end;
end;

procedure LibCurlInitialize(engines: TCurlGlobalInit);
var P: PPointer;
    api: integer;
const NAMES: array[0..{$ifdef LIBCURLMULTI}26{$else}12{$endif}] of string = (
  'global_init','global_cleanup','version_info',
  'easy_init','easy_setopt','easy_perform','easy_cleanup','easy_getinfo',
  'easy_duphandle','easy_reset','easy_strerror','slist_append','slist_free_all'
  {$ifdef LIBCURLMULTI},
  'multi_add_handle','multi_assign','multi_cleanup','multi_fdset',
  'multi_info_read','multi_init','multi_perform','multi_remove_handle',
  'multi_setopt','multi_socket_action','multi_socket_all','multi_strerror',
  'multi_timeout','multi_wait'
  {$endif LIBCURLMULTI} );
begin
  EnterCriticalSection(SynSockCS);
  try
    if curl.Module=0 then // try to load libcurl once
    try
      curl.Module := LoadLibrary(LIBCURL_DLL);
      {$ifdef Darwin} // another common names on MacOS
      if curl.Module=0 then
        curl.Module := LoadLibrary('libcurl.4.dylib');
      if curl.Module=0 then
        curl.Module := LoadLibrary('libcurl.3.dylib');
      {$else}
      {$ifdef Linux} // another common names on POSIX
      if curl.Module=0 then
        curl.Module := LoadLibrary('libcurl.so.4');
      if curl.Module=0 then
        curl.Module := LoadLibrary('libcurl.so.3');
      // for latest Linux Mint and other similar distros using gnutls
      if curl.Module=0 then
        curl.Module := LoadLibrary('libcurl-gnutls.so.4');
      if curl.Module=0 then
        curl.Module := LoadLibrary('libcurl-gnutls.so.3');
      {$endif Linux}
      {$endif Darwin}
      if curl.Module=0 then
        raise ECurl.CreateFmt('Unable to find %s'{$ifdef Linux}+
          ': try e.g. sudo apt-get install libcurl3'{$ifdef CPUX86}+':i386'{$endif}
          {$endif Linux},[LIBCURL_DLL]);
      P := @@curl.global_init;
      for api := low(NAMES) to high(NAMES) do begin
        P^ := GetProcAddress(curl.Module,{$ifndef FPC}PChar{$endif}('curl_'+NAMES[api]));
        if P^=nil then
          raise ECurl.CreateFmt('Unable to find %s() in %s',[NAMES[api],LIBCURL_DLL]);
        inc(P);
      end;
      curl.global_init(engines);
      curl.info := curl.version_info(cvFour)^;
      curl.infoText := format('%s version %s',[LIBCURL_DLL,curl.info.version]);
      if curl.info.ssl_version<>nil then
        curl.infoText := format('%s using %s',[curl.infoText,curl.info.ssl_version]);
  //   api := 0; with curl.info do while protocols[api]<>nil do begin
  //     write(protocols[api], ' '); inc(api); end; writeln(#13#10,curl.infoText);
    except
      on E: Exception do begin
        if curl.Module<>0 then
          FreeLibrary(curl.Module);
        PtrInt(curl.Module) := -1; // <>0 so that won't try to load any more
        raise;
      end;
    end;
  finally
    LeaveCriticalSection(SynSockCS);
  end;
end;

end.