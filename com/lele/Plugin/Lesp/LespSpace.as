package com.lele.Plugin.Lesp
{
	import adobe.utils.CustomActions;
	import com.lele.Data.GloableData;
	import com.lele.LeleSocket.Command;
	import com.lele.Manager.Events.APIEvent;
	import com.lele.Manager.GameManager;
	import com.lele.MathTool.LeleMath;
	import com.lele.Plugin.GUID.Guid;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.TriangleCulling;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Lele
	 */
	public class LespSpace 
	{
		private var _Root:String;
		
		private var _FunctionMap:Object;
		private var _ValueMap:Object;
		private var _Packs:Array;
		private var _PackLoaders:Array;
		private var _LespLoaders:Array;
		
		private var _printer:Function;
		
		public function LespSpace() 
		{
			_FunctionMap = new Object();
			_ValueMap = new Object();
			_PackLoaders = new Array();
			_LespLoaders = new Array();
			_Packs = new Array();
		}
		
		//清除空间
		public function Clean()
		{
			for (var a:int = 0; a < _PackLoaders.length; a++ )
			{
				(_PackLoaders[a] as LoadUnit).Release();
			}
			_FunctionMap = null;
			_ValueMap = null;
			_Packs = null;
			_PackLoaders = null;
		}
		//加载外部包
		public function LoadPack(url:String,callback:Function)
		{
			var loadUnit:LoadUnit = new LoadUnit(url, _Packs, callback);
			_PackLoaders.push(loadUnit);
		}
		//加载对象
		public function LoadObj(obj:Object)
		{
			_Packs.push(obj);
		}
		//根据语句重建原始函数
		private function GetCustomFunc(func:Func):Func
		{
			var custF:CustomFunc = _FunctionMap[func.Name];
			var funcS:String = custF.func;
			//这边存在一定的问题
			for (var a:int = 0; a < custF.param.length; a++ )
			{
				while (funcS.search(" "+custF.param[a]) >= 0)
				{
					funcS = funcS.replace(" " + String(custF.param[a]), " " + String(func.params[a]));
				}
			}
			funcS = "#" + funcS.substr(2, funcS.length);
			return ProcessOnce(funcS);
		}
		//执行Func
		public function ExecFunc(func:String):Object
		{
			if (func.charAt(1) == "!")
			{
				func = "#" + String(func).substr(2, String(func).length);
			}
			return ExecFuncHelp(ProcessOnce(func));
		}
        private function ExecFuncHelp(func:Func) : Object
        {
			//这里替换自定义函数
			while (_FunctionMap[func.Name] != undefined)
			{
				func = GetCustomFunc(func);
			}
			//替换结束
			var isDoing:Boolean = true;
			while (isDoing)
			{
				isDoing = false;
				for (var a:int = 0; a < func.params.length; a++ )
				{
					if (func.params[a] is Func)
					{
						func.params[a] = this.ExecFuncHelp(func.params[a] as Func);
						isDoing = true;
					}
					else if (func.params[a] is String && String(func.params[a]).charAt(0) == "#")
					{
						if (String(func.params[a]).charAt(1) != "!")
						{
							func.params[a] = this.ProcessOnce(func.params[a]);
							isDoing = true;
							//func.params[a] = "#" + String(func.params[a]).substr(2, String(func.params[a]).length);
						}
					}
					else if (func.params[a] is String && String(func.params[a]).charAt(0) == "&")
					{
						func.params[a] = this.GetFunction(String(func.params[a]).substr(1, String(func.params[a]).length));
						isDoing = true;
					}
					else if (func.params[a] is String && String(func.params[a]).charAt(0) == "@")
					{
						func.params[a] = this.GetUrl(String(func.params[a]).substr(1, String(func.params[a]).length));
						isDoing = true;
					}
					else if (func.params[a] is String && String(func.params[a]).charAt(0) == "$")
					{
						func.params[a] = this.GetInnerVariable(String(func.params[a]).substr(1, String(func.params[a]).length));
						isDoing = true;
					}
				}
			}
			return GetFunction(func.Name)(func.params);
        }

        private function GetInnerVariable(name:String) : Object
        {
			if (GloableData[name] != null) { return GloableData[name]; }
			return _ValueMap[name];
        }

        private function GetUrl(name:String) : String
        {
            return _Root+name;
        }

        private function GetFunction(name:String) : Function
        {
			var geted:Boolean = false;
			var retFunc:Function;
			try { retFunc = this[name] as Function; geted = true; }
			catch (er:Error) { geted = false; }
			if (geted == true) { return retFunc; }
			for (var a:int = 0; a < _Packs.length; a++ )
			{
				try { retFunc = _Packs[a][name] as Function; geted = true;}
				catch (er:Error) { geted = false; }
				if (geted == true) { return retFunc; }
			}
            if (!geted) { throw new Error("No such function!"+"function name:"+name); }
			return function() { };
        }

        private function ProcessOnce(str:String) : Func
        {
            var temp:String = null;
            str = str.substr(2, str.length - 3);
            var stack:Array = new Array();
            var func:Func = new Func();
            var params:Array = new Array();
            var ignore:int = 0;
            for (var a:int = 0; a < str.length; a++ )
			{
                if (str.charAt(a) == " " && ignore == 0)
                {
                    temp = "";
                    stack = stack.reverse();
                    while (stack.length > 0)
                    {
                        
                        temp = temp + stack.pop();
                    }
                    params.push(temp);
                }
                else
                {
                    stack.push(str.charAt(a));
                }
                if (str.charAt(a) == "#")
                {
                    ignore++;
                }
                if (str.charAt(a) == ")")
                {
                    ignore = ignore - 1;
                }
            }
            if (stack.length != 0)
            {
                temp = "";
                stack = stack.reverse();
                while (stack.length > 0)
                {
                    
                    temp = temp + stack.pop();
                }
                params.push(temp);
            }
            func.Name = params[0];
            func.params = params.slice(1, params.length);
            return func;
        }
		
		
		
		
		
		
		
		
		///lele func
		private function Abs(args:Array):Number
		{
			return Math.abs(Number(args[0]));
		}
		private function NextGaussian(args:Array):Number
		{
			return LeleMath.NextGaussian2(Number(args[0]), Number(args[1]));
		}
		private function MakeInt(args:Array):int //str
		{
			return int(args[0]);
		}
		private function LessThen(args:Array):Boolean
		{
			return Number(args[0]) < Number(args[1]);
		}
		private function GetSpliteAt(args:Array):String //str splite_char position
		{
			return String(args[0]).split(args[1])[args[2]];
		}
		private function BineString(args:Array):String
		{
			var str:String = "";
			for (var a:int = 0; a < args.length; a++ )
			{
				str += args[a];
			}
			return str;
		}
		private function MakeObject(args:Array = null):Object
		{
			return new Object();
		}
		private function SetObjValue(args:Array) //obj memberName memberValue
		{
			args[0][args[1]] = args[2];
		}
		private function GetObjValue(args:Array):Object //obj valueName
		{
			return args[0][args[1]];
		}
		private function CallObjFunction(args:Array):Object //obj funcName
		{
			return args[0][args[1]](args.slice(2, args.length));
		}
		private function Typeof(args:Array):String  //obj
		{
			return getQualifiedClassName(args[0]);
		}
		private function Unload(args:Array)//url
		{
			for (var a:int = 0; a < _LespLoaders.length; a++ )
			{
				if ((_LespLoaders[a] as LespLoader)._url == args[0])
				{
					(_LespLoaders[a] as LespLoader).Release();
					_LespLoaders.splice(a, 1);
					return;
				}
			}
		}
		private function Load(args:Array)//url callback
		{
			var loader:LespLoader = new LespLoader(args[0], args[1], this);
			_LespLoaders.push(loader);
		}
		private function MakeArray(args:Array):Array
		{
			var array:Array = new Array();
			if (args != null)
			{
				for (var a:int = 0; a < args.length; a++ )
				{
					array.push(args[a] );
				}
			}
			return array;
		}
		private function Random(args:Array):Number //get random num between a to b
		{
			if (Number(args[0]) > Number(args[1]))
			{
				return Math.random() * (Number(args[0]) -Number(args[1])) + Number(args[1]);
			}
			return Math.random() * (Number(args[1]) -Number(args[0])) +Number( args[0]);
		}
		private function Multiply(args:Array):Number
		{
			var result:Number = Number(args[0]);
			for (var a:int = 1; a < args.length; a++ )
			{
				result *= Number(args[a]);
			}
			return result;
		}
		private function Add(args:Array):Number //source add1 add2 add3....
		{
			var result:Number =Number(args[0]);
			for (var a:int = 1; a < args.length; a++ )
			{
				result +=Number( args[a]);
			}
			return result;
		}
		private function IsEqual(args:Array):Boolean// obj1   obj2
		{
			return args[0] == args[1];
		}
		private function Branch(args:Array) //condition yesFunc noFunc
		{
			if (args[0])
			{
				if (args[1] != null) { ExecFunc(args[1]); }
			}
			else
			{
				if (args[2] != null) { ExecFunc(args[2]); }
			}
		}
		private function Clock(args:Array) //delNum times==0 StepFunc CompleteFunc
		{
			var timer:Timer = new Timer(args[0], args[1]);
			var funcA:Function=function(evt:Event)
			{
				ExecFunc(args[2]);
			}
			var funcB:Function=function(evt:Event)
			{
				timer.removeEventListener(TimerEvent.TIMER, funcA);
				timer.removeEventListener(TimerEvent.TIMER, funcB);
				if (args[3] != null)
				{
					ExecFunc(args[3]);
				}
			}
			timer.addEventListener(TimerEvent.TIMER,funcA );
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, funcB );
			timer.start();
		}
		private function DefFunc(args:Array) //name func params....
		{
			var custc:CustomFunc = new CustomFunc();
			custc.name = args[0];
			custc.func = args[1];
			custc.param = args.slice(2, args.length);
			_FunctionMap[custc.name] = custc;
		}
		private function CheckBoolean(args:Array):Boolean
		{
			if (args[0] == false) { return false; }
			return true;
		}
		private function SetRoot(args:Array):String
		{
			_Root = args[0];
			return args[0];
		}
		private function False(args:Array=null):Boolean
		{
			return false;
		}
		private function True(args:Array=null):Boolean
		{
			return true;
		}
		private function MakeString(args:Array = null):String
		{
			var str:String = "";
			if (args != null)
			{
				for (var a:int = 0; a < args.length; a++ )
				{
					str +=" "+ args[a];
				}
			}
			return str.substr(1,str.length);
		}
		private function NULL(args:Array = null) {}
		private function MakePoint(args:Array):Point
		{
			return new Point(Number(args[0]), Number(args[1]));
		}
		private function LoadPackFunc(args:Array)//url callback(func)
		{
			var arr:Array = new Array();
			arr.push(args[1]);
			var ld:LoadUnit = new LoadUnit(args[0], _Packs,GenerateFunction(arr));
			_PackLoaders.push(ld);
		}
		private function LoadPackFunction(args:Array)//url callback(function)
		{
			var ld:LoadUnit = new LoadUnit(args[0], _Packs, args[1]);
			_PackLoaders.push(ld);
		}
		private function SetPrinter(args:Array)//function
		{
			_printer = args[0];
		}
		private function Print(args:Array)//str
		{
			if (_printer != null) { _printer(args[0]); }
			else
			{
				trace(args[0]);
			}
		}
		private function StructFor(args:Array)//times func
		{
			for (var a:int = 0; a < int(args[0]); a++ )
			{
				ExecFunc(args[1]);
			}
		}
		private function DefValue(args:Array):Object//type name val
		{
			try
			{
				var a:Class = getDefinitionByName(args[0]) as Class;
			}catch (er:Error) { Print(["No such definition"]); return null; }
			try
			{
				var test = a(args[2]);
			}
			catch (er:Error) 
			{
				try
				{
					test = args[2] as a;
					if (test == null)
					{
						Print(["Type cast faild"]);
						return null;
					}
				}catch (errr:Error)
				{
					Print(["Type cast faild"]); return null; 
				}
			}
			_ValueMap[args[1]] = test;
			return test;
		}
		private function SetValue(args:Array)//type name val
		{
			try
			{
				var a:Class = getDefinitionByName(args[0]) as Class;
			}catch (er:Error) { trace("No such definition"); return; }
			try
			{
				var test = a(args[2]);
			}catch (er:Error) { trace("Type cast faild"); return; }
			_ValueMap[args[1]]=test;
		}
		private function GenerateFunction(args:Array):Function//func 
		{
			var temp:Function = function():Object
			{
				return ExecFunc(args[0]);
			}
			return temp;
		}
		private function MakeNetFunction(args:Array):Function //func params:name v1 v2 v3...
		{
			var temp:Function = function(cmd:Command):Object
			{
				if (args[0].charAt(1) == "!")
				{
					args[0] = "#" + String(args[0]).substr(2, String(args[0]).length);
				}
				var par:Array = args.slice(1, args.length);
				while (args[0].search(" " + par[0]) >= 0)
				{
					args[0] = args[0].replace(" " + String(par[0]), " " + cmd._commandName);
				}
				var pa:Array = par.slice(1, par.length);
				for (var a:int = 0; a < pa.length; a++ )
				{
					while (args[0].search(" "+pa[a]) >= 0)
					{
						args[0] = args[0].replace(" " + String(pa[a]), " " + cmd.GetValueByName(pa[a]));
					}
				}
				return ExecFunc(args[0]);
			}
			return temp;
		}
		private function MakeFunction(args:Array):Function //func,params
		{
			var temp:Function = function(...arg):Object
			{
				if (args[0].charAt(1) == "!")
				{
					args[0] = "#" + String(args[0]).substr(2, String(args[0]).length);
				}
				var par:Array = args.slice(1, args.length);
				for (var a:int = 0; a < par.length; a++ )
				{
					while (args[0].search(" "+par[a]) >= 0)
					{
						args[0] = args[0].replace(" " + String(par[a]), " " + String(arg[a]));
					}
				}
				return ExecFunc(args[0]);
			}
			return temp;
		}
		private function ExecFunction_p_p(args:Array):Object//function
		{
			return (args[0] as Function)(args[1],args[2]);
		}
		private function ExecFunction_p(args:Array):Object//function
		{
			return (args[0] as Function)(args[1]);
		}
		private function ExecFunction(args:Array):Object//function
		{
			return (args[0] as Function)();
		}
		//Lele Function End
		//特化的关于该game 的
		public function AddAPIEventListener(args:Array):Function //evtStr:String action:Func name
		{
			var func:Function = function(evt:APIEvent)//如果这里的data要是任意类型的就必须在下面申请一个临时空间存放，执行完后清除
			{
				ExecFunc("#(" + args[1] + " " + evt.data + ")");
			}
			GameManager.GetEventDispatcher().addEventListener(args[0], func);
			return func;
		}
		public function RemoveAPIEventListener(args:Array) //evtStr:String action:Function
		{
			GameManager.GetEventDispatcher().removeEventListener(args[0], args[1]);
		}
		public function SetGloableData(args:Array) //name value
		{
			trace(args[1]);
			GloableData[args[0]] = args[1];
		}
	}

}

