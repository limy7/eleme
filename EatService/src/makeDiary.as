import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.FileReference;
import flash.net.URLLoader;
import flash.net.URLRequest;

public static const DIARY_URL:String = "E:/www/orders.txt";
private var _diaryLoader:URLLoader = new URLLoader();
private var _urlReq:URLRequest;
private var _tx:String;
/**加载日志*/
public function loadDiary():void
{
	_diaryLoader.load(new URLRequest(DIARY_URL));
	
	_diaryLoader.addEventListener(Event.COMPLETE, diaryLoadCompleteHandler);
	_diaryLoader.addEventListener(IOErrorEvent.IO_ERROR, diarrErrorHandler);
}

/**加载完成*/
private function diaryLoadCompleteHandler(e:Event):void
{
	_tx = e.target.data;
	diaryContent();
}

private function diarrErrorHandler(error:ErrorEvent):void
{
	trace("没有该文件，加载失败。下面开始生成");

	diaryContent();

}

private function diaryContent():void
{	
	var date:Date = new Date();
	var month:String =String(date.month + 1);
	var d:String = String(date.date);
	if(month.length == 1) month = "0"+month;
	if(d.length == 1) d = "0" + d;
	_tx +="\n"+ date.fullYear+"-"+month + "-"+d;
	
	for(var i:int=0; i < eatArr.length; i++)
	{
		_tx += "\n"+ eatArr[i].owner + "点了："+eatArr[i].name + "  " +  eatArr[i].price;
	}
	
	var down:FileReference = new FileReference (); 
	down.save(_tx,"orders.txt")

}