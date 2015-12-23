package 
{
	import com.lele.Manager.Events.ChangeMapEvent;
	import com.lele.Manager.Events.DebugEvent;
	import com.lele.Manager.Events.MapLoadedEvent;
	import com.lele.Manager.Events.RemoveMapEvent;
	import com.lele.Manager.Interface.IReport;
	import com.lele.Manager.ResourceManager;
	import com.lele.Manager.MapManager;
	import com.lele.Manager.SoundManager;
	import com.lele.Manager.UIManager;
	import com.lele.Map.Interface.IMapDocument;
	import com.lele.Plugin.RoadFind.RoadFinder;
	import com.lele.Controller.Avatar.CAvatar;
	import com.lele.Controller.PlayerController;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SpreadMethod;
	import flash.display.Sprite
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Lele
	 */
	public class GameManager extends Sprite implements IReport
	{
		private var _mapManager:MapManager;
		private var _resourceManager:ResourceManager;
		private var _soundManager:SoundManager;
		private var _uiManager:UIManager;
		
		private var resourcePack:Object;
		private var myAvatar:CAvatar;
		private var playController:PlayerController;
		private var roadFinder:RoadFinder;
		private var _dataBridge:Object;
		
		private var _UIContainer:Sprite;
		private var _MapsContainer:Sprite;
		
		private var _text:TextField;
		private var _debugContainer:Sprite;
		
		public function GameManager() 
		{
			_dataBridge = new Object();
			_resourceManager = new ResourceManager(this);
			_mapManager = new MapManager(_resourceManager, this);
			_soundManager = new SoundManager(_resourceManager,this);
			_uiManager = new UIManager(_resourceManager, this);
			
			
			
			_dataBridge.spawnPoint= new Point(637, 332);//连接出生点状态的数据，以后还有更多
			resourcePack = new Object();
			resourcePack.run_dl = new run_dl();
			resourcePack.run_lu = new run_lu();
			resourcePack.run_ur = new run_ur();
			resourcePack.run_rd = new run_rd();
			resourcePack.shadow = new shadow();
			myAvatar = new CAvatar(resourcePack);
			playController = new PlayerController();
			roadFinder = new RoadFinder();
			
			_UIContainer = new Sprite();
			_MapsContainer = new Sprite();
			this.addChild(_MapsContainer);
			this.addChild(_UIContainer);
			
			{
				_debugContainer = new Sprite();
				this.addChild(_debugContainer);
				_text = new TextField();
				_text.width = 500;
				var color:uint = 4294967295;
				_text.text = "摩尔庄园2 alpha v0.0.1\nDebug窗口:\n";
				_text.textColor =color;
				_debugContainer.addChild(_text);
			}
			
			_mapManager.LoadMapTo("Map/Map001.swf", _MapsContainer);//传递进回调函数，当加载完成
			_soundManager.LoadAndPlay("Map001MediaData");
			_uiManager.LoadUItoSprite("MainUI", _UIContainer);
		}
		
		
		
		public function OnReport(evt:Event):void//下层向本层汇报
		{
			
			if (evt is ChangeMapEvent)//如果是换地图事件
			{
				var cme:ChangeMapEvent = evt as ChangeMapEvent;
				var target:String = cme.TargetMap;
				_dataBridge.spawnPoint = cme.SpawnPoint;//dataBridge是跨越地图沟通的数据
				_soundManager.LoadAndPlay(target + "MediaData");
				_mapManager.UnLoadMap();
				myAvatar.Reset();
				_mapManager.LoadMapTo("Map/" + target + ".swf",_MapsContainer);
				return;
			}
			
			if (evt is RemoveMapEvent)
			{
				_soundManager.SmoothCloseAll();
				for (var a:int = 0; a < _MapsContainer.numChildren; a++ )//移除对象
				{
					if (_MapsContainer.getChildAt(a) == (evt as RemoveMapEvent)._map)
					{
						_MapsContainer.removeChildAt(a);
						return;
					}
				}
				
			}
			
			if (evt is MapLoadedEvent)//当地图加载完成
			{
				_mapManager.AddPlayerToMap(myAvatar,_dataBridge.spawnPoint, false, playController, roadFinder);
			}
			
			if (evt is DebugEvent)
			{
				var txF:TextField = (_debugContainer.getChildAt(0) as TextField);
				txF.text = _text.text + "\n" + (evt as DebugEvent).Log;
			}
		}
		
	}

}