import flash.display.Loader;
import flash.events.Event;
import flash.net.URLRequest;
import com.lele.Plugin.Lesp.LespSpace;

class LespLoader
{
	public var _callBack:String;
	public var _url:String;
	public var _lesp:LespSpace;
	public var _loader:Loader;
	
	public function LespLoader(url:String, callBack:String,lesp:LespSpace)
	{
		_url = url;
		_callBack = callBack;
		_lesp = lesp;
		
		_loader = new Loader();
		var request:URLRequest = new URLRequest(_url);
		var func:Function = function(evt:Event)
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, func);
			_lesp.ExecFunc(_callBack);
		}
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,func);
		_loader.load(request);
	}
	public function Release()
	{
		_lesp = null;
		_loader.unloadAndStop(true);
	}
	
}

import flash.display.Loader;
import flash.events.Event;
import flash.net.URLRequest;
class LoadUnit
{
	//来自Lesp的引用
	private var _packs:Array;
	
	private var _loader:Loader;
	private var _callBack:Function;
	
	public function LoadUnit(url:String,packs:Array,callBack:Function)
	{
		_packs = packs;
		_loader = new Loader();
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(evt:Event)
		{
			_packs.push(evt.target.content);
			callBack();
		});
		var req:URLRequest = new URLRequest(url);
		_loader.load(req);
	}
	public function Release()
	{
		_loader.unloadAndStop(true);
		_callBack = null;
	}
}

class CustomFunc
{
	public var name:String;
	public var func:String;
	public var param:Array;
}