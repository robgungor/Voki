﻿package com.voki.data {
	import com.oddcast.audio.AudioData;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class FAQQuestion {
		public var question:String;
		public var audio:AudioData;
		
		public function FAQQuestion(q:String="",a:AudioData=null) {
			question = q;
			audio = a;
		}
	}
	
}