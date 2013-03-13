/**
 * User: tamt
 * Date: 13-3-3
 * Time: 下午4:55
 */
package
{
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.themes.MetalWorksMobileTheme;

import flash.events.NetStatusEvent;

import flash.media.Camera;
import flash.media.Video;
import flash.net.NetStream;

import starling.display.Sprite;
import starling.events.Event;

import flash.net.NetConnection;

public class DinDin extends Sprite
{
    /**
     * Constructor.
     */
    public function DinDin()
    {
        //we'll initialize things after we've been added to the stage
        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
    }

    /**
     * A Feathers theme will automatically pass skins to any components that
     * are added to the stage. Components do not have default skins, so you
     * must always use a theme or skin the components manually.
     *
     * @see http://wiki.starling-framework.org/feathers/themes
     */
    protected var theme:MetalWorksMobileTheme;

    /**
     * The Feathers Button control that we'll be creating.
     */
    protected var button:Button;
    private var netConnection:NetConnection;

    /**
     * Where the magic happens. Start after the main class has been added
     * to the stage so that we can access the stage property.
     */
    protected function addedToStageHandler(event:Event):void
    {
        this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

        //create the theme. this class will automatically pass skins to any
        //Feathers component that is added to the stage. you should always
        //create a theme immediately when your app starts up to ensure that
        //all components are properly skinned.
        this.theme = new MetalWorksMobileTheme(this.stage, false);

        //create a button and give it some text to display.
        this.button = new Button();
        this.button.label = "Click Me";

        //an event that tells us when the user has tapped the button.
        this.button.addEventListener(Event.TRIGGERED, button_triggeredHandler);

        //add the button to the display list, just like you would with any
        //other Starling display object. this is where the theme give some
        //skins to the button.
        this.addChild(this.button);

        //the button won't have a width and height until it "validates". it
        //will validate on its own before the next frame is rendered by
        //Starling, but we want to access the dimension immediately, so tell
        //it to validate right now.
        this.button.validate();

        //center the button
        this.button.x = (this.stage.stageWidth - this.button.width) / 2;
        this.button.y = (this.stage.stageHeight - this.button.height) / 2;
    }

    /**
     * Listener for the Button's Event.TRIGGERED event.
     */
    protected function button_triggeredHandler(event:Event):void
    {
        if (Camera.isSupported) {
            const label:Label = new Label();
            var cam:String = Camera.names[0];
            label.text = cam;
            this.addChild(label);

            var camera:Camera = Camera.getCamera();
            camera.setQuality(1024, 16)
            var video:Video = new Video(320, 240)
            video.attachCamera(camera);
            App.stage.addChild(video);
        }

    }

    protected function connect():void
    {
        netConnection = new NetConnection();
        netConnection.addEventListener(NetStatusEvent.NET_STATUS, netConnectionHandler);

        // incoming call coming on NetConnection object
        var c:Object = new Object();
        c.onRelay = function (id:String, action:String, name:String):void
        {
            if (Invite == action) {
                if (currentState == CallReady) {
                    ring();

                    currentState = CallRinging;

                    // callee subscribes to media, to be able to get the remote user name
                    incomingStream = new NetStream(netConnection, id);
                    incomingStream.addEventListener(NetStatusEvent.NET_STATUS, incomingStreamHandler);
                    incomingStream.play("media-caller");

                    // set volume for incoming stream
                    var st:SoundTransform = new SoundTransform(speakerVolumeSlider.value / 100);
                    incomingStream.soundTransform = st;

                    incomingStream.receiveAudio(false);
                    incomingStream.receiveVideo(false);

                    var i:Object = new Object;

                    i.onIm = function (name:String, text:String):void
                    {
                        textOutput.text += name + ": " + text + "\n";
                        textOutput.validateNow();
                    }
                    incomingStream.client = i;

                    remoteName = name;
                    remoteId = id;
                }
                else {
                    status("Call rejected due to state: " + currentState + "\n");
                    netConnection.call(Relay, null, id, Reject, userNameInput.text);
                }
            }
            else if (Reject == action) {
                currentState = CallReady;

                onHangup();
            }
            else if (Accept == action) {
                if (currentState != CallCalling) {
                    status("Call accept: Wrong call state: " + currentState + "\n");
                    return;
                }

                currentState = CallEstablished;
            }
            else if (Bye == action) {
                netConnection.call(Relay, null, id, Ok, userNameInput.text);

                currentState = CallReady;

                onHangup();
            }
            else if (Cancel == action) {
                netConnection.call(Relay, null, id, Ok, userNameInput.text);

                currentState = CallReady;

                onHangup();
            }
        }

        netConnection.client = c;

        try {
            netConnection.connect(connectUrl, DeveloperKey);
        }
        catch (e:ArgumentError) {
            status("Incorrect connet URL\n");
            return;
        }
    }

    private function netConnectionHandler(event:NetStatusEvent):void
    {
        status("NetConnection event: " + event.info.code + "\n");

        switch (event.info.code) {
            case "NetConnection.Connect.Success":
                connectSuccess();
                break;

            case "NetConnection.Connect.Closed":
                currentState = LoginNotConnected;
                break;

            case "NetStream.Connect.Success":
                // we get this when other party connects to our outgoing stream
                status("Connection from: " + event.info.stream.farID + "\n");
                break;

            case "NetConnection.Connect.Failed":
                status("Unable to connect to " + connectUrl + "\n");
                currentState = LoginNotConnected;
                break;
        }
    }

}
}
