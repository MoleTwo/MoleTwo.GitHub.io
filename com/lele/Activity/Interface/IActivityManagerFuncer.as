package com.lele.Activity.Interface
{
	import com.lele.Activity.ActivityData.ActivityUnit;
	
	/**
	 * ...
	 * @author Lele
	 */
	///这个接口不是给Lesp用的  ,,似乎有个漏洞 Lesp用的在IActivityUnitFuncer
	public interface IActivityManagerFuncer 
	{
		function CleanThis(unit:ActivityUnit);
		function ShowBg(url:String);
		function HideBg();
		function ShowStyleBar();
		function HideStyleBar();
		function GetBloodBar(x:Number = 0, y:Number = 0):Object;
		function LoadStartActivity(url:String);
	}
	
}