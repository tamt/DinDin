package
{

import flash.display.Sprite;
import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.text.TextField;

public class Sender extends Sprite
{

    private var connectUrl:String = "rtmfp://p2p.rtmfp.net"
    private var developerKey:String = 'de58cdec6ebc0924075538b0-2c124047ea83';
    private var serviceUrl:String = 'http://www.itamt.com/dindin/service.php';
    private var nc:NetConnection;

    public function Sender()
    {
        nc = new NetConnection()
        nc.connect(connectUrl, developerKey)
        nc.addEventListener(NetStatusEvent.NET_STATUS, netConnectionHandler);

        var c:Object = new Object();
        c.onRelay = function (id:String, action:String, name:String):void
        {
            trace("[Object.onRelay]", id, action, name);
        }
    }

    private function netConnectionHandler(event:NetStatusEvent):void
    {
        status("NetConnection event: " + event.info.code + "\n");

        switch (event.info.code) {
            case "NetConnection.Connect.Success":
                trace('nearID: ' + nc.nearID)
                var service:URLRequest = new URLRequest(this.serviceUrl)
                var variables:URLVariables = new URLVariables()
                variables.op = 'setid';
                variables.id = nc.nearID;
                service.data = variables;
                var loader:URLLoader = new URLLoader(service)
                loader.addEventListener(Event.COMPLETE, onLoginServiceResponse)
                break;
            case "NetConnection.Connect.Closed":
//                currentState = LoginNotConnected;
                break;
            case "NetStream.Connect.Success":
                // we get this when other party connects to our outgoing stream
                status("Connection from: " + event.info.stream.farID + "\n");
                break;
            case "NetConnection.Connect.Failed":
                status("Unable to connect to " + connectUrl + "\n");
//                currentState = LoginNotConnected;
                break;
        }
    }

    private function onLoginServiceResponse(event:Event):void
    {
        trace("[Sender.onLoginServiceResponse]", (event.target as URLLoader).data);
    }

    private function status(msg:String):void
    {
        trace("ScriptDebug: " + msg);
    }


}
}
