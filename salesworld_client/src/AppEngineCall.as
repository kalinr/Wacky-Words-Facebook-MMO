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
		
		public static const SUBMIT_WORD:String =  "adminPage/submitWordCard";
		public static const SUBMIT_PRODUCT:String = "submitProduct";
		public static const DRAW_CARD:String = "drawCard";
		public static const GET_PRODUCT:String = "getProduct";
		public static const PRODUCT_VOTE:String = "productVote";
		public static const INVEST:String = "invest";
		public static const BUY_SKILL:String = "buySkill";
		
		public function AppEngineCall(func:String, vars:Object, onComplete:Function, authenticate:Boolean = false, passThruVars:Object = null ):void {
			onCompleteFunc = onComplete;
			if(passThruVars){
				passThru = passThruVars;
			}else{
				passThru = vars;
			}
			
			if(authenticate){
				vars.user_id = User.getInstance().id;
				vars.oauth_token = User.getInstance().oauth_token;
			}
						
			request = new URLRequest("/" + func);
			loader = new URLLoader();
			//loader.dataFormat = URLLoaderDataFormat.VARIABLES;
						
			request.method = URLRequestMethod.POST;
			var variables : URLVariables = new URLVariables();
			
			for(var i:String in vars){
				variables[i] = vars[i];
			}
			request.data = variables;
						
			loader.addEventListener(Event.COMPLETE, handleComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
			loader.load(request);
		}
		
		private function handleComplete(event:Event):void {
			
			var loader:URLLoader = URLLoader(event.target);
						
			var data:Object = JSON.decode(unescape(loader.data));
			
			//Alert.show(loader.data);
			
			if(data.response != "success"){
				Alert.show("What? An error! " + data.response + " Who designed this thing?");
				return;
			}
						
			if(data.experienceUp){
				User.getInstance().skillPoints = data.userSP;
				ExperienceManager.getInstance().experienceUp(data.experienceUp, data.userXP, data.XPx, data.XPy);
				
			}
			
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