import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;

import net.ServicesList;

/**所有人的结账数据*/
[Bindable]
public var moneyArr:ArrayCollection = new ArrayCollection();

private var _isShow:Boolean = false;

/**双击账单表示确认收账*/
protected function moneyList_doubleClickHandler(event:MouseEvent):void
{
	
	var item:Object = moneyList.selectedItem;
	item.isDone = !item.isDone;
	moneyArr.itemUpdated(item);
	Common.eatMe.send(ServicesList.SEND_TO_FWQ, moneyArr);
	
}

public function showOrHide():void
{
	TweenMax.killTweensOf(this);
	TweenMax.to(this, 0.2, {visible:_isShow ? 0 : 1, ease:Linear.easeNone});
	_isShow = !_isShow;
}


public function get isShow():Boolean { return _isShow; }


protected function titlewindow1_creationCompleteHandler(event:FlexEvent):void
{		
	this.visible = false;
	
}