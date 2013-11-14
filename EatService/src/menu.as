import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLRequest;

import mx.collections.ArrayCollection;
import mx.controls.Alert;

import utils.HashMap;

public static const DAILI:String = "http://127.0.0.1:8080/proxy.asp?url="

public static const IP:String = "http://m.ele.me/";
public static const TAB:String = "/tab/category";

public var today:String="";

public var menus:Array;
public var menusHp:HashMap;
private var _loader:URLLoader;
private var _urlRequest:URLRequest;




/**确认网址*/
protected function sureBtn_clickHandler(event:MouseEvent):void
{
	if(urlText.text != null && urlText.text != "")
	{
		today = urlText.text;
		loadWeb(DAILI + IP+ urlText.text + TAB);
//		loadWeb(http://m.ele.me/xdd/tab/category)
	}
}

/**开始加载菜单网页*/
private function loadWeb(url:String):void
{
	_loader = new URLLoader();
	_urlRequest = new URLRequest(url);
	_loader.load(_urlRequest);
	
	_loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
	_loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
}

/**加载完成*/
private function loadCompleteHandler(e:Event):void
{
	menus =[];
	var webStr:String = e.target.data;
	var mainArr:Array = new Array();
	var hp:HashMap = new HashMap();
	mainArr = webStr.split("<tr>");
	for(var i:int=1; i < mainArr.length; i++)
	{
		var name:String = mainArr[i].split('<td class="name">')[1].split("</td>")[0];
		var price:String = mainArr[i].split('<td class="price">')[1].split("</td>")[0];
		try{
			var url:String = mainArr[i].split("tab/category/")[1].split('" class')[0];
			menus.push({name : name, price : price, url : url});
			var id:String = url.split("cart/add/")[1].split("?")[0];
			hp.add({name : name, price : price, url : url}, id);
			trace(name+ price + "url="+url)
//			trace(name+ price + "id="+id)
		}catch(e:Error){
			trace(name + "没有了");
		}	
	}
	
	menusHp = hp;
	Alert.show("加载菜单完成");

}

private function errorHandler(error:ErrorEvent):void
{
//	trace("加载"+urlText.text + "失败");
	urlText.text = "";
	Alert.show("加载"+urlText.text + "失败");
}


/**提交今日订单给饿了么*/
protected function submit_clickHandler(event:MouseEvent):void
{
	var str1:String ="var restaurant =";
	str1 += '"'+today+'"'+"\n";
	str1 += "var orders =[";
	var arr:Array = [];
	for(var i:int=0; i < eatArr.length; i++)
	{
		arr.push('"'+eatArr[i].url+'"');
	}
	str1 += arr+"]";
	
//	var file:File = new File("E:/www/orders.js"); //公司
	var file:File = new File("E:/project/www/orders.js"); //家里
	
//	file = file.resolvePath("orders.js");
	
	var stream:FileStream = new FileStream();
	stream.open(file, FileMode.WRITE);	
	
	stream.writeUTFBytes(str1);			
	stream.close();
	
	loadDiary(); //生成日志
	
//	C:/Program Files/Mozilla Firefox/firefox.exe
	//D:/Program Files/Chrome/chrome.exe 公司
//	"C:/Program Files/Google/Chrome/Application/chrome.exe" 家里
	var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
	nativeProcessStartupInfo.executable = new File("C:/Program Files/Google/Chrome/Application/chrome.exe");
	var processArgs:Vector.<String> = new Vector.<String>();
	processArgs.push("http://127.0.0.1:8080/orders.html");
	nativeProcessStartupInfo.arguments = processArgs;
	new NativeProcess().start(nativeProcessStartupInfo);
}
