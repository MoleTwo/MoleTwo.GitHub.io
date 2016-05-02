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
		function InitMisDialog(args:Array);//icoUrl:Array,place:Array, name:String, msg:Array, options:Array, callBacks:Array
		function ShowMisDialog(args:Array=null);//显示dialog
		function HideMisDialog(args:Array=null);//隐藏dialog
		function DisposeMisDialog(args:Array = null);//销毁dialog
		function TurnDark(args:Array = null);//画面变暗
		function TurnBright(args:Array = null);//画面变亮
		function ShowToolBar(args:Array = null);
		function HideToolBar(args:Array = null);
		function ShowDialog(args:Array);// type:emoy mis   url:/emo:  txt: callBack:
		function UpdateMapPosition(args:Array = null);//更新地图位置
		function AttachTo(args:Array);// sp:sprite  id:string //将某个sprite附加到某个avatar上
		function GetNetPort(args:Array):String; //function(callback) 
		function ReleaseNetPort(args:Array);//id
		function NetSend(args:Array); //(evtName:String, length:String, pv:String, id:String)
		
	}
	
}