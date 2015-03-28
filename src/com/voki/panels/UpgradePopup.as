﻿package com.voki.panels {
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import com.voki.data.SessionVars;
	
	import flash.net.URLRequest;
	
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class UpgradePopup extends MovieClip {
		public var upgradeBtn:SimpleButton;
		
		public function UpgradePopup() {
			visible = false;
			upgradeBtn.addEventListener(MouseEvent.CLICK, onUpgrade);
		}
		
		private function onUpgrade(evt:MouseEvent) {
			/*if (root.upgradeFromFree.visible) {//isaac
				openStoreURL();
			}else {
				
			}*/
			ExternalInterface.call("upgradeAccount", SessionVars.acc);
		}
		
		/*private function openStoreURL() { //isaac
			var url:String = SessionVars.adminURL + "redirector.php?gotostore=1&accID=" + SessionVars.acc + "&page=additionalModels.php";// & modelId = " + curModel.id;
			var req:URLRequest = new URLRequest(url);
			if (!ExternalInterface.available) {
				navigateToURL(req, "_blank");					
			} else {
				var strUserAgent:String = String(ExternalInterface.call("function() {return navigator.userAgent;}")).toLowerCase();
				if (strUserAgent.indexOf("firefox") != -1 || (strUserAgent.indexOf("msie") != -1 && uint(strUserAgent.substr(strUserAgent.indexOf("msie") + 5, 3)) >= 7)) {
					ExternalInterface.call("window.open", req.url, "_blank");
				} else {
					navigateToURL(req, "_blank");
				}
			}					
		}*/
	}
	
}