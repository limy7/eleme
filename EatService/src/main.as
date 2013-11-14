import com.adobe.serialization.json.AdobeJSON;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.ServerSocketConnectEvent;
import flash.net.ServerSocket;
import flash.net.SharedObject;
import flash.net.Socket;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.events.FlexEvent;

public var SO_LIMY:SharedObject;
public static const QUANXIAN_IP:String = "10.6.91.33";
[Bindable]
public var eatArr:ArrayCollection = new ArrayCollection();
private var _service:ServerSocket;
private var _service843:ServerSocket;
private var _clientList:Array;
protected function windowedapplication1_creationCompleteHandler(event:FlexEvent):void
{
	if(!ServerSocket. isSupported) {
		Alert.show("程序无法运行，你的机器不能开启Socket服务！！", "提示");
		stateBtn.enabled = false;
		return;
	}
	SO_LIMY = SharedObject.getLocal("limy");
	if(SO_LIMY.data.qx != null)
	{
		qxIPText.text = SO_LIMY.data.qx;
	}
	
	_service843 = new ServerSocket();
	_service843.addEventListener(ServerSocketConnectEvent.CONNECT, connect843Handler);
	

	_service843.bind(843);
	_service843.listen();
}

private function connect843Handler(event:ServerSocketConnectEvent):void
{
	event.socket.addEventListener(ProgressEvent.SOCKET_DATA, client843_dataHandler);
}

private function client843_dataHandler(event:ProgressEvent):void
{
	var socket:Socket = event.target as Socket;
//	var str:String = socket.readMultiByte(socket.bytesAvailable, "utf-8");
	var xml:String ="<?xml version=\"1.0\"?>" +   
		"<!DOCTYPE cross-domain-policy SYSTEM \"http://www.adobe.com/xml/dtds/cross-domain-policy.dtd\">" + 
		"<cross-domain-policy>" +
		"<allow-access-from domain=\"*\" to-ports=\"*\" />" +
		"</cross-domain-policy>";
	
	socket.removeEventListener(ProgressEvent.SOCKET_DATA, client843_dataHandler);
	socket.writeUTFBytes(xml );
	socket.writeByte(0);
	socket.flush();
}



/**服务端状态改变*/
protected function stateBtn_clickHandler(event:MouseEvent=null):void
{
	//关闭服务
	if(_service != null) {
		stateBtn.label = "开启";
		hostText.editable = portText.editable = true;
		
		_service.close();
		_service.removeEventListener(ServerSocketConnectEvent.CONNECT, connectHandler);
		_service.removeEventListener(Event.CLOSE, closeHandler);
		_service = null;
		
		for each(var client:Client in _clientList) {
			client.socket.removeEventListener(ProgressEvent.SOCKET_DATA, client_dataHandler);
			client.socket.removeEventListener(Event.CLOSE, client_closeHandler);
			if(client.socket.connected) client.socket.close();
		}
		_clientList = [];
	}	//开启服务
	else {
		stateBtn.label = "停止";
		hostText.editable = portText.editable = false;
		
		_clientList = [];
		_service = new ServerSocket();
		_service.addEventListener(ServerSocketConnectEvent.CONNECT, connectHandler);
		_service.addEventListener(Event.CLOSE, closeHandler);
		_service.bind(int(portText.text), hostText.text);
		_service.listen();
		
	}
	showClientList();
}

/**
 * 收到客户端传来的数据
 * @param event
 */
private function client_dataHandler(event:ProgressEvent, client:Client=null):void
{
	if(event != null) client = getClientBySocket(event.target as Socket);
	
	//数据的总长度
	if(client.dataLength == 0) {
		if(client.socket.bytesAvailable < 4) return;
		client.dataLength = client.socket.readInt();
	}
	
	//数据包长度不够
	if(client.socket.bytesAvailable < client.dataLength) return;
	
	
	var command:String = client.socket.readUTFBytes(32);//命令
	var content:String = client.socket.readUTFBytes(client.dataLength - 32);//内容
	
	if(command != "heartBeat"){
		if(logText.text.length > 0) logText.appendText("\n");
		logText.appendText("["+ client.name +"]：[" + command + "]");
	}
		executeCmd(client, command, content);
	

	
	client.dataLength = 0;
	if(client.socket.bytesAvailable >= 4) client_dataHandler(null, client);
}

