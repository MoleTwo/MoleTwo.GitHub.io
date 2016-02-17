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
		function Finish(args:Array=null);
	}
	
}