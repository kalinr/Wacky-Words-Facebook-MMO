//this is our user model

package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	
	public class User extends EventDispatcher
	{
		
		//example algorithm: xp=50*(1+lvl^2.5) or xp equal first level times one plus current level to the power of something greater than one
		public var mainXPLevels:Array = [700, 1980, 3637, 5600, 7826, 10288, 12964, 15839, 18900, 22136, 25538, 29098, 32811, 36668, 40666, 44800, 49065, 
			53457, 57973, 62610, 67364, 72232, 77213, 82303, 87500, 92802, 98207, 103713, 109319, 115022, 120820, 126714, 132699, 138777, 144944, 151200, 157544, 
			163973, 170488, 177088, 183770, 190534, 197379, 204304, 211308, 218391, 225551, 232788, 240100, 247487, 254949, 262484, 270092, 277772, 285524, 293346, 
			301238, 309200, 317231, 325331, 333498, 341732, 350033, 358400, 366833, 375331, 383893, 392520, 401210, 409963, 418780, 427658, 436599, 445600, 454663, 
			463787, 472971, 482214, 491517, 500879, 510300, 519779, 529316, 538911, 548563, 558272, 568037, 577859, 587737, 597670, 607659, 617703, 627802, 637955, 
			648162, 658423, 668737, 679105, 689526, 700000];
		
		public var skillLevels:Array = [300, 849, 1559, 2400, 3354, 4409, 5556, 6788, 8100, 9487, 10945, 12471, 14062, 15715, 17428, 19200, 21028, 
			22910, 24846, 26833, 28870, 30957, 33091, 35273, 37500];
		
		//public var currentLevel:uint = 1;
		
		//-----user vars (should exactly match User table fields in database)-----------------
		public var id:String;
		public var created:Object;
		public var updated:Object;
		public var upVoteCount:int;
		public var upVoteDailyBonus:int;
		public var upVoteMax:int;
		public var downVoteCount:int;
		public var downVoteDailyBonus:int;
		public var downVoteMax:int;
		public var wordDrawCount:int;
		public var wordDrawDailyBonus:int;
		public var wordDrawMax:int;
		public var wordHandMax:int;
		public var createCount:int;
		public var createDailyBonus:int;
		public var createMax:int;
		public var gold:int;
		public var oauth_token:String;
		public var investmentTokens:int;
		public var experiencePoints:int;
		
		public var skillPoints:int;
		public var upVoteDailyBonus_lvl:int;
		public var upVoteMax_lvl:int;
		public var downVoteDailyBonus_lvl:int;
		public var downVoteMax_lvl:int;
		public var wordDrawDailyBonus_lvl:int;
		public var wordDrawMax_lvl:int;
		public var wordHandMax_lvl:int;
		public var createDailyBonus_lvl:int;
		public var createMax_lvl:int;
		//-----------end user vars-----------------------------------------------------------------
		
		public var level:uint = 1;
		
		//these skill levels are calculated so these vars are basically caching those levels
		/*public var upVoteDailyBonus_level:int;
		public var upVoteMax_level:int;
		public var wordDrawDailyBonus_level:int;
		public var wordDrawMax_level:int;
		public var wordHandMax_level:int;
		public var createDailyBonus_level:int;
		public var createMax_level:int;*/
		
		public var skillTypes:Array = new Array();
		
		private var initialized:Boolean = false;
		private static var instance:User;
		
		public function User()
		{
			if(User.instance){
				throw new Error("User is singleton. Use User.getInstance()");
				return;
			}
			User.instance = this;
		}
		
		public static function getInstance():User {
			if(User.instance){
				return User.instance;
			}else{
				return new User();
			}
		}
		
		public function inputValues(obj:Object):void{
			for(var i:String in obj){
				this[i] = obj[i];
			}	
			
			this.level = this.calculateLevel(mainXPLevels, this.experiencePoints);
			
			if(!this.initialized){
				this.skillTypes = [{name:"Compliment Fishing", field:"upVoteDailyBonus", modifier:1.5, max:25, description:"Gain one extra up vote per level per day."},
{name:"Approval Hoarding", field:"upVoteMax", modifier:1.5, max:25, description:"Increase your maximum up votes by one per level."},

{name:"Condemnation Accumulation", field:"downVoteDailyBonus", modifier:1.5, max:25, description:"Gain one extra down vote per level per day."},
{name:"Blame Monger", field:"downVoteMax", modifier:1.5, max:25, description:"Increase your maximum down votes by one per level."},

{name:"Dictionary Bloating", field:"wordHandMax", modifier:1.5, max:25, description:"Increase the maximum words you can hold at one time by one per level."}

/*,
{name:"Fast Talker", field:"wordDrawDailyBonus", modifier:1.5, max:25, description:"Gain one extra word draw per level per day."},
{name:"Intellectual Sandbagging", field:"wordDrawMax", modifier:1.5, max:25, description:"Increase your maximum saved word draws by one per level."},
{name:"Idea Factory", field:"createDailyBonus", modifier:1.5, max:25, description:"Gain one extra phrase creation per level per day."},
{name:"Mad Scientist", field:"createMax", modifier:1.5, max:25, description:"Increase the maximum saved phrase creations you can hold at one time by one per level."}*/
				];
				this.initialized = true;
			}
		}
		
		public function calculateLevel(skillArr:Array, points:int):uint{
			var l:uint = skillArr.length;
			for(var i:uint = 0; i<l; i++){
				if(points < skillArr[i]){
					return i;
				}
			}
			return l;
		}
		
		public function updateExperienceLevel(n:uint):Boolean {
			this.experiencePoints = n;
			var newLevel:uint = this.calculateLevel(this.mainXPLevels, this.experiencePoints);
			this.dispatchEvent(new Event("experienceUp"));
			//Alert.show("levelUp" + this.level);
			if(newLevel > level){
				//Alert.show("levelUp");
				this.level = newLevel;
				this.dispatchEvent(new Event("levelUp"));
				return true;
			}else{
				return false;
			}
		}
		
		public function updateSkillPoints(n:uint):void{
			this.skillPoints = n;
			//Alert.show("dispatching");
			this.dispatchEvent(new Event("skillPointsUpdated"));
		}
		
		public function get nextLevelValue():uint{
			return this.mainXPLevels[this.level];//array is 0 based so current level refers to next level's xp value
		}
		
		/*public function getNextSkillLevelValue(skillField:String):uint{
			var skillLevel:int = this.calculateLevel(this.skillLevels, this[skillField + "_sp"]);
			return this.skillLevels[skillLevel]
		}*/
		
		public function getNextSkillLevelDifference(skillField:String):uint{
			var skillLevel:int = this[skillField + "_lvl"];//this.calculateLevel(this.skillLevels, this[skillField + "_sp"]);
			//var nextSkillLevel = this.skillLevels[skillLevel];
			var currentSkillValue:int = 0;
			if(skillLevel > 0){
				currentSkillValue = this.skillLevels[skillLevel - 1];
			}
			
			return this.skillLevels[skillLevel] - currentSkillValue;
			
		}
		
		public function get nextLevelPercent():Number {
			var myXP:Number = this.experiencePoints - this.mainXPLevels[this.level - 1];
			var nextXP:Number = this.mainXPLevels[this.level] - this.mainXPLevels[this.level - 1];
				
			return (myXP/nextXP)*100;
		}
		
	}
}