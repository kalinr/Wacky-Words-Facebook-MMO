package {
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;
	
	public class AppEngineCall{

		private var request:URLRequest;
		private var loader:URLLoader;
		private var onCompleteFunc:Function;
		private var passThru:Object;
		
		/*public static const SUBMIT_WORD:String =  "adminPage/submitWordCard";
		public static const SUBMIT_PRODUCT:String = "submitProduct";
		public static const DRAW_CARD:String = "drawCard";
		public static const GET_PRODUCT:String = "getProduct";
		public static const PRODUCT_VOTE:String = "productVote";
		public static const INVEST:String = "invest";*/
		public static const SUBMIT_WORD_CARD:String = "submitWordCard";
		
		public function AppEngineCall(func:String, vars:Object, onComplete:Function, authenticate:Boolean = false ):void
		{
			
			onCompleteFunc = onComplete;
			passThru = vars;
			
			/*if(authenticate){
				vars.user_id = User.id;
				vars.oauth_token = User.oauth_token;
			}*/
			
			//Alert.show(" begin and");
			
			request = new URLRequest("/" + func);
			loader = new URLLoader();
			//loader.dataFormat = URLLoaderDataFormat.VARIABLES;
						
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
			//Alert.show("14");
		}
		
		private function handleComplete(event:Event):void {
			
			var loader:URLLoader = URLLoader(event.target);
			
			//if(event.target.trace && event.target.data)
			
			//Alert.show(loader.data);
			
			var data:Object = JSON.decode(unescape(loader.data));
			
			if(data.response != "success"){
				Alert.show("Error: " + data.response);
				return;
			}
			
			
			//	Alert.show("handleComplete");
			onCompleteFunc(data, passThru);
			
		}
		private function onIOError(event:IOErrorEvent):void {
			Alert.show("Error!!!!!!" + event.text);
		}
		
		private function onSecError(event:Event):void {
			Alert.show("Security Error!!!!!!");
		}
	}
}