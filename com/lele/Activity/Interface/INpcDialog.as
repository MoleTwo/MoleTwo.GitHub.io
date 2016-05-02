package com.lele.Activity.Interface
{
	import flash.display.Sprite;
	
	/**
	 * ...与npc的对话框
	 * @author Lele
	 */
	public interface INpcDialog 
	{
		function Show();
		function Hide();
		function Init(icoUrls:Array,places:Array, name:String, msg:String,msgCallBack:Function, options:Array, callBacks:Array);
		function Dispose();
		function set Container(sp:Sprite);
	}
	
}