package
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.greensock.data.TweenLiteVars;
	import com.greensock.easing.Sine;
	
	import mx.controls.Alert;
	
	import flash.display.MovieClip;
	
	import mx.effects.Tween;
	
	import spark.components.Application;
	import spark.components.Group;
	
	import viewassets.ExperiencePopup;
	import viewassets.LevelPopup;

	public class ExperienceManager
	{
		
		private static var instance:ExperienceManager;
		private var mainParent:Application;
		//private static var 
		/*
		private var mainObjList:Array = new Array();
		private var currentIndex:uint = 0;
		private var currentID:String = "";
		
		private var tutorialPopup:TutorialPopup;
		private var isFinal:Boolean = false;*/
		
		
		public function ExperienceManager() {
			if(instance){
				throw new Error("TutorialManager is singleton. Use TutorialManager.getInstance()");
				return;
			}
			instance = this;
		}
		
		public static function getInstance():ExperienceManager {
			if(instance){
				return instance;
			}else{
				return new ExperienceManager();
			}
		}
		
		public function setParent(mc:Application):void {
			mainParent = mc;
		}
		
		//the placement math in this function is all fucked up. Need to find a better solution at some point
		public function experienceUp(n:uint, userXP:uint, x:Number, y:Number):void {
						
			var xpPopup:ExperiencePopup = new ExperiencePopup();
			
			if(x){
				xpPopup.x = x - xpPopup.width/2;
			}else{
				xpPopup.x = this.mainParent.width/2 + xpPopup.width/2 - 10;
			}
			
			//Alert.show(mainParent.width + " and " + xpPopup.width);
			if(y){
				xpPopup.y = y - xpPopup.height/2;
			}else{
				xpPopup.y = this.mainParent.height/2;
			}
			xpPopup.showExperienceUp(n);
			mainParent.addElement(xpPopup);
			animatePopup(xpPopup);
			
			var updateResult:Boolean = User.getInstance().updateExperienceLevel(userXP);
			if(updateResult){//we've gained an experience level
				var levelPopup:LevelPopup = new LevelPopup();
				levelPopup.x = this.mainParent.width/2 + levelPopup.width/2;
				levelPopup.y = this.mainParent.height/2;
				levelPopup.showLevelUp(User.getInstance().level);
				mainParent.addElement(levelPopup);
				animatePopup(levelPopup, 1);
			}
		}
		
		private function animatePopup(popup:Group, delay:uint = 0):void{
			//var tlv:TweenLiteVars = new TweenLiteVars();
			//tlv.
			//var asfd:TimelineLite = new TimelineLite();
			
			//Alert.show(popup.width + " and " + popup.height)
			
			var newScale:Number = 1.5;
			var newX:Number = popup.x - (popup.width/2)*newScale;
			var newY:Number = popup.y - (popup.height/2)*newScale;
			
			popup.x = popup.x - popup.width/2;
			popup.y = popup.y - popup.height/2;
			
			var timeline:TimelineLite = new TimelineLite();
			
			timeline.append(new TweenLite(popup, .8, {scaleX:newScale, scaleY:newScale, x:newX, y:newY, delay:delay, ease:Sine.easeInOut}));
			timeline.append(new TweenLite(popup, .5, {alpha:0, ease:Sine.easeInOut, onComplete:this.animatePopupComplete, onCompleteParams:[popup]}));
			
		}
		
		private function animatePopupComplete(popup:Group):void{
			this.mainParent.removeElement(popup);
		}
	}
}