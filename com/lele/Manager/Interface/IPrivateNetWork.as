package com.lele.Manager.Interface
{
	/**
	 * ...
	 * @author Lele
	 */
	public interface IPrivateNetWork 
	{
		function Release(id:String);
		function PrivateSend(evtName:String, paramName:Array, paramValue:Array, id:String);
		function GetPrivateNetPort(callBack:Function):String
	}
	
}