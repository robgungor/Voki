﻿package com.voki.data {
	
	/**
	* ...
	* @author Sam Myer
	* 
	* 
	* 
	*/
	public class AlertLookup {
		private var alerts:Object;
		private var titles:Object;
		
		public function AlertLookup(_xml:XML) {
			alerts = new Object();
			titles = new Object();
			parse(_xml);
		}
		
		public function parse(_xml:XML) {
			var xalert:XML;
			var xcode:String;
			for (var i:int = 0; i < _xml.alert.length(); i++) {
				xalert = _xml.alert[i];
				xcode = xalert.@code.toString();
				alerts[xcode] = xalert.toString();
				if (xalert.hasOwnProperty("@title")) titles[xcode] = xalert.@title.toString();
			}
		}
		
		public function translate(key:String, defaultVal:String = "", varReplace:Object = null):String {
			var val:String;
			if (key == null || key == ""||alerts[key]==undefined) val=defaultVal;
			else val = alerts[key];
			
			var infoKey:String;
			//replace placeholders in text surrounded by {} brackets with values from evt.moreInfo
			//e.g. "You cannot use the word {badWord}" - becomes - You cannot use the word "balzac"
			if (varReplace != null) {
				for (infoKey in varReplace) {
					val = val.split("{" + infoKey + "}").join(varReplace[infoKey]);
				}
			}
			return(val);
		}
		
		public function titleOf(key:String):String {
			if (key == null || key == ""||titles[key]==undefined) return("");
			else return(titles[key]);
		}
	}
	
}