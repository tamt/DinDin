package
{
	import com.reyco1.multiuser.DirectLanConnection;
	import com.reyco1.multiuser.debug.Logger;
	
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class SimpleReciever extends Sprite
	{
		[Embed(source="../fonts/tahoma.ttf", fontFamily="Tahoma", embedAsCFF="false")]
		private var TahomaFont:String;
		
		private var tf:TextField;
		private var dlc:DirectLanConnection;
		
		public function SimpleReciever()
		{
			createTextField();
			initConnection();
		}
		
		private function initConnection():void
		{
			dlc = new DirectLanConnection();
			dlc.onDataRecieve = handleData;
			dlc.onConnect = handleConnect;
			dlc.connect();
		}
		
		private function handleConnect(data:Object):void
		{
			Logger.log("connected with id: " + dlc.port, this);
		}
		
		private function handleData(data:Object):void
		{
			Logger.log("type: " + data.type + ", value: " + data.value, this);
		}
		
		private function createTextField():void
		{
			var format:TextFormat = new TextFormat("Tahoma", 12, 0x000000);
			tf = new TextField();
			tf.defaultTextFormat = format;
			tf.multiline = true;
			tf.wordWrap = true;
			tf.width = stage.stageWidth;
			tf.height = stage.stageHeight;
			tf.embedFonts = true;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			addChild(tf);
			
			Logger.textArea = tf;
			Logger.LEVEL = Logger.ALL_BUT_NET_STATUS;
		}
	}
}