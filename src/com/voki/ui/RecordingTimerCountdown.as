﻿package com.voki.ui {
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class RecordingTimerCountdown extends MovieClip {
		public var timeMC:MovieClip;
		private var totalTime:Number;
		private var timer:Timer;
		private var _iTimerStartTime:int;
		private var _iRecTime:int;
		
		public function RecordingTimerCountdown() {
			gotoAndStop(1);
			timer = new Timer(667);
			timer.addEventListener(TimerEvent.TIMER, onTimerInterval);
			//timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			//setTotalTime(60);
		}
		
		public function get tf_time():TextField {
			return(timeMC.tf_time as TextField);
		}
		
		public function setTotalTime(value:Number) {
			totalTime = Math.floor(value);
			_iRecTime = int(totalTime);
			//timer.repeatCount = totalTime;
			reset();
		}
		
		public function startTimer() {
			reset();			
			_iTimerStartTime = getTimer();
			timer.start();
		}
		
		public function stopTimer() {
			timer.stop();
		}
		
		public function reset() {
			timer.reset();
			gotoAndStop(1);
			tf_time.text = ":" + totalTime.toString();
		}
		
		private function onTimerInterval(evt:TimerEvent) {			
			//trace("onTimerInterval:: _iRecTime="+_iRecTime+", d.getTime()="+getTimer()+", _iTimerStartTime="+_iTimerStartTime+" -> "+int((getTimer() - _iTimerStartTime) / 1000))
			var timeRemaining:int = _iRecTime - int((getTimer() - _iTimerStartTime) / 1000)-1;						
			tf_time.text = ":" + (timeRemaining).toString();
			if (timeRemaining <=0)
			{
				tf_time.text = ":00";
				play();
			}
		}
		
		private function onTimerComplete(evt:TimerEvent) {
			tf_time.text = ":00";
			play();
			dispatchEvent(evt);
		}
	}
	
}