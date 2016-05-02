package com.lele.Manager.Events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Lele
	 */
	public class APIEvent extends Event 
	{
		public static const OnMapChange:String = "OnMapChange";
		public static const OnPlayerAdded:String = "OnPlayerAdded";
		public static const OnHurt:String = "OnHurt"; //玩家自身onhurt
		public static const OnPlayerRemove:String = "OnPlayerRemove";
		//活动事件
		public static const OnSetBlood:String = "OnSetBlood";
		
		public var data:Object;
		
		public function APIEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);	
		}
		
		public override function clone():Event 
		{ 
			return new APIEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("APIEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}