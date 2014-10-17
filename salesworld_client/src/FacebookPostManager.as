package
{
	import com.facebook.graph.Facebook;
	
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import mx.controls.Alert;
	
	public class FacebookPostManager
	{
		
		public static var instance:FacebookPostManager;
		
		
		public function FacebookPostManager() {
			if(instance){
				throw new Error("FacebookPostManager is singleton. Use FacebookPostManager.getInstance()");
				return;
			}
			instance = this;
		}
		
		public static function getInstance():FacebookPostManager {
			if(instance){
				return instance;
			}else{
				return new FacebookPostManager();
			}
		}
		
		public function postProduct(oProduct:Object, rawSalesPitch:String):void{
						
			
			
			var url:String = "http://www.facebook.com/dialog/feed";//?app_id=213142532083793&link=http://developers.facebook.com/docs/reference/dialogs/&picture=http://fbrell.com/f8.jpg&name=Facebook%20Dialogs&caption=Reference%20Documentation&description=Using%20Dialogs%20to%20interact%20with%20users.&message=Facebook%20Dialogs%20are%20so%20easy!&redirect_uri=http://inventionsalesworld.appspot.com/post_response";
			
			//var variables:URLVariables = new URLVariables();
			//variables.exampleSessionId = new Date().getTime();
			//url = "http://kalinbooks.com";
			
			
			var request:URLRequest = new URLRequest(url);
			
			//can't figure out why this doesnt' work. It should :(
			var variables:URLVariables = new URLVariables();
			variables.app_id="213142532083793";
			variables.link = "http://apps.facebook.com/wackywords/";//TODO: add param to go directly to the product
			//variables.picture = "http://fbrell.com/f8.jpg";
			
			//value.replace(/<.*?>/g, "");
			variables.name = oProduct.productString
			variables.caption = "Another bright idea from " + oProduct.user_name + " and Wacky Words!";
			variables.description = rawSalesPitch;//oProduct.salesPitch.replace(/<.*?>/g, "");//strip the html out of the sales pitch
			variables.message = "Thank you for posting through Wacky Words!"
			variables.redirect_uri = "http://inventionsalesworld.appspot.com/post_response/";
			request.data = variables;
			
			//Alert.show("postProductsa" + oProduct.salesPitch.replace(/<.*?>/g, ""));
			
			
			request.data = variables;
			navigateToURL(request, "_blank");
			
			
			
		}
	}
}