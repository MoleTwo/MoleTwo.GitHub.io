package com.lele.Manager.Interface
{
	import com.lele.Map.RuntimeActor;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Lele
	 */
	public interface ICommand 
	{
		function GotoMap(args:Array);//(map:String, spawnPosition:Point, callBack:Function = null);
		function AddActorToMap(args:Array);//(actor:RuntimeActor, place:Point, callBack:Function = null );
		function AddActorUrlToMap(args:Array);//(packUrl:String, item:String, place:Point, callBack:Function = null);
		function CloseCurrentMapSound(args:Array=null);//(callBack:Function = null);
		function PlayMp3(args:Array);//(url:String, times:int,callBack:Function = null);
		function CloseMp3(args:Array=null);//(callBack:Function = null);
		function PlayApp(args:Array);//(url:String, param:Array = null,callBack:Function = null);
		function PlayMovie(args:Array);//(url:String,callBack:Function = null)//param 第一个，如果param有，则为OnFinish回调!
		function PlayActivity(args:Array);//(url:String);
		function MoveTo(args:Array);//(point:Point) 移动到
		function DoAction(args:Array);//(actionName:String,direction:String,callBack:Function)
		function ShowMsg(args:Array);//(msg:String)
	}
	
}