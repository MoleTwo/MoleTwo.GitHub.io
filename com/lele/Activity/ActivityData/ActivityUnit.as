package com.lele.Activity.ActivityData
{
	import com.lele.Activity.Interface.IActivityUnitFuncer;
	import com.lele.Activity.Interface.INpcDialog;
	import com.lele.Data.GloableData;
	import com.lele.Manager.Events.APIEvent;
	import com.lele.Activity.Interface.IActivityManagerFuncer;
    import com.lele.Manager.*;
    import com.lele.Manager.Interface.*;
	import com.lele.Map.RuntimeActor;
	import com.lele.Plugin.collections.HashMap;
	import com.lele.Plugin.Lesp.LespSpace;
    import flash.events.*;
	import flash.geom.Point;
    import flash.net.*;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

    public class ActivityUnit implements IActivityUnitFuncer
    {
		public var _lesp:LespSpace;
		public var _IMisDialog:INpcDialog;
		public var _Enable:Boolean;//标识活动是否开始
		public var _ValueMap:Object;
        public var _ActivityManager:IActivityManagerFuncer;
        public var _ResLoader:IResourceLoader;
        public var _LoadLefts:int;
        public var _loaderUnits:Array;
		public var _PreLoadUnits:Array;
        public var _Arts:Array;
        public var _Loader:URLLoader;
        public var _XML:XML;
        public var _Config:Config;
        public var _Includes:Array;
		public var _PreLoad:Array;
        public var _Entrances:Array;
        public var _Step:Array;
		public var _Init:String;//初始化语句
		public var _Finish:String//结束语句
        public var _CurrentStep:String;//这个记录ID
		public var _CurrentStepObj:Step;//这个保存本体

        public function ActivityUnit(resLoader:IResourceLoader,actFuncer:IActivityManagerFuncer)
        {
			GameManager.GetEventDispatcher().addEventListener(APIEvent.OnMapChange, OnMapChanged);
			_lesp = new LespSpace();
			_ValueMap = new Object();
			_ActivityManager = actFuncer;
            _loaderUnits = new Array();
			_PreLoadUnits = new Array();
            _ResLoader = resLoader;
            _LoadLefts = 0;
            _Arts = new Array();
            _Loader = new URLLoader();
			
			_lesp.LoadObj(this as IActivityUnitFuncer);
			_lesp.LoadObj(GameManager.GetICommand());
			_CurrentStep = "-1";
        }
		
		///IActivityUnitFuncer
		public function StartActivity(args:Array) //url
		{
			var str:String = args[0];
			str = str.charAt(0) == "@"?_Config.Root + str.substr(1, str.length):str;
			_ActivityManager.LoadStartActivity(str);
		}
		public function NextStep(args:Array = null)
		{
			var nextStep:String;
			try { nextStep = String(int(_CurrentStep) + 1); } catch (er:Error) { return; }
			var next:Step = GetStep(nextStep);
			if (next == null) { return; }
			next.Start(GloableData.ActivityConditionTime);
			_CurrentStepObj = next;
			_CurrentStep = String(int(_CurrentStep) + 1);
		}
		public function GotoStep(args:Array)
		{
			var next:Step = GetStep(args[0]);
			if (next == null) { return; }
			if(_CurrentStepObj!=null)
				_CurrentStepObj.Stop();
			_CurrentStep = args[0];
			next.Start(GloableData.ActivityConditionTime);
		}
		public function Finish(args:Array = null)
		{
			_lesp.ExecFunc(_Finish);
			if (_CurrentStepObj != null) { _CurrentStepObj.Stop(); }
			_lesp.Clean();
			Clean();
		}
		public function InitMisDialog(args:Array)//icoUrl:Array,place:Array, name:String, msg:String, msgCallBack:Func, options:Array, callBacks:Array
		{
			var array:Array = new Array();
			for (var a:int = 0; a < (args[6] as Array).length; a++)
			{
				array.push(_lesp.ExecFunc("#(GenerateFunction " + (args[6] as Array)[a] + ")"));
			}
			args[6] = array;
			args[4] = _lesp.ExecFunc("#(GenerateFunction " + (args[4]) + ")");
			_IMisDialog.Init(args[0], args[1], args[2], args[3], args[4], args[5],args[6]);
		}
		public function ShowMisDialog(args:Array = null)//显示dialog
		{
			_IMisDialog.Show();
		}
		public function HideMisDialog(args:Array = null)//隐藏dialog
		{
			_IMisDialog.Hide();
		}
		public function DisposeMisDialog(args:Array = null)//销毁dialog
		{
			_IMisDialog.Dispose();
		}
		public function ShowBg(args:Array)//显示背景
		{
			_ActivityManager.ShowBg(args[0]);
		}
		public function HideBg(args:Array = null)//隐藏背景
		{
			_ActivityManager.HideBg();
		}
		public function ShowStyleBar(args:Array=null)
		{
			_ActivityManager.ShowStyleBar();
		}
		public function HideStyleBar(args:Array=null)
		{
			_ActivityManager.HideStyleBar();
		}
		public function GetBloodBar(args:Array = null):Object
		{
			if(args==null)
				return _ActivityManager.GetBloodBar();
			else
				return _ActivityManager.GetBloodBar(args[0], args[1]);
		}
		/////
		
		
		
		
		public function Clean()
		{
			_Loader = null;
			for (var a:int = 0; a < _Step.length; a++ )
			{
				(_Step[a] as Step).Stop();
			}
			_ValueMap = null;
			for (var a:int = 0; a < _loaderUnits.length; a++ )
			{
				(_loaderUnits[a] as ResLoaderUnit).Clean();
			}
			_IMisDialog.Hide();
			_IMisDialog.Dispose();
			_IMisDialog = null;
			GameManager.GetEventDispatcher().removeEventListener(APIEvent.OnMapChange, OnMapChanged);
			_ActivityManager.CleanThis(this);
		}
		
		private function GetStep(id:String):Step
		{
			for (var a:int = 0; a < _Step.length; a++ )
			{
				if ((_Step[a] as Step).ID == id)
				{
					return _Step[a];
				}
			}
			return null;
		}
		
        private function OnLoaded(event:Event)
        {
			_Loader.removeEventListener(Event.COMPLETE, OnLoaded);
            Init(XML(event.target.data));
            _Loader.removeEventListener(Event.COMPLETE, this.OnLoaded);
            var reg:RegExp = /_.*\./;
			_LoadLefts = 0;
			if(_Includes!=null)
				_LoadLefts += _Includes.length;
			GameManager.GetICommand().TurnDark();
			if (_PreLoad != null && _PreLoad.length > 0)
			{
				_LoadLefts += _PreLoad.length;
			}
			if (_LoadLefts == 0) { _LoadLefts = 1; LoadedCheck(); }
			if (_Includes != null)
			{
				for (var a:int = 0; a < _Includes.length;a++ )
				{
					switch(String(reg.exec(_Includes[a])).substr(1,String(reg.exec(_Includes[a])).length-2))
					{
						case "func":
						{
							if (_Includes[a].charAt(0) == "@")
							{
								_lesp.LoadPack(_Config.Root+String(_Includes[a]).substr(1,String(_Includes[a]).length), LoadedCheck);
							}
							else
							{
								_lesp.LoadPack(_Includes[a], LoadedCheck);
							}
							break;
						}
						case "art":
						{
							var loaderUnit:ResLoaderUnit;
							if (_Includes[a].charAt(0) == "@")
							{
								loaderUnit = new ResLoaderUnit(_ResLoader, _Config.Root+String(_Includes[a]).substr(1,String(_Includes[a]).length), _Arts, LoadedCheck);
							}
							else
							{
								loaderUnit = new ResLoaderUnit(_ResLoader, _Includes[a], _Arts, LoadedCheck);
							}
							_loaderUnits.push(loaderUnit);
							break;
						}
					}
				}
			}
			if (_PreLoad != null && _PreLoad.length > 0)
			{
				for (var a:int = 0; a < _PreLoad.length; a++ )
				{
					var str:String = _PreLoad[a];
					str = str.charAt(0) == "@"?_Config.Root + str.substr(1, str.length):str;
					var preLoad:PreLoadUnit = new PreLoadUnit(_ResLoader, str, LoadedCheck);
					_PreLoadUnits.push(preLoad);
				}
			}
            return;
        }
		
		//开始执行事件
        private function LoadedCheck()
        {
			_LoadLefts--;
            if (_LoadLefts != 0) { return; }
			GameManager.GetICommand().TurnBright();
			_PreLoadUnits = new Array();
			_Enable = true;
			OnMapChanged(null);
			if ((_Entrances == null || _Entrances.length == 0)&&_Step!=null&&_Step.length!=0) { GotoStep([0]); }
			///load 之后开始执行
        }

        public function LoadStart(url:String)
        {
            _Loader.addEventListener(Event.COMPLETE, OnLoaded);
            var request:URLRequest = new URLRequest(url);
            _Loader.load(request);
        }
		
		//当地图改变,这里有错误，还有换图时存在bug
		public function OnMapChanged(evt:APIEvent)//#(PlayActivity Activity/Story/M10001/M10001.xml)
		{
			if (_Entrances == null || _Entrances.length == 0) { return; }
			for (var a:int = 0; a < _Entrances.length; a++ )
			{
				if ((_Entrances[a] as Entrance).Map == GloableData.CurrentMap)
				{
					GameManager.GetICommand().AddActorToMap([GetRuntimActor((_Entrances[a] as Entrance).Display), 
					(_Entrances[a] as Entrance).Position,OnMapChangedHelp((_Entrances[a] as Entrance).OnTrigger)]);
				}
			}
		}
		private function OnMapChangedHelp(func:String):Function
		{
			return function() { _lesp.ExecFunc(func); };
		}
		//  ,,,,,,,,,,,,,,,,,,,,
		
		
		private function GetRuntimActor(className:String):RuntimeActor
		{
			var act:RuntimeActor;
			for (var a:int = 0; a < _Arts.length; a++ )
			{
				try
				{
					var temp:Class = (_Arts[a] as ApplicationDomain).getDefinition(className) as Class;
					act = new temp();
					return act;
				}
				catch(er:Error){}
			}
			throw new Error("No such Item");
		}
		
        private function Init(xml:XML)
        {
            var entrance:Entrance = null;
            var step:Step = null;
            var _loc_5:int = 0;
            var _loc_6:int = 0;
            _XML = xml;
			_Init = xml.Init;
			_Finish = xml.Finish;
            _Config = new Config();
            _Config.Root = this.Conver(xml.Config.Root);
			_lesp.ExecFunc("#(SetRoot " + _Config.Root + ")");
            _Includes = new Array();
			_PreLoad = new Array();
            var counter:int = 0;
            if (String(xml.Include.PackUrl) == "")
            {
                this._Includes = null;
            }
            else
            {
                while (xml.Include.PackUrl[counter] != undefined)
                {
                    this._Includes.push(this.Conver(xml.Include.PackUrl[counter]));
                    counter++;
                }
            }
            counter = 0;
			if (String(xml.PreLoad.Url) == "")
			{
				this._PreLoad = null;
			}
			else
			{
				while (xml.PreLoad.Url[counter] != undefined)
				{
					this._PreLoad.push(xml.PreLoad.Url[counter]);
					counter++;
				}
			}
			counter = 0;
            this._Entrances = new Array();
            if (String(xml.SetupEntrance.Entrance) == "")
            {
                this._Entrances = null;
            }
            else
            {
                while (xml.SetupEntrance.Entrance[counter] != undefined)
                {
                    entrance = new Entrance();
					entrance.Position=new Point(Number(String(xml.SetupEntrance.Entrance[counter].Position).split(",")[0]),Number(String(xml.SetupEntrance.Entrance[counter].Position).split(",")[1]))
                    entrance.Display = this.Conver(xml.SetupEntrance.Entrance[counter].Display);
                    entrance.Map = this.Conver(xml.SetupEntrance.Entrance[counter].Map);
                    entrance.OnTrigger = this.Conver(xml.SetupEntrance.Entrance[counter].OnTrigger);
                    this._Entrances.push(entrance);
                    counter++;
                }
            }
            counter = 0;
            this._Step = new Array();
            if (String(xml.Step.Sp) == "")
            {
                this._Step = null;
            }
            else
            {
                while (xml.Step.Sp[counter] != undefined)
                {
                    step = new Step();
                    step.Condition = this.Conver(xml.Step.Sp[counter].Condition);
                    step.Func = this.Conver(xml.Step.Sp[counter].Function);
                    step.ID = this.Conver(xml.Step.Sp[counter].Id);
                    step.UnFunc = this.Conver(xml.Step.Sp[counter].UnFunction);
					step.Lesp = _lesp;
                    this._Step.push(step);
                    counter++;
                }
            }
			_lesp.ExecFunc(_Init);
            return;
        }

        private function Conver(param:Object) : String
        {
            if (String(param) == ("" || "Null" || "null" || "NULL"))
            {
                return null;
            }
            return String(param);
        }

        public function ToString() : String
        {
            return "Activity:\n" + this._Config.ToString() + this.ArrayToString("Includes", this._Includes) + "\n" + this.DataToString("Entrances", this._Entrances) + "\n" + this.DataToString("Step", this._Step) + "\n\tCurrentStep:" + this._CurrentStep;
        }

        private function ArrayToString(name:String, array:Array) : String
        {
            var str:String = name + ":";
            for (var a:int = 0; a < array.length; a++ )
			{
                str = str + ("\n\t\t" + "[" + a + "]" + ":" + array[a]);
                a++;
            }
            return str;
        }

        private function DataToString(name:String, array:Array) : String
        {
            var str:String = name + ":";
            for (var a = 0; a < array.length; a++ )
			{
                str = str + ("\n\t\t" + "[" + a + "]" + ":" + array[a].ToString());
                a++;
            }
            return str;
        }
    }
}

