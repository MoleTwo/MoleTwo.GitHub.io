package com.lele.Container
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Lele
	 */
	public class ActivityContainer extends Sprite
	{
		private var _containers:Array;
		
		public function ActivityContainer() 
		{
			_containers = new Array();
		}
		
		override public function addChild(child:DisplayObject):DisplayObject 
		{
			return GetContainer().addChild(child);
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject 
		{
			for (var a:int = 0; a < _containers.length; a++ )
			{
				if ((_containers[a] as Sprite).contains(child))
				{
					(_containers[a] as Sprite).removeChild(child);
					//进行重排
					/*var tempArray:Array = _containers;
					_containers = new Array();
					for (var t:int = 0; t < tempArray.length; t++)
					{
						if ((tempArray[t] as Sprite).numChildren > 0)
						{
							_containers.push(tempArray[t]);
						}
						else
						{
							super.removeChild(tempArray[t]);
						}
					}
					*/
					
					return child;
				}
			}
			return null;
		}
		
		public function GetContainer():Sprite
		{
			var newContainer:Sprite = new Sprite();
			_containers.push(newContainer);
			super.addChild(newContainer);
			return newContainer;
		}
	}

}