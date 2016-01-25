package com.lele.Plugin.Mole
{
	import flash.display.Sprite;
	import fl.motion.Color;
	/**
	 * ...
	 * @author Lele
	 */
	public class MolePic extends Sprite
	{
		private var _body:Sprite;
		
		public function MolePic() 
		{
			_body = getChildByName("skee0_mc") as Sprite;
		}
		
		public function SetColor(color:String)
		{
			var co:Color;
			switch(color)
			{
				case "blue":
				{
					co = new Color(0.109803, 0.705882, 0.992156);
					break;
				}
				case "white":
				{
					co = new Color(1, 1, 1);
					break;
				}
				case "black":
				{
					co = new Color(0, 0, 0);
					break;
				}
				case "orange":
				{
					co = new Color(0.988, 0.494, 0.094);
					break;
				}
				case "green":
				{
					co = new Color(0.152, 0.913, 0.454);
					break;
				}
				case "red":
				{
					co = new Color(0.890, 0.133, 0.066);
					break;
				}
				case "brown":
				{
					co = new Color(0.705, 0.490, 0.164);
					break;
				}
				case "purple":
				{
					co = new Color(0.807, 0.152, 0.811);
					break;
				}
				case "grey":
				{
					co = new Color(0.639, 0.627, 0.635);
					break;
				}
				case "pink":
				{
					co = new Color(0.952, 0.301, 0.592);
					break;
				}
			}
			_body.transform.colorTransform = co;
		}
		
	}

}