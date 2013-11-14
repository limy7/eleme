import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.net.SharedObject;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.FlexEvent;

import net.ServicesList;

import spark.collections.Sort;
import spark.collections.SortField;
import spark.components.supportClasses.ItemRenderer;

public var isDebug:Boolean = true;

/**今日菜单*/
[Bindable]
public var menus:ArrayCollection = new ArrayCollection();
/**所有人的点餐数据*/
[Bindable]
public var eatArr:ArrayCollection = new ArrayCollection();


/**人物姓名*/
public var guestName:String;
/**是否有权限记账*/
public var quanxian:Boolean;
private var SO : SharedObject;
private var IP:String;

public function addToCart(id:String):void
{
//	Alert.show("哈哈哈::" + id);
	var item:Object = {};
	item.owner = guestName;
	item.isDone = false;
	item.total = int(totalMoneyText.text);
	item.id = id;
	send(ServicesList.SUBMIT,item);
}


protected function application1_creationCompleteHandler(event:FlexEvent):void
{
	Common.eatMe = this;
	
	if(isDebug){
		IP = "127.0.0.1";
	}else{
		if(ExternalInterface.available) {
			var ipStr:String = ExternalInterface.call("function(){return window.location.href;}");
			IP = ipStr.split("http://")[1].split("/eleme.html")[0];		
			ipText.text = IP;
	
			ExternalInterface.addCallback("addToCart", addToCart);
		}
		else {
			Alert.show("fuck!");
		}
	}
	
	this.addElement(billPanel);
}

protected function addedToStageHandler(event:Event):void
{
	this.stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
}

private function stage_keyUpHandler(event:KeyboardEvent):void
{
	if(event.keyCode == Keyboard.B)billPanel.showOrHide();
	
}

private function onInit() : void
{

	SO = SharedObject.getLocal( "LIMY" );
	if(SO.data.name != null) {
		nameSaticText.text = SO.data.name + "您好！";
		guestName = SO.data.name;
		nameSureBtn.visible = false;	
		modifyBtn.visible = true;
		
		connectFWQ();
	}
	
	

}


/**获取菜单请求*/
protected function getBtn_clickHandler(event:MouseEvent):void
{
	send(ServicesList.GET_MENU,null,getMenuCallBack);
}
/**获取菜单返回数据*/
private function getMenuCallBack(success:Boolean, data:Object):void
{
	if(success)
	{
		menus.removeAll();
		for(var i:int=0; i < data.menus.length; i++){
			menus.addItem(data.menus[i]);
		}
		
		if(!isDebug) initHtml(data.url);
		
	}
}




/**确认名字*/
protected function nameSureBtn_clickHandler(event:MouseEvent):void
{
	if(nameText.text != ""){
		nameSaticText.text = nameText.text + "您好！";
		guestName = nameText.text;
		nameSureBtn.visible = false;	
		modifyBtn.visible = true;
		nameText.text = "";
		SO.data.name = guestName;
		SO.flush();
		connectFWQ();
	}
}

/**修改名字*/
protected function modifyBtn_clickHandler(event:MouseEvent):void
{
	if(nameText.text != ""){
		nameSaticText.text = nameText.text + "您好！";
		guestName = nameText.text;
		nameText.text = "";
		SO.data.name = guestName;
		SO.flush();
	}
}

/**左边点单区双击删除*/
protected function eatList_doubleClickHandler(event:MouseEvent):void
{
	var listItem:Object = eatList.selectedItem;
	if(listItem.owner == guestName)
	{
		eatArr.removeItemAt(eatList.selectedIndex);
		
		send(ServicesList.REMOVE_ITEM, listItem);
	}
}


/**接收后端推送更新别人点餐的数据*/
private function updateAccept(data:Object):void
{
	eatArr.removeAll();
	var numTotal:Number = 0;
	var numLeft:Number = 0;
	if(data.hasOwnProperty("eatArr")){
		for(var i:int=0; i < data.eatArr.source.length; i++)
		{
			eatArr.addItem(data.eatArr.source[i]);
			numTotal += Number(String(eatArr[i].price).split("元")[0]);
			if(!eatArr[i].isDone) numLeft += Number(String(eatArr[i].price).split("元")[0]);
		}
	}
	billPanel.moneyArr = eatArr;
	
	totalMoneyText.text = String(numTotal);
	leftMoneyText.text = String(numLeft);
}

/**弹出菜单*/
private function showMoneyList(value:Boolean):void
{
	quanxian = value;
	if(value) qxText.text = "有记账权限";
}



/**
 * 已点区域按名字排序 
 * @param event
 */
protected function sortBtn_clickHandler(event:MouseEvent):void
{
	var sort:Sort = new Sort();
	if(sortBtn.label == "▲")
	{
		sortBtn.label = "▼";
		sort.fields=[new SortField("owner")];
	}else{
		sortBtn.label = "▲"
		sort.fields=[new SortField("owner", true)];
	}
	eatArr.sort = sort;
	eatArr.refresh();
}

/**连接服务器*/
public function connectFWQ():void
{
	initSocket();
	connect(IP, 1208);	
	
}

/**调用html*/
private function initHtml(url:String):void
{
	ExternalInterface.call("setRestaurantSrc",url);
}
