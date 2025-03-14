package com.lele.Manager
{
	import com.lele.LeleSocket.Param;
	import com.lele.Manager.Events.APIEvent;
	import com.lele.Manager.Interface.IPrivateNetWork;
	import com.lele.Plugin.GUID.Guid;
	import com.lele.LeleSocket.Command;
	import com.lele.LeleSocket.LeleSocketBasic;
	import com.lele.LeleSocket.EventCommandConver;
	import com.lele.Manager.Events.ManagerEventBase;
	import com.lele.Manager.Events.Net_Game_ManagerEvent;
	import com.lele.Manager.Events.NetData_Net_ManagerEvent;
	import com.lele.Manager.Interface.INetManager;
	import com.lele.Manager.Interface.IReport;
	import com.lele.Data.GloableData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GradientGlowFilter;
	/**
	 * ...
	 * @author Lele
	 */
	 
	public class NetManager extends Sprite implements INetManager,IPrivateNetWork
	{
		//内部端口计数器
		private var _mPortCounter:int;
		private var _portPairs:Array;
		
		private var _leleSocket:LeleSocketBasic;
		private var _repoter:IReport;
		
		private var _serverIP:String;
		private var _serverPort:int;
		
		public static var _privateNetWork:IPrivateNetWork;
		
		public function NetManager(serverIP:String,serverPort:int,repoter:IReport) 
		{
			_portPairs = new Array();
			_mPortCounter = 1000;
			_serverIP = serverIP;
			_serverPort = serverPort;
			_repoter = repoter;
			_leleSocket = new LeleSocketBasic(OnCommand, OnServerClose);
			_privateNetWork = this;
		}
		
		
		
		
		
		private function OnCommand(command:Command,vip:Boolean=false)
		{
			if (vip && GloableData.VipNetEnable)
			{
				var callBack:Function = GetPortPairPort((int)(command.GetValueByName("port"))).callBack;
				for (var a:int = 0; a < command._paramArray.length; a++ )
				{
					if ((command._paramArray[a] as Param)._name == "port")
					{
						command._paramArray.splice(a, 1);
						break;
					}
				}
				callBack(command);  
				return; 
			}
			
			var tempEvt:NetData_Net_ManagerEvent = EventCommandConver.ConverCommandToEvent(command);
			if (tempEvt == null)
			{
				trace("未定义的通讯协议");
				return;
			}
			var toGameManger:Net_Game_ManagerEvent;
			switch(tempEvt.EvtType)
			{
				case NetData_Net_ManagerEvent.DOACTION:
				{
					toGameManger= new Net_Game_ManagerEvent(Net_Game_ManagerEvent.DOACTION);
					toGameManger._playerID = tempEvt._playerID;//一定要
					toGameManger.DOACTION_name = tempEvt.DOACTION_name;
					toGameManger.DOACTION_direction = tempEvt.DOACTION_direction;
					break;
				}
				case NetData_Net_ManagerEvent.ADDNETPLAYER:
				{
					toGameManger = new Net_Game_ManagerEvent(Net_Game_ManagerEvent.ADDNETPLAYER);
					toGameManger.ADDNETPLAYER_color = tempEvt.ADDNETPLAYER_color;
					toGameManger.ADDNETPLAYER_name = tempEvt.ADDNETPLAYER_name;
					toGameManger._playerID = tempEvt._playerID;
					toGameManger.ADDNETPLAYER_spownPoint = tempEvt.ADDNETPLAYER_spownPoint;
					toGameManger.ADDNETPLAYER_map = tempEvt.ADDNETPLAYER_map;
					toGameManger.ADDNETPLAYER_dress = tempEvt.ADDNETPLAYER_dress;
					break;
				}
				case NetData_Net_ManagerEvent.LOGINRESULT:
				{
					toGameManger = new Net_Game_ManagerEvent(Net_Game_ManagerEvent.LOGINRESULT);
					toGameManger.LOGINRESULT_result = tempEvt.LOGINRESULT_result;
					break;
				}
				case NetData_Net_ManagerEvent.NETPLAYERMOVE:
				{
					toGameManger = new Net_Game_ManagerEvent(Net_Game_ManagerEvent.NETPLAYERMOVE);
					toGameManger._playerID = tempEvt._playerID;
					toGameManger.NETPLAYERMOVE_point = tempEvt.NETPLAYERMOVE_target;
					break;
				}
				case NetData_Net_ManagerEvent.REMOVENETPLAYER:
				{
					toGameManger = new Net_Game_ManagerEvent(Net_Game_ManagerEvent.REMOVENETPLAYER);
					toGameManger._playerID = tempEvt._playerID;
					break;
				}
				case NetData_Net_ManagerEvent.NETPLAYERSAY:
				{
					toGameManger = new Net_Game_ManagerEvent(Net_Game_ManagerEvent.NETCHATMSG);
					toGameManger._playerID = tempEvt._playerID;
					toGameManger.NETCHATMSG_msg = tempEvt.NETPLAYERSAY_msg;
					break;
				}
				case NetData_Net_ManagerEvent.CHANGEWEATHER:
				{
					toGameManger = new Net_Game_ManagerEvent(Net_Game_ManagerEvent.CHANGEWEATHER);
					toGameManger.CHANGEWEATHER_weather = tempEvt.CHANGEWEATHER_weather;
					toGameManger.CHANGEWEATHER_strength = tempEvt.CHANGEWEATHER_strength;
					break;
				}
				case NetData_Net_ManagerEvent.CREATACCOUNTRESULT:
				{
					toGameManger = new Net_Game_ManagerEvent(Net_Game_ManagerEvent.CREATACCOUNTRESULT);
					toGameManger.CREATACCOUNTRESULT_result = tempEvt.CREATACCOUNTRESULT_result;
					toGameManger.CREATACCOUNTRESULT_id = tempEvt.CREATACCOUNTRESULT_id;
					break;
				}
				case NetData_Net_ManagerEvent.MOLEBASEINFO:
				{
					toGameManger = new Net_Game_ManagerEvent(Net_Game_ManagerEvent.MOLEBASEINFO);
					toGameManger.MOLEBASEINFO_num = tempEvt.MOLEBASEINFO_num;
					toGameManger.MOLEBASEINFO_color = tempEvt.MOLEBASEINFO_color;
					toGameManger.MOLEBASEINFO_name = tempEvt.MOLEBASEINFO_name;
					toGameManger.MOLEBASEINFO_dress = tempEvt.MOLEBASEINFO_dress;
					break;
				}
				case NetData_Net_ManagerEvent.CREATEMOLEBACK:
				{
					toGameManger = new Net_Game_ManagerEvent(Net_Game_ManagerEvent.CREATEMOLEBACK);
					toGameManger.CREATEMOLEBACK_result = tempEvt.CREATEMOLEBACK_result;
					break;
				}
				case NetData_Net_ManagerEvent.NETTHROWITEM:
				{
					toGameManger = new Net_Game_ManagerEvent(Net_Game_ManagerEvent.NETTHROWITEM);
					toGameManger.NETTHROWITEM_action = tempEvt.NETTHROWITEM_action;
					toGameManger.NETTHROWITEM_blood = tempEvt.NETTHROWITEM_blood;
					toGameManger.NETTHROWITEM_dir = tempEvt.NETTHROWITEM_dir;
					toGameManger.NETTHROWITEM_id = tempEvt.NETTHROWITEM_id;
					toGameManger.NETTHROWITEM_itemStyle = tempEvt.NETTHROWITEM_itemStyle;
					toGameManger.NETTHROWITEM_position = tempEvt.NETTHROWITEM_position;
					break;
				}
				case NetData_Net_ManagerEvent.FRIENDCHATRECEIVE:
				{
					//好友信息接受
					GameManager.ApplicationManagerFuncer.StartApp("FriendsApp",2, tempEvt.FRIENDCHATRECEIVE_time,
					tempEvt.FRIENDCHATRECEIVE_from, tempEvt.FRIENDCHATRECEIVE_msg);
					break;	
				}
				case NetData_Net_ManagerEvent.CHATLISTDATABACK:
				{
					//构建全局好友信息，简单版
					if (tempEvt.CHATLISTDATABACK_dataField == "0")
					{
						for (var a:int = 0; a < tempEvt.CHATLISTDATABACK_num; a++)
						{
							GloableData.AddFriend(tempEvt.CHATLISTDATABACK_ids.split("|")[a], tempEvt.CHATLISTDATABACK_colors.split("|")[a], tempEvt.CHATLISTDATABACK_names.split("|")[a], int(tempEvt.CHATLISTDATABACK_stys.split("|")[a]));
						}
					}
					GameManager.ApplicationManagerFuncer.StartApp("FriendsApp", 3, tempEvt.CHATLISTDATABACK_dataField,
					tempEvt.CHATLISTDATABACK_isAppend, tempEvt.CHATLISTDATABACK_totalNum, tempEvt.CHATLISTDATABACK_num,
					tempEvt.CHATLISTDATABACK_colors, tempEvt.CHATLISTDATABACK_ids, tempEvt.CHATLISTDATABACK_isOnlines,
					tempEvt.CHATLISTDATABACK_names, tempEvt.CHATLISTDATABACK_stys);
					break;
				}
				case NetData_Net_ManagerEvent.FRIENDLOGIN://好友登录
				{
					GameManager.ApplicationManagerFuncer.StartApp("FriendsApp", 4, tempEvt.FRIENDLOGIN_id);
					break;
				}
				case NetData_Net_ManagerEvent.FRIENDOFFLINE://好友离线
				{
					GameManager.ApplicationManagerFuncer.StartApp("FriendsApp", 5, tempEvt.FRIENDOFFLINE_id);
					break;
				}
				case NetData_Net_ManagerEvent.XMFRIEND://请求加好友
				{
					ApplicationManager.GetIDialog().AddNote(1, function(state:Boolean) { 
						GloableData.AddFriend(tempEvt.XMFRIEND_id, "white", "null", 0);
						var str:String = "<XXMFriend;2;ans;";
						if (state) { str += "1"; }
						else { str += "0"; }
						str += ";aorID;" + tempEvt.XMFRIEND_id + ">";
						_leleSocket.Send(str);
					},
					tempEvt.XMFRIEND_name+"要和你交朋友!", "和我做朋友吧," + tempEvt.XMFRIEND_name+"(" + tempEvt.XMFRIEND_id + ")",
					((new Date()).getMonth() + 1).toString(), (new Date()).getDate().toString(),
					(new Date()).hours.toString() + ":" + (new Date()).minutes.toString());
					break;
				}
				case NetData_Net_ManagerEvent.NOTEY:
				{
					ApplicationManager.GetIDialog().AddNote(0, function() {},
					tempEvt.NOTEY_title,tempEvt.NOTEY_content,
					((new Date()).getMonth() + 1).toString(), (new Date()).getDate().toString(),
					(new Date()).hours.toString() + ":" + (new Date()).minutes.toString());
					break;
				}
				case NetData_Net_ManagerEvent.NCHANGEDRESS:
				{
					toGameManger = new Net_Game_ManagerEvent(Net_Game_ManagerEvent.NCHANGEDRESS);
					toGameManger.NCHANGEDRESS_HENHSC = tempEvt.NCHANGEDRESS_HENHSC;
					toGameManger.NCHANGEDRESS_id = tempEvt.NCHANGEDRESS_id;
					break;
				}
				case NetData_Net_ManagerEvent.SHOWDIALOG:
				{
					ApplicationManager.GetIDialog().ShowDialog("emoy", tempEvt.SHOWDIALOG_mood, tempEvt.SHOWDIALOG_msg, null);
					break;
				}
				case NetData_Net_ManagerEvent.BLOOD:
				{
					var apiEvt:APIEvent = new APIEvent(APIEvent.OnSetBlood);
					var obj:Object = new Object();
					apiEvt.data = tempEvt.BLOOD_id+";"+tempEvt.BLOOD_num;
					GameManager.GetEventDispatcher().dispatchEvent(apiEvt);
				}
			}
			_repoter.OnReport(toGameManger);
		}
		private function OnServerClose()
		{	
			//ApplicationManager.GetIDialog().ShowDialog("emoy", "sad", "服务器似乎挂了!", null);
		}
		public function Connect()
		{
			_leleSocket.Connect(_serverIP, _serverPort);
		}
		public function DisConnect()
		{
			_leleSocket.DisConnect();
		}
		public function OnReceive(evt:Event)
		{
			var str:String = EventCommandConver.ConverEventToCommand(evt as ManagerEventBase);
			_leleSocket.Send(str);
		}
		
		//提供独立端口给子app使用
		
		public function GetPrivateNetPort(callBack:Function):String
		{
			var temp:PortPair = new PortPair();
			temp.id = Guid.create();
			temp.port = _mPortCounter;
			temp.callBack = callBack;
			_mPortCounter++;
			_portPairs.push(temp);
			return temp.id;
		}
		
		public function Release(id:String)
		{
			for (var a:int = 0; a < _portPairs.length; a++ )
			{
				if ((_portPairs[a] as PortPair).id == id)
				{
					_portPairs.splice(a, 1);
					return;
				}
			}
		}
		
		public function PrivateSendStr(evtName:String, length:String, pv:String, id:String) //das;asd;asd;adss
		{
			var pack:String = "<" + evtName+";" + length;
			pack += ";"+pv;
			pack += ";port;" + GetPortPair(id).port.toString() + ">";
			_leleSocket.Send(pack);
		}
		public function PrivateSend(evtName:String, paramName:Array, paramValue:Array, id:String)
		{
			var pack:String = "<" + evtName+";"+(paramName.length+1).toString();
			for (var a:int = 0; a < paramName.length; a++ )
			{
				pack += ";" + paramName[a] + ";" + paramValue[a];
			}
			pack += ";port;" + GetPortPair(id).port.toString() + ">";
			_leleSocket.Send(pack);
		}
		
		private function GetPortPair(id:String):PortPair
		{
			for (var a:int = 0; a < _portPairs.length; a++ )
			{
				if ((_portPairs[a] as PortPair).id == id)
				{
					return (_portPairs[a]);
				}
			}
			return null;
		}
		private function GetPortPairPort(port:int):PortPair
		{
			for (var a:int = 0; a < _portPairs.length; a++ )
			{
				if ((_portPairs[a] as PortPair).port == port)
				{
					return (_portPairs[a]);
				}
			}
			return null;
		}
		
	}
}
class PortPair
{
	public var id:String;
	public var port:int;
	public var callBack:Function;
}