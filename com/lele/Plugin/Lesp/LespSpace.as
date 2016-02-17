package com.lele.Plugin.Lesp
{
	import adobe.utils.CustomActions;
	import flash.display.TriangleCulling;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
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
		
		private var _printer:Function;
		
		public function LespSpace() 
		{
			_FunctionMap = new Object();
			_ValueMap = new Object();
			_PackLoaders = new Array();
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
				funcS=funcS.replace(String(custF.param[a]), String(func.params[a]));
			}
			return ProcessOnce(funcS);
		}
		//执行Func
		public function ExecFunc(func:String):Object
		{
			return ExecFuncHelp(ProcessOnce(func));
		}
        private function ExecFuncHelp(func:Func) : Object
        {
			//这里替换自定义函数
			if (_FunctionMap[func.Name] != undefined)
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
						if (String(func.params[a]).charAt(1) == "!")
						{
							func.params[a] = "#" + String(func.params[a]).substr(2, String(func.params[a]).length);
						}
						else
						{
							func.params[a] = this.ProcessOnce(func.params[a]);
							isDoing = true;
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
            if (!geted) { throw new Error("No such function!"); }
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
		private function NULL(args:Array=null){}
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
			}catch (er:Error) { trace("No such definition"); return null; }
			try
			{
				var test = a(args[2]);
			}catch (er:Error) { trace("Type cast faild"); return null; }
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
		private function ExecFunction(args:Array):Object//function
		{
			return (args[0] as Function)();
		}
		//Lele Function End
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