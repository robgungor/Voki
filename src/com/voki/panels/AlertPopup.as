﻿package com.voki.panels {
	import com.oddcast.event.AlertEvent;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.voki.data.AlertLookup;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AlertPopup extends MovieClip {
		public var tf_title:TextField; //only for "about" popup
		public var tf_alert:TextField;
		public var tf_ok:TextField;
		private var callback:Function = null;
		//private var msgLookup:TranslationLookup;
		public var okBtn:SimpleButton;
		public var cancelBtn:SimpleButton;
		
		public var alertLookup:AlertLookup;
		
		public function AlertPopup() {
			okBtn.addEventListener(MouseEvent.CLICK, onOK, false, 0, true);
			if (cancelBtn != null) cancelBtn.addEventListener(MouseEvent.CLICK, onCancel, false, 0, true);
			
		}
		
		private function onKeyPressed(evt:KeyboardEvent) {
			if (!visible) return;
			trace("key perssed : " + evt.keyCode);
			if (evt.keyCode == Keyboard.ENTER /*&& !(stage.focus is TextField)*/) onOK(null);
			if (evt.keyCode == Keyboard.ESCAPE) onCancel(null);
		}
		
		protected function onOK(evt:MouseEvent) {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			dispatchEvent(new Event(Event.CLOSE));
			if (callback != null) callback(true);
			callback = null;
			
		}
		
		protected function onCancel(evt:MouseEvent) {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			dispatchEvent(new Event(Event.CLOSE));
			if (callback != null) callback(false);
			callback = null;
			
		}
		
		/*public function setMessageTable(messageTable:TranslationLookup) {
			msgLookup = messageTable;
		}*/
		
		public function alert(evt:AlertEvent, fatal:Boolean = false) {
			var alertText:String;
			if (alertLookup == null) alertText = evt.text;
			else {
				alertText = alertLookup.translate(evt.code, evt.text, evt.moreInfo);
				if (tf_title != null) tf_title.text = alertLookup.titleOf(evt.code);
			}
			trace("AlertPopup::alert evt="+evt)
			
			trace("AlertPopup::alert fatal="+fatal);
			tf_alert.text=alertText;
			//visible = true;
			if (evt.callback != null) callback = evt.callback;
			if (fatal)
			{
				okBtn.visible = false;
				if (tf_ok != null)
				{
					tf_ok.visible = false;
				}
			}
			else
			{
				okBtn.visible = true;
				if (tf_ok != null)
				{
					tf_ok.visible = true;
					tf_ok.mouseEnabled = false;
				}
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			}
			//report error
			//ErrorReporter.report(evt,alertText);
		}
		
	}
	
}