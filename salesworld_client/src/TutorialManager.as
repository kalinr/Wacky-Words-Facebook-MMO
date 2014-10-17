package{
	import com.greensock.TweenNano;
	import com.greensock.easing.Back;
	import com.greensock.easing.Sine;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.controls.Alert;
	
	import viewassets.TutorialPopup;

	public class TutorialManager{
		
		private static var instance:TutorialManager;
		
		private var mainObjList:Array = new Array();
		private var currentIndex:uint = 0;
		private var currentID:String = "";
		
		private var tutorialPopup:TutorialPopup;
		private var isFinal:Boolean = false;
		
		public function TutorialManager(){
			if(instance){
				throw new Error("TutorialManager is singleton. Use TutorialManager.getInstance()");
				return;
			}
			instance = this;
			
			tutorialPopup = new TutorialPopup();
			tutorialPopup.visible = false;
			
			tutorialPopup.addEventListener(TutorialPopup.TUTORIAL_CLOSE, handleTutorialPopupClose);
			tutorialPopup.addEventListener(TutorialPopup.TUTORIAL_NEXT, handleTutorialPopupNext);
		}
		
		public static function getInstance():TutorialManager{
			//Alert.show("get instance");
			if(instance){
				return instance;
			}else{
				return new TutorialManager();
			}
		}
		
		public function addSequence(obj:Object, identifier:String):void{
			mainObjList[identifier] = obj;
			//trace("adding sequence");
		}
		
		public function setParent(mc:*):void{
			mc.addElement(tutorialPopup);
		}
		
		public function beginSequence(identifier:String):void{
			//Alert.show("begin sequence");
			currentID = identifier
			currentIndex = 0;
			loadCurrentItem();
			tutorialPopup.visible = true;
			
			//var asdf:Alert
		}
		
		private function loadCurrentItem():void{
			isFinal = currentIndex >= mainObjList[currentID].itemList.length - 1
			tutorialPopup.load(mainObjList[currentID].itemList[currentIndex], isFinal);
						
			var arrowLocation:String = "";
			var currentObj:Object = mainObjList[currentID].itemList[currentIndex];
			var currentTarget:* = currentObj.target;
			
			if(!currentTarget){
				currentTarget = new Rectangle(currentObj.x, currentObj.y, 0, 0);
			}
			
			var prevX:Number = tutorialPopup.x;
			var prevY:Number = tutorialPopup.y;
			
			if(currentObj.orientation){
				/*switch(currentObj.orientation){
					case "bottom_middle":
						tutorialPopup.y = currentTarget.y - tutorialPopup.height - 10;
						arrowLocation = "bottom_middle";
						break;
				}*/
			}else{
				if(currentTarget.y <= tutorialPopup.parent.height/2 - currentTarget.height/2){
					tutorialPopup.y = currentTarget.y + currentTarget.height + 10;
					arrowLocation = "top_";
				}else{
					tutorialPopup.y = currentTarget.y + currentTarget.height/2 - tutorialPopup.border.height/2;
					arrowLocation = "bottom_";
				}
								
				if(currentTarget.x <= tutorialPopup.parent.width/2 - currentTarget.width/2){
					tutorialPopup.x = currentTarget.x + currentTarget.width + 10;
					arrowLocation += "left";
				}else{
					tutorialPopup.x = currentTarget.x - tutorialPopup.border.width - 10;
					arrowLocation += "right";
				}
			}
			
			if(currentIndex == 0){
				var fromX:Number = tutorialPopup.x + tutorialPopup.width/2;
				var fromY:Number = tutorialPopup.y + tutorialPopup.height/2;
				tutorialPopup.alpha = 1;
				tutorialPopup.scaleX = tutorialPopup.scaleY = 1;
				TweenNano.from(tutorialPopup, .3, {scaleX:.1, scaleY:.1, alpha:0, x:fromX, y:fromY, ease:Back.easeOut});
			}else{
				TweenNano.from(tutorialPopup, .3, {x:prevX, y:prevY, ease:Back.easeOut});
			}
			
			tutorialPopup.setArrowLocation(arrowLocation);
		}
		
		private function handleTutorialPopupNext(evt:Event):void{
			currentIndex++;
			if(currentIndex >= mainObjList[currentID].itemList.length){
				handleTutorialPopupClose(null);
			}else{
				loadCurrentItem();
			}			
		}
		
		private function handleTutorialPopupClose(evt:Event):void{
			currentIndex = 0;
			var toX:Number = tutorialPopup.x + tutorialPopup.width/2;
			var toY:Number = tutorialPopup.y + tutorialPopup.height/2
			TweenNano.to(tutorialPopup, .2, {scaleX:.1, scaleY:.1, x:toX, y:toY, alpha:0, ease:Sine.easeInOut, onComplete:onCloseComplete});
		}
		
		private function onCloseComplete():void{
			tutorialPopup.visible = false;
		}
	}
}