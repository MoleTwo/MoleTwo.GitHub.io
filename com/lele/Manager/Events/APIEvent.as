package com.lele.Manager.Events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Lele
	 */
	public class APIEvent extends Event 
	{
		public static const OnMapChange:String = "onmapchange";
		
		
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