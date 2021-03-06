﻿package com.voki.processing {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class ASyncProcessList extends EventDispatcher {
		private var processArr:Array;
		
		public function ASyncProcessList() {
			processArr = new Array();
		}
		
		private function queueProcess(processObj:Object):void {
			//not yet implemented
		}
		
		public function processStarted(processObj:Object, message:String = ""):void {
			var process:ASyncProcess;
			if (processObj is ASyncProcess) process=processObj as ASyncProcess;
			else process = new ASyncProcess(processObj, null, message);
			
			processArr.push(process);
			dispatchEvent(new Event(Event.CHANGE));
			dispatchEvent(new ASyncProcessEvent(ASyncProcessEvent.STARTED, process));
		}
		
		public function processProgress(processObj:Object, percentDone:Number, message:String = null):void {
			var process:ASyncProcess;
			if (processObj is ASyncProcess) process = processObj as ASyncProcess;
			else process = getProcess(processObj);
			if (process == null) return;
			
			process.percentDone = percentDone;
			if (message!=null) process.message = message;
			dispatchEvent(new ASyncProcessEvent(ASyncProcessEvent.PROGRESS, process));
		}
		
		public function processDone(processObj:Object, success:Boolean=true):void {
			var process:ASyncProcess;
			if (processObj is ASyncProcess) process = processObj as ASyncProcess;
			else process = getProcess(processObj);
			if (process == null) return;
			
			process.percentDone = 1;
			process.success = success;
			var i:int = processArr.indexOf(process);
			if (i >= 0) {
				processArr.splice(i, 1);
				dispatchEvent(new Event(Event.CHANGE));
				dispatchEvent(new ASyncProcessEvent(ASyncProcessEvent.DONE, process));
			}
		}
		
		public function processDoneByType(processType:String,success:Boolean=true):void {
			var processArr:Array = getProcessesByType(processType);
			if (processArr.length == 0) return;
			processDone(processArr[0], success);
		}
		
		private function getProcess(processObj:Object):ASyncProcess {
			var process:ASyncProcess;
			for (var i:int = 0; i < processArr.length; i++) {
				process = processArr[i];
				if (process.process == processObj) return(process);
			}
			return(null);
		}
		
		public function getProcessesByType(processType:String):Array {
			var a:Array = new Array();
			var process:ASyncProcess;
			for (var i:int = 0; i < processArr.length; i++) {
				process = processArr[i];
				if (process.processType == processType) a.push(process);
			}
			return(a);
		}
		
		public function isProcessingType(processType:String):Boolean {
			return(getProcessesByType(processType).length > 0);
		}
	}
	
}