﻿package com.voki.panels {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.SendEvent;
	import com.oddcast.ui.OCheckBox;
	import com.oddcast.utils.EmailValidator;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import fl.managers.FocusManager;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class EmailPopup extends MovieClip {
		public var tf_toEmail:TextField;
		public var tf_fromEmail:TextField;
		public var tf_message:TextField;
		public var cb_mailingList:OCheckBox;
		public var sendBtn:SimpleButton;
		public var closeBtn:SimpleButton;
		private var _bInitied:Boolean;
		private var focusManager:FocusManager;
	
		public function EmailPopup() {
			closeBtn.addEventListener(MouseEvent.CLICK, onClose);
			sendBtn.addEventListener(MouseEvent.CLICK, onSend);
			
			tf_toEmail.tabIndex=1;
			tf_fromEmail.tabIndex=2;
			tf_message.tabIndex = 3;
			
		}
		
		public function init() {
			if (!_bInitied)
			{
				tf_toEmail.text = "";
				tf_message.text = "";
				tf_fromEmail.text = "";
				focusManager = new FocusManager(this);
				cb_mailingList.selected = false;
				_bInitied = true;
			}
		}

		private function closeWin() {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function onClose(evt:MouseEvent) {
			closeWin();
		}
		
		private function onSend(evt:MouseEvent) {
			if (!EmailValidator.validate(tf_toEmail.text)) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp103", "Invalid Email Address"));
				return;
			}
			if (!EmailValidator.validate(tf_fromEmail.text))  {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp103", "Invalid Email Address"));
				return;
			}
			
			var messageXML:XML = new XML("<message />");
			messageXML.to.email=tf_toEmail.text;
			messageXML.from.email=tf_fromEmail.text;
			messageXML.body=tf_message.text;
			messageXML.optin = cb_mailingList.selected?"1":"0";
			
			closeWin();
			dispatchEvent(new SendEvent(SendEvent.SEND, "email", messageXML));
		}
	}
	
}