private function executeCmd(client:Client, command:String, content:String):void
{
	if(content != "") var data:Object = AdobeJSON.decode(content);
	switch(command)
	{
		case "getMenu"://获取菜单
			client.sendData("getMenu", {menus : menus, rest : "", url : urlText.text});
			break;		
		case "submit": //用户提交点的菜
		
			var obj:Object = {};
			obj = menusHp.getValueByKey(data.id);
//			obj.isDone = data.isDone;
//			obj.owner = data.owner;
			
			for(var property:String in data)
			{
				obj[property] = data[property];
			}
			
			
			obj.index = eatArr.length;
			eatArr.addItem(obj);
			logText.appendText(obj.owner+" 点了 "+obj.name);

			sendEatArrUpdate();
			
			break;
		case "removeItem"://用户删除点的菜
//			eatArr.source.splice(data.index, 1);
			eatArr.removeItemAt(data.index);
			for(var j:int=0; j < eatArr.length; j++)
			{
				eatArr[j].index = j;
			}	
			logText.appendText(data.owner+"删除"+data.name);
			sendEatArrUpdate();
			
			break;
		
		case "sendToFWQ"://数据发送给服务器
			eatArr = new ArrayCollection(data.source);
			sendEatArrUpdate();
			break;
		
//		
	}
}

/**推送更新的用户点单信息*/
private function sendEatArrUpdate():void
{
//	/**向某个有权限的人推送账单*/
//	var ip:String = (qxIPText.text != null &&  qxIPText.text != "")? qxIPText.text : QUANXIAN_IP;
	var i:int;
	for(i=0; i < _clientList.length; i++)
	{
		_clientList[i].sendData("update1", {eatArr:eatArr});
	}
	
	var total:Number = 0;
	for(i=0; i < eatArr.source.length; i++)
	{
		total += Number(String(eatArr[i].price).split("元")[0]);
	}
	totalText.text = total+"";
}

/**
 * 确认记账地址 
 * @param event
 */
protected function ipBtn_clickHandler(event:MouseEvent):void
{
	SO_LIMY.data.qx = qxIPText.text;
	newQxUpdate();
	
}

/**推送新的记账权限*/
private function newQxUpdate():void
{
	var i:int;
	
	for(i=0; i < _clientList.length; i++)
	{
		var qx:Boolean = false;
		if(_clientList[i].name == qxIPText.text)qx = true;
		_clientList[i].sendData("update2", { qx : qx });
	}
}



/**
 * 有客户端连上来
 * @param event
 */
private function connectHandler(event:ServerSocketConnectEvent):void
{
	var client:Client = new Client(event.socket, event.socket.remoteAddress);
	client.socket.addEventListener(ProgressEvent.SOCKET_DATA, client_dataHandler);
	client.socket.addEventListener(Event.CLOSE, client_closeHandler);
	_clientList.push(client);
	var qx:Boolean;
	var ip:String;
	ip = QUANXIAN_IP;
	qx = false;
	if(qxIPText.text && qxIPText.text != "" )
	{
		ip = qxIPText.text;
	}
	if(client.name == ip)
	{
		qx = true;
	}
	client.sendData("update2", { qx : qx });
	showClientList();
}

/**
 * 客户端断开
 * @param event
 */
private function client_closeHandler(event:Event):void
{
	removieClientBySocket(event.target as Socket);
}

/**删除登陆的游客*/
private function removieClientBySocket(socket:Socket):void
{
	for(var i:int = 0; i < _clientList.length; i++) {
		if(_clientList[i].socket == socket)
		{
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, client_dataHandler);
			socket.removeEventListener(Event.CLOSE, client_closeHandler);
			if(socket.connected) socket.close();
			
			_clientList.splice(i, 1);
			showClientList();
			return;
		}
	}
}




private function closeHandler(event:Event):void
{
	Alert.show("Socket服务已异常关闭", "提示");
	stateBtn_clickHandler();
}

/**
 * 通过socket获取client
 */
private function getClientBySocket(socket:Socket):Client
{
	for(var i:int = 0; i < _clientList.length; i++)
	{
		var client:Client = _clientList[i];
		if(client.socket == socket) return client;
	}
	return null;
}

/**
 * 刷新客户端列表
 */
private function showClientList():void
{
	var al:ArrayList = new ArrayList();
	for(var i:int=0; i<_clientList.length; i++) {
		var client:Client = _clientList[i];
		al.addItem({ label:client.name });
	}
	clientList.dataProvider = al;
	
	sendEatArrUpdate();
	
}


