package {
	
	public class AppEngineCall{

		import flash.events.*;
		import flash.net.*;
		import flash.net.URLVariables;
		
		import mx.controls.Alert;
		
		private var request:URLRequest;
		private var loader:URLLoader;
		private var onCompleteFunc:Function;
		private var passThru:Object;
		
		public static const SUBMIT_WORD:String =  "submitWordCard";
		public static const SUBMIT_PRODUCT:String = "submitProduct";
		public static const DRAW_CARD:String = "drawCard";
		public static const GET_PRODUCT:String = "getProduct";
		
		public function AppEngineCall(func:String, vars:Object, onComplete:Function ):void
		{
			
			onCompleteFunc = onComplete;
			passThru = vars;
			
			//Alert.show(func + " and");
			
			request = new URLRequest("/" + func);
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			request.method = URLRequestMethod.POST;
			var variables : URLVariables = new URLVariables();
			
			for(var i:String in vars){
				variables[i] = vars[i];
			}
			
			request.data = variables;
			
			//Alert.show("13");
			
			loader.addEventListener(Event.COMPLETE, handleComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
			loader.load(request);
		}
		
		private function handleComplete(event:Event):void {
			
			var loader:URLLoader = URLLoader(event.target);	
			//Alert.show("handleComplete" + loader.data.wordDescription + " and " + loader.data.word);
			
			onCompleteFunc(loader.data, passThru);
			
		}
		private function onIOError(event:IOErrorEvent):void {
			Alert.show("Error!!!!!!" + event.text);
		}
		
		private function onSecError(event:Event):void {
			Alert.show("Security Error!!!!!!");
		}
	}
}