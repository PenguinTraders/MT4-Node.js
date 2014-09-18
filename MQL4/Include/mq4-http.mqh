//+------------------------------------------------------------------+
//|                                                  InternetLib.mqh |
//|                                 Copyright © 2010 www.fxmaster.de |
//|                                         Coding by Sergeev Alexey |
//+------------------------------------------------------------------+
#property copyright   "www.fxmaster.de  © 2010"
#property link        "www.fxmaster.de"
#property version     "1.00"
#property description "Library for work with wininet.dll"
#property library

#import "wininet.dll"
int InternetAttemptConnect(int x);
int InternetOpenW(string &sAgent,int lAccessType,string &sProxyName,string &sProxyBypass,int lFlags);
int InternetConnectW(int hInternet,string &lpszServerName,int nServerPort,string &lpszUsername,string &lpszPassword,int dwService,int dwFlags,int dwContext);
int HttpOpenRequestW(int hConnect,string &lpszVerb,string &lpszObjectName,string &lpszVersion,string lpszReferer,string &lplpszAcceptTypes[],uint dwFlags,int dwContext);
int HttpSendRequestW(int hRequest,string &lpszHeaders,int dwHeadersLength,uchar &lpOptional[],int dwOptionalLength);
int HttpQueryInfoW(int hRequest,int dwInfoLevel,uchar &lpvBuffer[],int &lpdwBufferLength,int &lpdwIndex);
int InternetOpenUrlW(int hInternet,string &lpszUrl,string &lpszHeaders,int dwHeadersLength,int dwFlags,int dwContext);
int InternetReadFile(int hFile,uchar &sBuffer[],int lNumBytesToRead,int &lNumberOfBytesRead);
int InternetCloseHandle(int hInet);
#import

#define OPEN_TYPE_PRECONFIG           0  // use confuguration by default
#define FLAG_KEEP_CONNECTION 0x00400000  // keep connection
#define FLAG_PRAGMA_NOCACHE  0x00000100  // no cache
#define FLAG_RELOAD          0x80000000  // reload page when request
#define SERVICE_HTTP                  3  // Http service
#define HTTP_QUERY_CONTENT_LENGTH     5
//+------------------------------------------------------------------+
class MqlNet
  {

   string            Host;       // host name
   int               Port;       // port
   int               Session;    // session descriptor
   int               Connect;    // connection descriptor
public:
                     MqlNet();   // class constructor
                    ~MqlNet();   // destructor
   bool              Open(string aHost,int aPort); // create session and open connection
   void              Close();    // close session and connection
   bool              Request(string Verb,string Request,string &Out,bool toFile=false,bool get_out=false,string addData="",bool fromFile=false); // send request
   bool              OpenURL(string URL,string &Out,bool toFile); // open page
   void              ReadPage(int hRequest,string &Out,bool toFile); // read page
   long              GetContentSize(int hURL); //get content size
   int               FileToArray(string FileName,uchar &data[]); // copying file to the array
  };
//------------------------------------------------------------------ MqlNet
void MqlNet::MqlNet()
  {
   // default values
   Session=-1;
   Connect=-1;
   Host="";
  }
//------------------------------------------------------------------ ~MqlNet
void MqlNet::~MqlNet()
  {
   // close all descriptors
   Close();
  }
//------------------------------------------------------------------ Open
bool MqlNet::Open(string aHost,int aPort)
  {
   if(aHost=="")
     {
      Print("-Host is not specified");
      return(false);
     }
   // is DLL allowed in the client terminal
   if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED))
     {
      Print("-DLL is not allowed");
      return(false);
     }
   // if session has been opened, close it
   if(Session>0 || Connect>0) Close();
   // exit, if connection check has failed
   if(InternetAttemptConnect(0)!=0)
     {
      Print("-Err AttemptConnect");
      return(false);
     }
   string UserAgent="Mozilla"; string nill="";
   // open session
   Session=InternetOpenW(UserAgent,OPEN_TYPE_PRECONFIG,nill,nill,0);
   // exit, if session is not opened
   if(Session<=0)
     {
      Print("-Err create Session");
      Close();
      return(false);
     }
   Connect=InternetConnectW(Session,aHost,aPort,nill,nill,SERVICE_HTTP,0,0);
   if(Connect<=0)
     {
      Print("-Err create Connect");
      Close();
      return(false);
     }
   Host=aHost; 
   Port=aPort;
   // overwise all checks successful
   return(true);
  }
//------------------------------------------------------------------ Close
void MqlNet::Close()
  {
   if(Session>0) InternetCloseHandle(Session);
   Session=-1;
   if(Connect>0) InternetCloseHandle(Connect);
   Connect=-1;
  }
