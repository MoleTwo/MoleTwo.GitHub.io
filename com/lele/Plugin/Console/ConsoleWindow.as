package com.lele.Plugin.Console
{
	import com.lele.Link.AppDataLink;
	import com.lele.Manager.GameManager;
	import com.lele.Manager.Interface.ICommand;
	import com.lele.Map.RuntimeActor;
	import com.lele.Plugin.Lesp.LespSpace;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	/**
	 * ...
	 * @author Lele
	 */
	public class ConsoleWindow extends Sprite implements IConsole
	{
		private var _icommand:ICommand;
		private var _lesp:LespSpace;
		private var _txtField:TextField;
		private var _bg:Sprite;
		private var _input:TextField;
		private var _button:Boolean;
		
		private var _lastLine:int;
		
		private var _callKey:int = 192;
		private var _enterKey:int = 13;
		
		public function ConsoleWindow(icommand:ICommand) 
		{
			_icommand = icommand;
			_lesp = new LespSpace();
			_button = false;
			_txtField = new TextField();
			_txtField.x = 20;
			_txtField.width = 940;
			_txtField.height = 180;
			_txtField.textColor = 0xFFFFFF;
			_txtField.appendText("Mole2 ConsoleWindow:\n");
			_input = new TextField();
			_input.width = 960;
			_input.height = 20;
			_input.y = 180;
			_input.textColor = 0xFFFFFF;
			_input.type=TextFieldType.INPUT;
			_input.appendText(">>> ");
			_bg = new Sprite();
			_bg.graphics.beginFill(0x000000, 0.8);
			_bg.graphics.drawRect(0, 0, 960, 200);
			_bg.graphics.endFill();
			
			_lesp.LoadObj(this as IConsole);
			_lesp.LoadObj(icommand);
		}
		
		public function On()
		{
			this.parent.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
			this.parent.addEventListener(KeyboardEvent.KEY_DOWN, OnInputDown);
		}
		public function Off()
		{
			this.parent.removeEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
			this.parent.removeEventListener(KeyboardEvent.KEY_DOWN, OnInputDown);
		}
		private function OnKeyDown(evt:KeyboardEvent)
		{
			if (evt.keyCode == _callKey)
			{
				_button = !_button;
				if (_button)
				{
					this.addChild(_bg);
					this.addChild(_txtField);
					this.addChild(_input);
					_input.text = ">>> ";
				}
				else
				{
					try
					{
						this.removeChild(_bg);
						this.removeChild(_txtField);
						this.removeChild(_input);	
					}catch(er:Error){}
				}
			}
		}
		private function OnInputDown(evt:KeyboardEvent)
		{
			if (!_button) { return; }
			if (evt.keyCode == _enterKey)
			{
				var cmd:String = _input.text;
				_input.text = ">>> ";
				cmd = cmd.substr(4, cmd.length);
				_txtField.appendText("> " + cmd + "\n");
				Deal(cmd);
				if (_txtField.numLines > 4)
				{
					_txtField.scrollV += _txtField.numLines-_lastLine;
				}
				_lastLine = _txtField.numLines;
			}
		}
		
		
		//IConsole
		public function Printer(str:String)
		{
			_txtField.appendText("\t" + str + "\n");
			if (_txtField.numLines > 4)
			{
				_txtField.scrollV++;
			}
		}
		//IConsole
		
		
		private function Deal(cmd:String)
		{
			try
			{
				var obj:Object = _lesp.ExecFunc(cmd);
				if (obj != null)
				{
					_txtField.appendText("\t" + obj + "\n");
				}
			}
			catch (er:Error)
			{
				_txtField.appendText("error: "+er.message+"\n");
			}
		}
		
	}

}