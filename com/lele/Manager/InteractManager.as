package com.lele.Manager
{
	import com.lele.Data.GloableData;
	import com.lele.Manager.Interface.IResourceLoader;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.lele.Manager.Interface.IReport;
	import flash.display.Sprite;
	import flash.events.Event;
	import com.lele.Container.ContainerBase;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	/**
	 * ...
	 * @author Lele
	 */
	public class InteractManager extends Sprite implements IReport
	{
		private var _repoter:IReport;
		private var _container:ContainerBase;
		private var _clickStyle:Class;
		private var _interectResLoader:Loader;
		
		public function InteractManager(report:IReport,interactContainer:ContainerBase) 
		{
			_repoter = report;
			_container = interactContainer;
			
			_interectResLoader = new Loader();
		}
		
		public function LoadRes(url:String)
		{
			var req:URLRequest = new URLRequest(url);
			_interectResLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, OnLoaded);
			_interectResLoader.load(req);
		}
		private function OnLoaded(evt:Event)
		{
			_interectResLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, OnLoaded);
			_clickStyle = _interectResLoader.contentLoaderInfo.applicationDomain.getDefinition("MouseClick") as Class;
		}
		
		public function OnReport(evt:Event):void
		{
			
		}
		
		//click effect
		public function OnMapClick(position:Point)
		{
			if (_clickStyle == null) { return; }
			var mc = new _clickStyle();
			(mc as MovieClip).x = position.x+GloableData.MapOffSetX;
			(mc as MovieClip).y = position.y+GloableData.MapOffSetY;
			(mc as MovieClip).addFrameScript(6, function()
			{
				(mc as MovieClip).stop();
				_container.removeChild(mc);
			});
			_container.addChild(mc);
		}
		
		
		public function MouseClickMode(style:Sprite, OnClick:Function)
		{
			var sjb:Sprite = new Sprite();//这个过来的sprite有病，会发癫
			sjb.addChild(style);
			var _OnClick:Function = function(evt:MouseEvent):void{
				OnClick(new Point(mouseX-GloableData.MapOffSetX,mouseY-GloableData.MapOffSetY)); 
				sjb.removeEventListener(MouseEvent.CLICK, _OnClick);
			}
			
			sjb.addEventListener(Event.ENTER_FRAME, MouseClickMode_everyFrame);
			sjb.addEventListener(MouseEvent.CLICK, MouseClickMode_onClick);
			sjb.addEventListener(MouseEvent.CLICK, _OnClick);
			
			_container.addChild(sjb);
			
			Mouse.hide();
		}
		private function MouseClickMode_onClick(evt:MouseEvent)
		{
			(evt.target as Sprite).removeEventListener(MouseEvent.CLICK, MouseClickMode_onClick);
			(evt.target as Sprite).removeEventListener(Event.ENTER_FRAME, MouseClickMode_everyFrame);
			(evt.target as Sprite).parent.removeChild((evt.target as Sprite));
			Mouse.show();
		}
		private function MouseClickMode_everyFrame(evt:Event)
		{
			(evt.target as Sprite).x = mouseX-(evt.target as Sprite).width/2; 
			(evt.target as Sprite).y = mouseY-(evt.target as Sprite).height/2;
		}
		
	}

}