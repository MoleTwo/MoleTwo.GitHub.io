package com.lele.Activity.ActivityData
{
	import flash.geom.Point;

    public class Entrance extends Object
    {
        public var Map:String;
        public var Display:String;
		public var Position:Point;
        public var OnTrigger:String;

        public function ToString() : String
        {
            return "Entrance:\n" + "\t" + "Map:" + this.Map+"\n\t"+this.Position + "\n\tDisplay:" + this.Display + "\n\tOnTrigger:" + this.OnTrigger + "\n";
        }

    }
}
