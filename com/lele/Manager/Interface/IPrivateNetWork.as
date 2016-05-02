package com.lele.Manager.Interface
{
	/**
	 * ...
	 * @author Lele
	 */
	public interface IPrivateNetWork 
	{
		function Release(id:String);
		function PrivateSendStr(evtName:String, length:String, pv:String, id:String) //das;asd;asd;adss
		function PrivateSend(evtName:String, paramName:Array, paramValue:Array, id:String);
		function GetPrivateNetPort(callBack:Function):String
	}
	
}