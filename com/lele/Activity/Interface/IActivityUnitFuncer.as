package com.lele.Activity.Interface
{
	
	/**
	 * ...
	 * @author Lele
	 */
	public interface IActivityUnitFuncer 
	{
		function NextStep(args:Array=null);
		function GotoStep(args:Array);
		function Finish(args:Array = null);
		function InitMisDialog(args:Array);//icoUrl:Array,place:Array, name:String, msg:Array, options:Array, callBacks:Array
		function ShowMisDialog(args:Array=null);//显示dialog
		function HideMisDialog(args:Array=null);//隐藏dialog
		function DisposeMisDialog(args:Array = null);//销毁dialog
		function ShowBg(args:Array);//显示背景
		function HideBg(args:Array = null);//隐藏背景
		function ShowStyleBar(args:Array=null);
		function HideStyleBar(args:Array = null);
		function GetBloodBar(args:Array = null):Object;
		function StartActivity(args:Array);
	}
	
}