/*
For help and support, please visit http://penguintraders.com

https://github.com/PenguinTraders/MT4-Node.js
http://www.forexfactory.com/saver0
*/

#property copyright "Copyright © 2014, Penguin Traders"
#property link      "http://penguintraders.com/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue


#include <mq4-http.mqh>
#include <hash.mqh>
#include <json.mqh>


extern string hostIp = "localhost";
extern int hostPort = 8080;
extern int maxBarsToLoad = 500;

MqlNet INet;
double DataBuffer[];
string _obj = "exampleIndi_";

int deinit() {

	//Delete any objects created on the chart by the indicator
   for (int index = 0; index < ObjectsTotal(); index++)
	{
		if (StringFind(ObjectName(index), _obj) == 0)
		{
			ObjectDelete(ObjectName(index));
			index--;
		}
	}
	
	
   return(0);
}

int init() {

	IndicatorBuffers(1);
	
	SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,DataBuffer);  
	
   return(0);
}


//Make the request to the Node.js server with the price to do some caculations and return the result
double make_request(double price)
{
   
	//Create the client request. This is in JSON format but you can send any string
	string reqest = "{\"value\":\""+price+"\"}";
	
	//Create the response string
	string response = "";
	
	//Make the connection
	if(!INet.Open(hostIp,hostPort)) return(0);
	if(!INet.Request("POST","/",response,false, true, reqest, false))
	{
		printDebug("-Err download ");
		return(0);
	}
	
	double calculated_value = 0; //To store the calculated value from the server
	
	//The response string should now contain the response that the Node.js server gave with the data that we need
	if (response != "") // If the respone isn't empty
	{
		
		
		JSONParser *parser = new JSONParser(); //Since the response is a JSON object, let's parse it
		JSONValue *jv = parser.parse(response);
		
		//If the object looks good
		if (jv == NULL) {
			printDebug("error:"+(string)parser.getErrorCode()+parser.getErrorMessage());
		} else {

			JSONObject *jo = jv;

			calculated_value = jo.getDouble("value");

		}
		
		delete parser;
	
	}
	
	return (calculated_value); // Return the value

}


int start()
{
	int counted_bars = IndicatorCounted();
	int limit = MathMin(Bars - counted_bars, maxBarsToLoad);


	for (int i=limit; i>=0; i--)
	{
		DataBuffer[i] = make_request(Close[i]); // Make the request and set the data buffer with the caculated value 
	}


   return(0);
}  



//Helper functions to print debug information on to the chart
int debugLine = 0;
void printDebug(string msg)
{

	int y = 15*debugLine;
	int x = 20+MathFloor(y/800)*410;

	y = 20+MathMod(y,800);

	DrawLabel(_obj+"_debug_"+debugLine, msg, x, y, DodgerBlue, "Arial", 9);
	debugLine++;

}
void DrawLabel(string label, string text, int x, int y, color clr, string fontName, int fontSize)
{
   int typeCorner = 0;
 
   string labelIndicator = label;   
   if (ObjectFind(labelIndicator) == -1)
   {
      ObjectCreate(labelIndicator, OBJ_LABEL, 0, 0, 0);
   }
   
   ObjectSet(labelIndicator, OBJPROP_CORNER, typeCorner);
   ObjectSet(labelIndicator, OBJPROP_XDISTANCE, x);
   ObjectSet(labelIndicator, OBJPROP_YDISTANCE, y);
   ObjectSetText(labelIndicator, text, fontSize, fontName, clr);
}
