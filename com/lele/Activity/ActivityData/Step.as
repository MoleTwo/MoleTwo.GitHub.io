package com.lele.Activity.ActivityData
{
	import com.lele.Plugin.Lesp.LespSpace;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

    public class Step extends Object
    {
        public var ID:String;
        public var Condition:String;
        public var Func:String;
        public var UnFunc:String;
		public var Lesp:LespSpace;
		
		private var timer:Timer;
		private var isProcessing:Boolean;
		
		public function Step()
		{
			isProcessing = false;
		}
		
        public function ToString() : String
        {
            return "Step:" + "\n\tID:" + this.ID + "\n\tCondition:" + this.Condition + "\n\tFunction:" + this.Func + "\n\tUnFunction:" + this.UnFunc +"\n";
        }
		
		public function Start(ctime:int)
		{
			Stop();
			
			timer = new Timer(ctime);
			
			timer.addEventListener(TimerEvent.TIMER, Process);
			
			timer.start();
			
			Process(null);
		}
		
		private function Process(evt:Event)
		{
			if (isProcessing) { return; }
			if (Lesp.ExecFunc(Condition))
			{
				isProcessing = true;
				Lesp.ExecFunc(Func);
				Stop();
			}
			else
			{
				Lesp.ExecFunc(UnFunc);
			}
		}
		
		public function Stop()
		{
			isProcessing = false;
			if (timer != null) { timer.removeEventListener(TimerEvent.TIMER, Process); timer = null; }
		}
    }
}
