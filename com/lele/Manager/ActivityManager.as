package com.lele.Manager
{
	import com.lele.Activity.Interface.*;
    import com.lele.Activity.ActivityData.*;
	import com.lele.Container.ContainerBase;
	import com.lele.Data.GloableData;
    import com.lele.Manager.Interface.*;
    import flash.display.*;
    import flash.events.*;

    public class ActivityManager extends Object implements IReport,IActivityManagerFuncer
    {
        private var _movUnits:Array;
        private var _report:IReport;
        private var _resourceLoader:IResourceLoader;
        private var _activityUnits:Array;
		private var _movContainer:ContainerBase;
		
        public function ActivityManager(loader:IResourceLoader, repoter:IReport,highMovContainer:ContainerBase)
        {
			_movContainer = highMovContainer;
            _activityUnits = new Array();
            _movUnits = new Array();
            _resourceLoader = loader;
            _report = repoter;
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
            var actUnit:ActivityUnit = new ActivityUnit(_resourceLoader,this);
            actUnit.LoadStart(url);
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

