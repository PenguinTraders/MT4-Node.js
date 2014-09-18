/* This is example code. Modify it accordingly. For questions, please visit http://penguintraders.com */

//Include the node.js modules that you need. Make sure you install them first with npm install
var http = require("http");

var _PORT = 8080; //Http port Node.js server will be listening on. Make sure that this is an open port and its the same as the one defined in MT4 indicator/EA.
	

//Create the server and listening to the request
http.createServer(function onRequest(request, response) {
	request.setEncoding("utf8");
	var content = [];

	request.addListener("data", function(data) {
		content.push(data); //Collect the incoming data
	});
	

	//At the end of request call
	request.addListener("end", function() {
		//setup the response
		response.writeHead( 200, {"Content-Type": "text/plain"} );
		
		ms = content[0];
		
		if(ms.toString() != "")
		{
			var msg = ms.toString();	//Parse the ms into string		
			
			console.log(msg); // Prints the message in the console
			
			var reqObj = JSON.parse(msg);	// If the incoming message is in JSON format, you can parse it as JSON.
			
			
			console.log(reqObj); 
			
			/*
			Here you can have the code to do what you want it to do. You can also use cluster to run a multithreaded app. Or connect to a DB or connect to external web services and collect data, etc
			*/
			
			//Create a dummy response object
			var outObj = {
				value: Math.random()*reqObj.value, //Just some random value to demonstrate
				msg: "test message",
			}
			
			response.write(JSON.stringify(outObj));	//Write the response
			response.end(); //Close the response

		}

	});

	
	
}).listen(_PORT);

console.log("Node.js server listening on port "+ _PORT);

