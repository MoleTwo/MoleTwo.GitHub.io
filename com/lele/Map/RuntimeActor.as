package com.lele.Map
{
	import com.lele.Map.Interface.IClickAble;
	/**
	 * ...
	 * @author Lele
	 */
	public class RuntimeActor extends MaskedObj implements IClickAble
	{
		public var onClick:Function;
		
		public function RuntimeActor() 
		{
			
		}
		
		public function get _y():Number
		{
			return this.y;
		}
		public function get _x():Number
		{
			return this.x;
		}
		public function get _width():Number
		{
			return this.width;
		}
		public function get _height():Number
		{
			return this.height;
		}
		public function OnClick():Boolean
		{
			if (onClick != null) { onClick(); }
			return true;
		}
		
	}

}