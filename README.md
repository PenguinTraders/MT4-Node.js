MT4-Node.js
===========

MT4 Node.js client/server 

[Visit Penguin Traders](http://penguintraders.com/) to get help from the community

This demonstrates how you can communicate between a Node.js server and a MT4 client application quickly. There are no delays and the connection/calculations are done on the same tick. 

The Node folder contains the Node.js server application that you can run. MQL4 folder contains a simple indicator made for demonstration purposes. 

You must have Node.js installed and working in your computer (http://nodejs.org/download). Make sure you have allowed DLL imports in MT4 (Tools > Options > Expert Advisor, check the box "Allow DLL imports)

### Installation
- Copy the entire directory into your MetaTrader installation folder.
- Open the command prompt and browse to where you copied the Node folder into (The Node folder can be anywhere) and then enter the command following command to run the server: node server.js 
  For example, if the Node folder is in C:\Node, you can execute the server by entering: node c:\Node\server.js
- Either compile the "sample_node_indi.mq4" indicator in MetaEditor or restart MT4 for the indicator to show up in MT4 terminal. 
- Attach the indicator and have fun experimenting.

[Visit Penguin Traders](http://penguintraders.com/) for more examples and for indicators that you can download that uses the MT4 to Node.js extensively.


#### License
This code is released to the public under GNU GENERAL PUBLIC LICENSE
