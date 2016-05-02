package com.lele.Manager
{
	import com.lele.Activity.Interface.*;
    import com.lele.Activity.ActivityData.*;
	import com.lele.Container.ActivityContainer;
	import com.lele.Container.ContainerBase;
	import com.lele.Data.GloableData;
	import com.lele.Manager.Events.APIEvent;
    import com.lele.Manager.Interface.*;
    import flash.display.*;
    import flash.events.*;
	import flash.net.URLRequest;

    public class ActivityManager extends Object implements IReport,IActivityManagerFuncer
    {
        private var _movUnits:Array;
        private var _report:IReport;
        private var _resourceLoader:IResourceLoader;
        private var _activityUnits:Array;
		private var _movContainer:ActivityContainer;//同时装载Movie和对话框
		private var _backGroundSp:Sprite;
		private var _styleBarSp:Sprite;
		private var _misDialogSp:Sprite;
		private var	_styleBar:Sprite;
		private var _bgLoader:Loader;
		private var _misDialogClass:Class;
		private var _misDialog:INpcDialog;
		private var _bloodBarClass:Class;
		
		//关于，水战活动，blood <0时，表示不显示血条，即没有进入水战模式，那么，服务器端初始值为-1,玩家加入时，多加一个信息段 blood
		
        public function ActivityManager(loader:IResourceLoader, repoter:IReport,highMovContainer:ActivityContainer)//暂时不给Lezaisp 加载调用资源文件直接的权限
        {
			_movContainer = highMovContainer;
			
			_backGroundSp = _movContainer.GetContainer();
			
			_styleBarSp = _movContainer.GetContainer();
			_styleBar = new Sprite();
			_styleBar.graphics.beginFill(0x000000);
			_styleBar.graphics.drawRect(0, 0, 960, 60);
			_styleBar.graphics.drawRect(0, 480, 960, 60);
			_styleBar.graphics.endFill();
			
			_misDialogSp = _movContainer.GetContainer();
			
			_bgLoader = new Loader();
            _activityUnits = new Array();
            _movUnits = new Array();
            _resourceLoader = loader;
            _report = repoter;
			
			//load dialog
			var temploader:Loader = new Loader();
			temploader.contentLoaderInfo.addEventListener(Event.COMPLETE, OnMisDialogLoaded);
			var request:URLRequest = new URLRequest("Activity/Res/MissionDialog_app.swf");
			temploader.load(request);
			//load blood bar
			var bloodBarLoader:Loader = new Loader();
			bloodBarLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, OnBloodBarLoaded);
			var bloodBarReq:URLRequest = new URLRequest("Activity/Res/BloodBar_app.swf");
			bloodBarLoader.load(bloodBarReq);
        }
		
		private function OnMisDialogLoaded(evt:Event)
		{
			(evt.target as LoaderInfo).removeEventListener(Event.COMPLETE, OnMisDialogLoaded);
			_misDialogClass = (evt.target as LoaderInfo).applicationDomain.getDefinition("MisDialog") as Class;
			_misDialog = new _misDialogClass();
			_misDialog.Container = _misDialogSp;
		}
		private function OnBloodBarLoaded(evt:Event)
		{
			(evt.target as LoaderInfo).removeEventListener(Event.COMPLETE, OnBloodBarLoaded);
			_bloodBarClass = (evt.target as LoaderInfo).applicationDomain.getDefinition("Bar") as Class;
		}
		
		
		
		///接口方法
		public function CleanThis(unit:ActivityUnit)
		{
			for (var a:int = 0; a < _activityUnits.length; a++ )
			{
				if (_activityUnits[a] == unit)
				{
					_activityUnits.splice(a, 1);
					return;
				}
			}
		}
		public function ShowBg(url:String)
		{
			_bgLoader.unloadAndStop();
			_bgLoader = new Loader();
			var request:URLRequest = new URLRequest(url);
			var comp:Function=function(evt:Event)
			{
				while (_backGroundSp.numChildren > 0) { _backGroundSp.removeChildAt(0); }
				_backGroundSp.addChild(evt.target.content);
				_bgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, comp);
			}
			_bgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, comp);
			_bgLoader.load(request);
		}
		public function HideBg()
		{
			while (_backGroundSp.numChildren > 0) { _backGroundSp.removeChildAt(0); }
			_bgLoader.unloadAndStop();
			_bgLoader = new Loader();
		}
		public function ShowStyleBar()
		{
			while (_styleBarSp.numChildren > 0) { _styleBarSp.removeChildAt(0); }
			_styleBarSp.addChild(_styleBar);
		}
		public function HideStyleBar()
		{
			while (_styleBarSp.numChildren > 0) { _styleBarSp.removeChildAt(0); }
		}
		
		//加载并播放视频
        public function LoadPlayMovie(url:String, useUI:Boolean = false, UIType:String = "NULL", onFinish:Function = null)
        {
            var movu:MovieUnit = new MovieUnit(_resourceLoader, onFinish, url, _movContainer.GetContainer(), useUI, UIType);
            _movUnits.push(movu);
        }
		
        public function OnReport(event:Event) : void
        {
            return;
        }
		
		//加载并开始活动
        public function LoadStartActivity(url:String)
        {
            var actUnit:ActivityUnit = new ActivityUnit(_resourceLoader, this);
			if (_misDialogClass != null) 
			{
				actUnit._IMisDialog = _misDialog;
			}
            actUnit.LoadStart(url);
        }
		
		//initMisDialog
		public function InitMisDialog(icoUrl:Array,place:Array, name:String, msg:String,msgCallBack:Function, options:Array, callBacks:Array)//icoUrl:Array,place:Array, name:String, msg:Array, options:Array, callBacks:Array
		{
			if (_misDialog == null) { return; }
			_misDialog.Init(icoUrl, place, name, msg,msgCallBack, options, callBacks);
		}
		//showMisDialog
		public function ShowMisDialog()
		{
			if (_misDialog != null) { _misDialog.Show(); }
		}
		//hideMisDialog
		public function HideMisDialog()
		{
			if (_misDialog != null) { _misDialog.Hide(); }
		}
		//dispose
		public function DisposeMisDialog()
		{
			if (_misDialog != null) { _misDialog.Dispose();}
		}
		
		//水战活动部分
		public function GetBloodBar(x:Number=0, y:Number=0):Object
		{
			if (_bloodBarClass != null) 
			{ 
				var bar = new _bloodBarClass(); 
				bar.x = x;
				bar.y = y;
				return bar;
			}
			return null;
		}

    }
}

import flash.events.Event;
import flash.display.Sprite;
import flash.display.MovieClip;
import com.lele.Manager.Interface.IResourceLoader

class MovieUnit extends Object
{
    private var _resourceLoader:IResourceLoader;
    private var _onFinish:Function;
    private var _container:Sprite;
    private var _unitUrl:String;
    private var _mov:MovieClip;

    function MovieUnit(loader:IResourceLoader, onFinish:Function, url:String, container:Sprite, useUI:Boolean, UIType:String)
    {
        _container = container;
        _onFinish = onFinish;
        _unitUrl = url;
        _resourceLoader = loader;
        _resourceLoader.LoadResource("ActivityManager", url, OnComplete, useUI, UIType);
    }
	
    private function OnComplete(event:Event)
    {
        var evt:Event = event;
        _mov = evt.target.content as MovieClip;
        _container.addChild(_mov);
        _mov.addFrameScript((_mov.totalFrames - 1), function ()
        {
            _mov.stop();
            _container.removeChild(_mov);
            if (_onFinish != null)
            {
                _onFinish();
            }
            _resourceLoader.UnLoadResource("ActivityManager", _unitUrl);
        });
    }
}