class PreLoadUnit
{
	private var _loader:IResourceLoader;
	private var _url:String;
	private var _callBack:Function;
	
	function PreLoadUnit(loader:IResourceLoader, url:String, callBack:Function)
	{
		_callBack = callBack;
		_url = url;
		_loader = loader;
		_loader.LoadResource("ActivityManager/ActivityUnit", _url, function(evt:Event)
		{
			_loader.UnLoadResource("ActivityManager/ActivityUnit", _url);
			_callBack();
		}, true, "MAP");
	}
}

import flash.events.Event;
import com.lele.Manager.Interface.IResourceLoader;

class ResLoaderUnit
{
    private var _loader:IResourceLoader;
	private var _url:String;

    function ResLoaderUnit(loader:IResourceLoader, url:String, addArray:Array, callBack:Function)
    {
		_url = url;
        _loader = loader;
        _loader.LoadResource("ActivityManager/ActivityUnit", url, function (event:Event)
        {
            addArray.push(event.target.applicationDomain);
            callBack();
        }
        , true, "ITEM");
    }
	function Clean()
	{
		_loader.UnLoadResource("ActivityManager/ActivityUnit", _url);
	}

}


class Func extends Object
{
    public var Name:String;
    public var params:Array;

    function Func()
    {
        return;
    }

}

