import com.adobe.serialization.json.JSON;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.net.Socket;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Timer;

import net.ServicesList;

public var socket:Socket = new Socket();
/**正在通信的模型列表*/
private var _rmList:Dictionary = new Dictionary();

/**后台主机地址*/
private var _host:String = null;
/**后台主机端口*/
private var _port:int;

/**当前数据内容长度*/
private var _contentLength:uint;
//还有心跳包部分
private var _heartBeatTimer:Timer;

public function initSocket():void
{
	socket.addEventListener(Event.CONNECT, connectHandler);
	socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
	_heartBeatTimer = new Timer(10000);
	_heartBeatTimer.addEventListener(TimerEvent.TIMER, timerHandler);
}

/**连接成功*/
private function connectHandler(e:Event):void
{
	trace("连接成功！")
	_heartBeatTimer.start();
}

/**收到数据*/
private function socketDataHandler(e:Event=null):void
{
	//还没有读取到数据内容的长度
	if(_contentLength == 0){
		//数据内容的长度为4byte
		if(socket.bytesAvailable < 4) {
			return;
		}
		else{
			_contentLength = socket.readInt();
		}
	}
	
	//缓冲区的长度还未达到数据内容长度
	if(socket.bytesAvailable < _contentLength) return;
	
	//读取命令
	var command:String = socket.readUTFBytes(32);
	
	//读取内容
	var content:String;
	/*还涉及到用不用  解压 此处略*/
	
	//			content = this.readUTFBytes(_contentLength - 36);
	//			_contentLength = this.readInt();
	
	content = socket.readUTFBytes(socket.bytesAvailable);
	
	//置空数据内容的长度
	_contentLength = 0;
	
	//转换数据
	var msg:String;
	var data:Object;
	try{
		data = JSON.decode(content);
	} catch(error:Error)
	{
		msg = "数据转换失败";
		callback(false, {message : msg}, command);
		return;
	}
	
	if(command.indexOf("update") != -1) //如果是推送数据
	{
//		
		switch(command){
			case "update1": //菜单账单更新信息
				updateAccept(data);
				break;
			case "update2"://记账权限
				showMoneyList(data.qx)
				break;
		}
		
		
	}else{
		callback(true, data, command);
	}
	
	//缓冲区还有数据可以读
	if(socket.bytesAvailable > 0) socketDataHandler();
	
}



private function callback(success:Boolean, data:Object, command:String):void
{
	if(_rmList[command] == null) return;
	//			if(data["data"] == null) data["data"] = {};
	
	var rmData:Object;//数据
	for(var i:int=0; i < _rmList[command].length; i++)
	{
		rmData = _rmList[command][i];
		if(rmData.callBack != null){
			rmData.callBack(success, data);
		}
		_rmList[command].splice(i, 1); //用完删除
	}
}

/**心跳包计时器*/
private function timerHandler(e:TimerEvent):void
{
//	send(HEART_BEAT, {heartBeat : "我是心跳包"});
	send(ServicesList.HEART_BEAT);
}

/**
 * 发送数据
 * @param rm 
 * @param data
 * @param callBack
 * 
 */		
public function send(rm:String, data:Object=null, callBack:Function=null):void
{
	if(!socket.connected) return;
	
	if(_rmList[rm] == null) _rmList[rm] = [];
	_rmList[rm].push({ rm : rm, callBack : callBack });
	
	//操作类型
	var command:ByteArray = new ByteArray();
	command.writeUTFBytes(rm);
	command.length = 32;
	
	var content:ByteArray = new ByteArray();
	var str:String;
	if(!(data is String)) {
		str = JSON.encode(data);
	}			
	if(data != null) content.writeUTFBytes(str);
	
	socket.writeInt(command.length + content.length);
	socket.writeBytes(command);
	socket.writeBytes(content);
	socket.flush();
	
}

public function connect(host:String, port:int):void
{
	socket.connect(host, port);
	_host = host;
	_port = port;
}

/**关闭端口*/
public function close():void
{
	if(socket.connected) socket.close();
}