//------------------------------------------------------------------ Request
bool MqlNet::Request(string Verb,string Object,string &Out,bool toFile=false, bool get_out=false, string addData="",bool fromFile=false)
  {
   
   if(toFile && Out=="")
     {
      Print("-File is not specified ");
      return(false);
     }
   uchar data[];
   int hRequest,hSend,h;
   string Vers="HTTP/1.1";
   string nill="";
   if(fromFile)
     {
      if(FileToArray(addData,data)<0)
        {
         Print("-Err reading file "+addData);
         return(false);
        }
     } // file loaded to the array
   else StringToCharArray(addData,data);

   if(Session<=0 || Connect<=0)
     {
      Close();
      if(!Open(Host,Port))
        {
         Print("-Err Connect");
         Close();
         return(false);
        }
     }
   // create descriptor for the request
   string accept[] = {"Accept: text/*\r\n"};
   hRequest=HttpOpenRequestW(Connect,Verb,Object,Vers,NULL,accept,FLAG_KEEP_CONNECTION|FLAG_RELOAD|FLAG_PRAGMA_NOCACHE,NULL);
   if(hRequest<=0)
     {
      Print("-Err OpenRequest");
      InternetCloseHandle(Connect);
      return(false);
     }
   // send request
   // request headed
   string head="Content-Type: application/x-www-form-urlencoded";
   // send request
  hSend=HttpSendRequestW(hRequest,head,StringLen(head),data,ArraySize(data)-1);
   if(hSend<=0)
     {
      Print("-Err SendRequest");
      InternetCloseHandle(hRequest);
      Close();
     }
  
   // read page
   if(get_out) ReadPage(hRequest,Out,toFile);
   // close all descriptors
   InternetCloseHandle(hRequest);
   InternetCloseHandle(hSend);
   return(true);
  }
//------------------------------------------------------------------ OpenURL
bool MqlNet::OpenURL(string URL,string &Out,bool toFile)
  {
   string nill="";
   if(Session<=0 || Connect<=0)
     {
      Close();
      if(!Open(Host,Port))
        {
         Print("-Err Connect");
         Close();
         return(false);
        }
     }
   int hURL=InternetOpenUrlW(Session, URL, nill, 0, FLAG_RELOAD|FLAG_PRAGMA_NOCACHE, 0);
   if(hURL<=0)
     {
      Print("-Err OpenUrl");
      return(false);
     }
   // read to Out
   ReadPage(hURL,Out,toFile);
   // close
   InternetCloseHandle(hURL);
   return(true);
  }
//------------------------------------------------------------------ ReadPage
void MqlNet::ReadPage(int hRequest,string &Out,bool toFile)
  {
   // read page
   uchar ch[128];
   string toStr="";
   int dwBytes,h;
   while(InternetReadFile(hRequest,ch,128,dwBytes))
     {
      if(dwBytes<=0) break;
      toStr=toStr+CharArrayToString(ch,0,dwBytes);
     }
   if(toFile)
     {
      h=FileOpen(Out,FILE_BIN|FILE_WRITE);
      FileWriteString(h,toStr);
      FileClose(h);
     }
   else Out=toStr;
  }
//------------------------------------------------------------------ GetContentSize
long MqlNet::GetContentSize(int hRequest)
  {
   int len=2048,ind=0;
   uchar buf[2048];
   int Res=HttpQueryInfoW(hRequest, HTTP_QUERY_CONTENT_LENGTH, buf, len, ind);
   if(Res<=0)
     {
      Print("-Err QueryInfo");
      return(-1);
     }
   string s=CharArrayToString(buf,0,len);
   if(StringLen(s)<=0) return(0);
   return(StringToInteger(s));
  }
//----------------------------------------------------- FileToArray
int MqlNet::FileToArray(string FileName,uchar &data[])
  {
   int h,i,size;
   h=FileOpen(FileName,FILE_BIN|FILE_READ);
   if(h<0) return(-1);
   FileSeek(h,0,SEEK_SET);
   size=(int)FileSize(h);
   ArrayResize(data,(int)size);
   for(i=0; i<size; i++)
     {
      data[i]=(uchar)FileReadInteger(h,CHAR_VALUE);
     }
   FileClose(h); return(size);
  }
//+------------------------------------------------------------------+

string URLEncode(string toCode) {
  int max = StringLen(toCode);

  string RetStr = "";
  for(int i=0;i<max;i++) {
    string c = StringSubstr(toCode,i,1);
    int  asc = StringGetChar(c, 0);

    if((asc > 47 && asc < 58) || (asc > 64 && asc < 91) || (asc > 96 && asc < 123)) 
      RetStr = StringConcatenate(RetStr,c);
    else if (asc == 32)
      RetStr = StringConcatenate(RetStr,"+");
    else {
      RetStr = StringConcatenate(RetStr,"%",hex(asc));
    }
  }
  return (RetStr);
}

string ArrayEncode(string &array[][]) {
   string ret = "";
   string key,val;
   int l = ArrayRange(array,0);
   for (int i=0;i<l;i++) {
      key = URLEncode(array[i,0]);
      val = URLEncode(array[i,1]);
      ret = StringConcatenate(ret,key,"=",val);
      if (i+1<l) ret = StringConcatenate(ret,"&");
   }
   return (ret);
}

void addParam(string key, string val, string&array[][]) {
   int l = ArrayRange(array,0);
   if (ArrayResize(array, l+1)>-1) {
      array[l][0]=key;
      array[l][1]=val;
   }
}

string hex(int i) {
   static string h =  "0123456789ABCDEF";
   string ret="";
   int a = i % 16;
   int b = (i-a)/16;
   if (b>15) ret = StringConcatenate(hex(b), StringSubstr(h,a,1));
   else      ret = StringConcatenate(StringSubstr(h, b ,1), StringSubstr(h,a,1));
   
   return (ret);
}
