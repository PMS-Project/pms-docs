var ws = null;
function test()
{
  if(ws != null){
    ws.send("NOCHMAL");
    return;
  }
  if ("WebSocket" in window){
  //  // Google example code
    ws = new WebSocket("ws://localhost:3000");
    ws.onopen = function(){
        // Web Socket is connected. You can send data by send() method
        ws.send("Dies ist ein Test");
    };
    ws.onmessage = function (evt) { var received_msg = evt.data; alert(received_msg);};
    ws.onclose = function() { // websocket is closed. 
      
    };
  }else{
    // the browser doesn't support WebSockets
    alert("Your Browser Sucks!");
  }
}
