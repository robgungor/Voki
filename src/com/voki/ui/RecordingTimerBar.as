﻿package com.voki.ui {
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class RecordingTimerBar extends MovieClip {
		public var _mcProgress:MovieClip;
		public var _tfStart:TextField;
		public var _tfMiddle:TextField;
		public var _tfEnd:TextField;
		private var totalTime:Number;
		private var timer:Timer;
		
		public function RecordingTimerBar() {
			_tfStart.text = "0";
			timer = new Timer(1000,_mcProgress.totalFrames-1);
			totalTime = parseFloat(_tfEnd.text);
			_mcProgress.gotoAndStop(1);
			timer.addEventListener(TimerEvent.TIMER, onTimerInterval);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimerComplete);
		}
		
		public function setTotalTime(value:Number) {
			totalTime = value;
			_tfEnd.text = Math.round(value).toString();
			_tfMiddle.text = Math.round(value / 2).toString();
			if (_mcProgress.totalFrames == 1) {
				timer.delay = value;
				timer.repeatCount = 1;
			}
			else timer.delay = (value-0.5)*1000 / (_mcProgress.totalFrames-1);
		}
		
		public function startTimer() {
			timer.reset();
			timer.start();
			_mcProgress.gotoAndStop(1);
		}
		
		public function stopTimer() {
			timer.stop();
		}
		
		public function reset() {
			timer.reset();
			_mcProgress.gotoAndStop(1);
		}
		
		private function onTimerInterval(evt:TimerEvent) {
			_mcProgress.gotoAndStop(timer.currentCount+1);
		}
		
		private function onTimerComplete(evt:TimerEvent) {
			_mcProgress.gotoAndStop(_mcProgress.totalFrames);
			dispatchEvent(evt);
		}
		
	}
	
}