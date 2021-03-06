﻿package com.voki.autophoto 
{
	import com.oddcast.assets.structures.EngineStruct;
	import com.oddcast.host.api.FileData;		
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OCheckBox;	
	import com.oddcast.ui.OScrollBar;
	import com.oddcast.ui.Selector;
	import com.oddcast.ui.SelectorItem;
	import flash.external.ExternalInterface;
	import flash.geom.Point;	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import com.voki.data.SessionVars;
	import com.voki.data.SPHostStruct;
	import com.voki.events.SceneEvent;
	import com.oddcast.host.api.API_Constant;
	import com.oddcast.host.api.EditLabel;
	import com.oddcast.data.LibraryThumbSelectorData;
	import com.oddcast.ui.LibrarySelectorItem;
	import com.voki.ui.InfoBubble;	
	import flash.system.Capabilities;
	
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	/**
	 * ...
	 * @author jachai
	 */
	public class AutoPhotoWin extends MovieClip
	{		
		public var _mcTerms:MovieClip;
		public var _mcUpload:MovieClip;
		public var _mcAdjust:MovieClip;
		public var _mcPoints:MovieClip;
		public var _mcMask:MovieClip;
		public var _mcPreview:MovieClip;
		public var _mcProcessing:MovieClip
		public var _mcAPCWin:MovieClip;
		public var _mcBtnClose:BaseButton;
		public var _mcBlocker:MovieClip;
		public var _mcNoticeNo3d:MovieClip;
				
		private var _apc:Object
		private var _loaderAPC:Loader;		
		private var _sSessionId:String;
		private var _bRotateBtnHol:Boolean;
		private var _sCurrentStep:String;
		private var _bAPCLoaded:Boolean;
		private var _sErrorReturnStep:String;
		private var _bInited:Boolean;
		private var _modelLoader:AutoPhotoModelLoader;
		private var _modelAPI:*;
		private var autoPhotoModel:SPHostStruct;
		private var _mcBubble:InfoBubble;
		
		//private var _mcExpressionSelector:Selector;
		//private var expressionsArr:Array;
		//private var expressionsMap:Array;
		private var _mcTeethScrollBar:OScrollBar;
		private var _bTeethScrollerDragged:Boolean;
		
		private var _oa1Uploader:OA1_Uploader;
		private var _sLastOA1Url:String;		
		private var _iLastSavedModelId:int;
		private var _urlVarsLastAPData:URLVariables;
		
		private var _timerExpression:Timer;
		
		private const ANCHOR_CLASS:String = "oc_autophoto_anchor";
		private const MASKPOINT_CLASS:String = "oc_autophoto_maskPoint";
		
		private const MSG_INITIALIZING		:String = 'Initializing ...';
		private const MSG_LOADING			:String = 'Loading ...';
		private const MSG_LOADING_MODEL		:String = 'Retrieving Model';
		private const MSG_UPLOADING_PHOTO	:String = 'Uploading Photo ...';
		private const MSG_PROCESSING_UPLOAD	:String = 'Processing Photo ...';
		
		private const STEP_PROCESSING		:String = 'Processing';
		private const STEP_UPLOAD			:String = 'Upload';
		private const STEP_TERMS			:String = 'Terms';
		private const STEP_MASK				:String = 'Mask';
		private const STEP_POINTS			:String = 'Points';
		private const STEP_ADJUST			:String = 'Adjust';
		private const STEP_PREVIEW			:String = 'Preview';
		
		private const EXPRESSION_TIME		:Number = 3000;//3 seconds
		
		private var expiryTimer:Timer;
		private var demoModelCounter:int = -1;
		
		private var flashPlayerVersion:String; 

		private var osArray:Array;
		private var osType:String 
		
		public function AutoPhotoWin() 
		{
			stop();	
			flashPlayerVersion = Capabilities.version;
			osArray = flashPlayerVersion.split(' ');
			osType = osArray[0]; //The operating system: WIN, MAC, LNX
			//expressionsMap = new Array();
			//expressionsMap[expressionEngineName] = displayname
			//expressionsMap["OpenSmile"] = "Smile";
			//expressionsMap["Sad"] = "Sad";
			//expressionsMap["None"] = "None";
			//expressionsMap["Surprise"] = "Surprise";		
			
			expiryTimer = new Timer(1800000*2, 1); //expire photo after 60 minutes (was 30 changed based on bug #5790)
			expiryTimer.addEventListener(TimerEvent.TIMER_COMPLETE, photoExpired,false,0,true);
			//_mcBlocker.buttonMode=true;
			//_mcBlocker.useHandCursor=false;
			//_mcBlocker.addEventListener(MouseEvent.MOUSE_OVER, function(evt:MouseEvent) { trace("blockerOver")} );
		}
		
		private function loadAPC():void
		{
			gotoStep(STEP_PROCESSING);
			showLoading(MSG_INITIALIZING, 0);
			_loaderAPC = new Loader();
			//APC Parameters
			var apcW:Number = MovieClip(_mcAPCWin.holder).width;
			var apcH:Number = MovieClip(_mcAPCWin.holder).height;
			var dragOffCenter:Boolean = true; //set this to true if you don't want to constrain the photo to the APC box
			var reqUrl:String = SessionVars.apcSwfBaseUrl + "APC.swf?appId=" + SessionVars.apcId + "&apd="+SessionVars.apcBaseUrl+"&apad="+SessionVars.apcAccBaseUrl;
			//var reqUrl:String = SessionVars.apcBaseUrl + "APC.swf?appId=" + SessionVars.apcId;// + "&apd=" + SessionVars.apcBaseUrl + "&apad=" + SessionVars.apcAccBaseUrl;
			//var reqUrl:String = SessionVars.apcSwfBaseUrl + "APC.swf?appId=" + SessionVars.apcId + "&apd="+SessionVars.apcBaseUrl+"&apad="+SessionVars.apcAccBaseUrl;
			reqUrl += "&w=" + apcW + "&h=" + apcH + "&output=1&pd=" + SessionVars.swfDomain 
			reqUrl += "&dragOffCenter=" + (dragOffCenter?1:0) + "&loadFUC=0&erVer=2.0&maskingStep=1&maskingStepMode=body&threshold=100&rnd=" + (Math.random() * 100000);
			var req:URLRequest = new URLRequest(reqUrl);
			var context:LoaderContext = new LoaderContext();
			context.applicationDomain = ApplicationDomain.currentDomain;
			_loaderAPC.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, apcLoadError);
			_loaderAPC.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, apcLoadError);
			_loaderAPC.contentLoaderInfo.addEventListener(Event.COMPLETE, onAPCLoaded);
			_loaderAPC.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onAPCLoadProgress);			
			_loaderAPC.load(req, context);
		}
		
		public function getLastSavedOA1Url():String
		{
			return _sLastOA1Url;
		}
		
		private function photoExpired(evt:TimerEvent) {
			dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp607", "Your photo has expired.  Please submit the photo again."));
			startOverConfirmed(true);
		}
		
		private function apcLoadError(evt:ErrorEvent):void
		{
			if (evt is IOErrorEvent)
			{
				dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp601", "Could not load APC component (IO)"));
			}
			else
			{
				dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp602", "Could not load APC component (Security)"));
			}
		}
		
		private function onAPCLoadProgress(evt:ProgressEvent):void
		{
			var percent:int = Math.round((evt.bytesLoaded * 100) / evt.bytesTotal);
			showLoading(MSG_INITIALIZING, percent);
		}
		
		private function onAPCLoaded(evt:Event):void
		{
			_bAPCLoaded = true;
			_apc = _loaderAPC.content;
			_apc.addEventListener(AutophotoEvent.PHOTO_FILE_DOWNLOADED, onFinishUpload);
			_apc.addEventListener(AutophotoEvent.PROCESSING_PROGRESS,onProcessing);
			_apc.addEventListener(AutophotoEvent.ON_DONE,onProcessingDone);			
			_apc.addEventListener(AutophotoEvent.ON_POINTS, onPointsReady);
			_apc.addEventListener(AutophotoEvent.ON_MASK, onMaskStep);
			_apc.addEventListener(AutophotoEvent.PHOTO_FILE_UPLOAD_ERROR,onError);
			_apc.addEventListener(AutophotoEvent.ON_REDO_POSITION,onError);
			_apc.addEventListener(AutophotoEvent.ON_ERROR, onError);	
			_apc.addEventListener(AutophotoEvent.PHOTO_FILE_SELECTED, onImageSelected);
			_apc.addEventListener(AutophotoEvent.ON_ACTIVITY, onAPCActivity);
			
			_apc.setPointPlacementIcon(ApplicationDomain.currentDomain, ANCHOR_CLASS);
			_apc.setMaskPointIcon(ApplicationDomain.currentDomain,MASKPOINT_CLASS);
			//_apc.setUploadLimits(10, 6 * 1024); //10Kb min 6Mb max
			_apc.setUploadLimits(10, 8 * 1024); //10Kb min 8Mb max (03-05-2014)
			_apc.setMaskDynamicPoints(true);
			//_apc.setMaskBlurRadius(0);
			_apc.setMaskOutline(true);
			_apc.zoomToFaceForPointsPlacement(true);
			_apc.hideCursorForDragging(true);
			
			MovieClip(_mcAPCWin.holder).addChild(_loaderAPC);
			gotoStep(STEP_UPLOAD);			
			
		}
		
		private function onFinishUpload(evt:*):void
		{
			if (expiryTimer != null)
			{
				expiryTimer.reset();
				expiryTimer.start();
			}
			gotoStep(STEP_ADJUST);			
		}
		
		private function onAPCActivity(evt:*):void
		{
			if (expiryTimer != null)
			{
				expiryTimer.reset();
				expiryTimer.start();
			}
		}
		
		private function onProcessing(evt:*):void
		{
			
			var processingObj:Object = evt.data;
			trace("SitepalV5::AutoPhotoWin onProcessing "+processingObj.percent);
			if (processingObj.msg.toLowerCase().indexOf("uploading") >= 0 && int(processingObj.percent) == 100)
			{
				showLoading(MSG_PROCESSING_UPLOAD, -1);
			}
			else
			{
				showLoading(processingObj.msg, processingObj.percent);
			}
		}
		
		private function onPointsReady(evt:*):void
		{
			gotoStep(STEP_POINTS);
			MovieClip(_mcPoints._mcZoomInOut).gotoAndStop(2);
		}
		
		private function onMaskStep(evt:*):void {			
			gotoStep(STEP_MASK);
		}
		
		private function onProcessingDone(evt:*):void
		{
			gotoStep(STEP_PROCESSING);
			showLoading(MSG_LOADING_MODEL, 0)
			expiryTimer.stop();
			/*
			 * //http://host.staging.oddcast.com/autophoto/getAFModelXML.php?sessionId=a5f0b5d63aab56b37d8a450df75dc0f7&gender=male&appId=2 
			
			var url:String=ServerInfo.localURL+"autophoto/getPFModelv2XML.php?doorId="+ServerInfo.door+"&sessionId="+sessionId;
			if (!firstLoad) url += "&next=1";
			XMLLoader.loadXML(url,gotAutoPhotoXML);
			*/
			_apc.getCharXML(gotAutoPhotoXML);
			//XMLLoader.loadXML(SessionVars.apcRetrieveUrl + "?doorId=239&sessionId=" + _sSessionId, gotAutoPhotoXML);
			// build host						
		}
				
		
		private function gotAutoPhotoXML(_xml:XML):void
		{
			var alertEvt:AlertEvent = XMLLoader.checkForAlertEvent("sp700");
			if (alertEvt != null) 
			{
				dispatchEvent(alertEvt);
				gotoStep(STEP_PREVIEW);
				return;
			}
			autoPhotoModel 				= new SPHostStruct(null);
			autoPhotoModel.charXml 							= addRandomToUrls(_xml);
			autoPhotoModel.autoPhotoSessionId 				= parseInt(_sSessionId, 16);
			autoPhotoModel.thumbUrl							= _xml.url.(@id == "thumb").@url.toString();
			autoPhotoModel.is3d = true;
			autoPhotoModel.engine = new EngineStruct(SessionVars.apEngineUrl, SessionVars.apEngineId, SessionVars.apEngineType);
			autoPhotoModel.engine.ctlUrl = SessionVars.apControlUrl;
			autoPhotoModel.name = "new autophoto model";
			autoPhotoModel.isAutoPhoto = true;
			autoPhotoModel.url = SessionVars.apSamSetUrl;				
			_modelLoader.addEventListener(ProgressEvent.PROGRESS, onHostProgress);	
			_modelLoader.addEventListener(SceneEvent.TALK_STARTED,onTalkStarted);
			_modelLoader.addEventListener(SceneEvent.TALK_ENDED,onTalkEnded);
			_modelLoader.addEventListener(SceneEvent.TALK_ERROR,onTalkError);
			_modelLoader.addEventListener(SceneEvent.CONFIG_DONE, onModelLoaded);			
			//_modelLoader.addEventListener(SceneEvent.ACCESSORY_LOADED, onAccLoaded,false,0,true);			
			_modelLoader.addEventListener(ProcessingEvent.PROGRESS, onHostProgress);
			trace("gptAutoPhotoXML autoPhotoModel.charXml=" + autoPhotoModel.charXml );
			_modelLoader.loadModel(autoPhotoModel);			
			
		}
		
		private function addRandomToUrls(_xml:XML):XML
		{			
			var retXML:XML = new XML("<" + _xml.name() + "/>");
			var xmlList:XMLList = _xml.url;			
			for each(var node:XML in xmlList)
			{		
				node.@url += "?rnd=" + Math.random() * 100000;				
				//remove mask if clicked yes at the begining and then no
				if (node.@id.toLowerCase() == "alpha" && Selector(_mcMask.selectorWithMask).getSelectedId() == 1)
				{
					continue;
				}
				else
				{
					retXML.appendChild(node);
				}
			}
			return retXML;
		}
		
		private function onHostProgress(evt:ProcessingEvent):void
		{			
			showLoading(evt.message==null?"Saving Character":evt.message,int(evt.percent*100));
		}
		
		private function onModelLoaded(evt:SceneEvent):void
		{
			trace("AutoPhotoWin::onModelLoaded");
			//resize to fit:
			
			
			
			/*
			var w, h, ratioW, ratioH, ratio:Number;
			w = Sprite(_mcPreview._mcPreviewPlayerHolder._mcPlayer).width;
			h = Sprite(_mcPreview._mcPreviewPlayerHolder._mcPlayer).height;			
			ratioW = MovieClip(_mcPreview._mcPreviewPlayerHolder._mcMask).width / w ;
			ratioH = MovieClip(_mcPreview._mcPreviewPlayerHolder._mcMask).height / h;
			ratio = ratioW < ratioH ? ratioW : ratioH;
			Sprite(_mcPreview._mcPreviewPlayerHolder._mcPlayer).width *= ratio;
			Sprite(_mcPreview._mcPreviewPlayerHolder._mcPlayer).height *= ratio;
			*/
			/*
			Sprite(_mcPreview._mcPreviewPlayerHolder._mcPlayer).scaleX = Sprite(_mcPreview._mcPreviewPlayerHolder._mcPlayer).scaleY = ratio;			
			Sprite(_mcPreview._mcPreviewPlayerHolder._mcPlayer).x -= (w -Sprite(_mcPreview._mcPreviewPlayerHolder._mcPlayer).width);
			Sprite(_mcPreview._mcPreviewPlayerHolder._mcPlayer).y -= (h -Sprite(_mcPreview._mcPreviewPlayerHolder._mcPlayer).height);
			*/
			//trace("AutoPhotoWin::resize ratio="+ratio+", w="+w+", h="+h+", new w="+Sprite(_mcPreview._mcPreviewPlayerHolder._mcPlayer).width+", new h="+Sprite(_mcPreview._mcPreviewPlayerHolder._mcPlayer).height);
			/*
			 * bgMC.addEventListener(Event.INIT, bgLoaded, false, 0, true);
			bgMC.addEventListener(ErrorEvent.ERROR, bgError, false, 0, true);
			
			hostMC.mask=hostMask;
			bgMask=duplicateMask(hostMask)
			player.addChild(bgMask);
			bgMC.mask=bgMask;
			*/
			
			
			_mcPreview._mcPreviewPlayerHolder._mcPlayer.mask = _mcPreview._mcPreviewPlayerHolder._mcMask;
			
			
			var hostMoveZoom:MoveZoomUtil = new MoveZoomUtil(_mcPreview._mcPreviewPlayerHolder._mcPlayer);			
			hostMoveZoom.setScaleLimits(0.1,3);
			hostMoveZoom.boundBy(_mcPreview._mcPreviewPlayerHolder._mcMask,MoveZoomUtil.CONTAINER);
			hostMoveZoom.anchorTo(_mcPreview._mcPreviewPlayerHolder._mcMask);			
			hostMoveZoom.enableDragging(false);
			
			
			_modelAPI = _modelLoader.api;
			//initExpressions();
			
			var defaultTeethWhiteness:Number = _modelAPI.getEditValue(API_Constant.ADVANCED, "mouth brightness");
			trace("defaultTeethWhiteness="+defaultTeethWhiteness);
			_mcTeethScrollBar.percent = defaultTeethWhiteness;
			//_modelAPI.setEditValue(API_Constant.ADVANCED, "mouth brightness", evt.percent, 0);
			
			_sLastOA1Url = "";
			gotoStep(STEP_PREVIEW);
		}
		
		private function onTalkStarted(evt:SceneEvent):void
		{
			
		}
		
		private function onTalkEnded(evt:SceneEvent):void
		{
			
		}
		
		private function onTalkError(evt:SceneEvent):void
		{
			
		}				
		
		private function onImageSelected(evt:*):void
		{
			_mcUpload._tfFilename.text = evt.data;
		}
		
		private function onFileUploadError(evt:*):void	{
			var errObj:Object = evt.data;
			trace("AutoPhotoWin::onFileUploadError error #"+errObj.id+": "+errObj.msg);
			dispatchEvent(new AlertEvent(AlertEvent.ERROR, errObj.id, errObj.msg));
			gotoStep(STEP_UPLOAD);
		}
		
		private function onError(evt:*):void {
			var errObj:Object = evt.data;
			trace("AutoPhotoWin::onError error #"+errObj.id+": "+errObj.msg);
			dispatchEvent(new AlertEvent(AlertEvent.ERROR,errObj.id,errObj.msg,{sessionId:_sSessionId}));
			//some errors are irrecoverible for example resolution
			if (errObj.msg.toLowerCase().indexOf("resolution") >= 0)
			{
				startOverConfirmed(true);
			}
			else if (errObj.msg.toLowerCase().indexOf("adobe flash player") >= 0)
			{
				trace("flash update required");
				closeConfirmed(true);
				_mcProcessing.visible = false;
			}
			else
			{
				if (_sErrorReturnStep == STEP_MASK)
				{
					gotoStep(STEP_POINTS);
				}
				else
				{
					gotoStep(_sErrorReturnStep);			
				}
			}
		}
		
		private function showLoading(msg:String, percent:int):void
		{
			
			_mcProcessing._mcLoadingArt.visible = percent == -1;
			_mcProcessing._tfProcessingPercent.visible = percent != -1;
			
			_mcProcessing._tfProcessingTitle.text = msg;
			_mcProcessing._tfProcessingPercent.text = String(percent) + "%";
		}
		
		private function getFAQText(i:int):String
		{
			switch (i)
			{
				case 1:
					//return  'It depends. There are two options for the PhotoFace background. \n1. You can "mask out" the background in the photo, letting the software animate only the face and body. The avatar can be used with any background from our background gallery. If you select this option, the background in your photo doesn’t matter because it will be cut out.\n2. You can skip masking and have the entire photo animated. In this case, the background in the photo matters because it will be part of the end result and NOT be separable from the avatar. If the hair or clothing is very delicate (which means it will be difficult to mask them out accurately), we recommend you select this option. A solid background (e.g. white wall) works better than a busy one (e.g. on the street).';
					return 'After uploading your photo, you can select from one of two options: \n1. "mask out" (crop) the background in the photo. If you select this option, the original background in the photo is discarded, and you can use your avatar with any background from our background gallery.\n2. Skip masking and have the entire photo animated. In this case, the background in the photo matters because it will be part of the end result and NOT be separable from the avatar. In this case a solid background (e.g. white wall) works better than a busy one (e.g. on the street).';
				case 2:
					//return 'You can\'t customize the PhotoFace avatars. The exact accessories you use in the photo will be the permanent assets for the avatar you created. However, PhotoFace avatars let you change its facial emotions from 4 different choices - happy, sad, angry and surprised.';
					return 'No. PhotoFace avatars cannot be customized with accessories. Note however that facial expressions can be applied to your PhotoFace avatar, i.e. happy, sad, angry etc.';
			}
			return "";
		}
		
		private function faqRollOver(evt:MouseEvent):void
		{
			var faqId:int = int(DisplayObject(evt.target).name.split("_mcBtnFAQ")[1]);
			_mcBubble = new InfoBubble();
			_mcBubble.setContainer(_mcBlocker);
						
			_mcBubble.setText(getFAQText(faqId));
			
			var p:Point = BaseButton(_mcUpload["_mcBtnFAQ" + String(faqId)]).localToGlobal(new Point(0, 0));			
			var pHere:Point = globalToLocal(p);
			
			_mcBubble.x = pHere.x;
			_mcBubble.y = pHere.y - _mcBubble.height;
			this.addChild(_mcBubble);
		}
		
		private function faqRollOut(evt:MouseEvent):void
		{
			var faqId:int = int(DisplayObject(evt.target).name.split("_mcBtnFAQ")[1]);	
			this.removeChild(_mcBubble);
		}
		
		private function agreeClicked(evt:MouseEvent):void
		{
			if (OCheckBox(_mcTerms._mcCheckTerms).selected)
			{	
				Security.allowDomain(SessionVars.apcBaseUrl.split("/")[2]);
				loadAPC();
			}
			else
			{
				dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp600", "You must agree to the terms and conditions before you can create your own."));
			}
		}
		
		private function browseClicked(evt:MouseEvent):void
		{
			_apc.browseFileSystem();			
		}
		
		private function startOverClicked(evt:MouseEvent):void
		{		
			dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "sp606", "You have not saved the following model. Click CANCEL to return and save this model. Click OK to discard this model.", null, startOverConfirmed));			
			
		}
		
		private function startOverConfirmed(ok:Boolean):void
		{
			if (ok)
			{
				_mcAPCWin.visible = true;
				_apc.restart();
				expiryTimer.stop();
				Selector(_mcMask.selectorWithMask).selectById(0);
				_mcUpload._tfFilename.text = "";
				TextField(_mcPreview._tfModelName).text = "";
				gotoStep(STEP_UPLOAD);
			}
		}
		
		private function uploadNextClicked(evt:MouseEvent):void
		{	
			if (OCheckBox(_mcUpload._mcCheckTerms).selected)
			{	
				if (_apc.uploadFile())
				{
					gotoStep(STEP_PROCESSING);
				}			
			}
			else
			{
				dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp600", "You must agree to the terms and conditions before you can create your own."));
			}				
			
			
			
		}
		
		private function termsClicked(evt:MouseEvent):void
		{
			var req:URLRequest = new URLRequest(SessionVars.terms_url); 			
			if (!ExternalInterface.available) {
				trace("Terms Clicked: navigateToURL EI not available");
				navigateToURL(req, "_blank");					
			} else {
				var strUserAgent:String = String(ExternalInterface.call("function() {return navigator.userAgent;}")).toLowerCase();
				if (strUserAgent.indexOf("firefox") != -1 || (strUserAgent.indexOf("msie") != -1 && uint(strUserAgent.substr(strUserAgent.indexOf("msie") + 5, 3)) >= 7)) {
					trace("Terms Clicked: window.open");
					ExternalInterface.call("window.open", req.url, "_blank");
				} else {
					trace("Terms Clicked: navigateToURL based on user agent");
					navigateToURL(req, "_blank");
				}
			}															
		}
		
		private function adjustNextClicked(evt:MouseEvent):void
		{
			gotoStep(STEP_PROCESSING);
			_apc.submit();
			_sSessionId=_apc.getSessionId();						
		}
		
		private function pointsNextClicked(evt:MouseEvent):void
		{
			gotoStep(STEP_PROCESSING);
			_apc.submitWithPoints();
		}
		
		private function pointsZoomClicked(evt:MouseEvent):void
		{
			if (MovieClip(_mcPoints._mcZoomInOut).currentFrame == 1)
			{
				_apc.zoomInFace();
				MovieClip(_mcPoints._mcZoomInOut).gotoAndStop(2);
			}
			else
			{
				_apc.zoomOutFace();
				MovieClip(_mcPoints._mcZoomInOut).gotoAndStop(1);
			}
		}
		
		private function maskNextClicked(evt:MouseEvent):void
		{
			gotoStep(STEP_PROCESSING);
			//_mcAPCWin.visible = true;
			if (Selector(_mcMask.selectorWithMask).getSelectedId() == 0)
			{
				_apc.submitMask();
			}
			else
			{
				_apc.skipMask();
			}
		}
		
		private function genderRadioSelected(evt:SelectorEvent):void
		{
			//previewAudioSample(evt.id);	
			BaseButton(_mcPreview._mcBtnPreview).disabled = false;
		}
		
		private function previewAudioClicked(evt:MouseEvent):void
		{
			previewAudioSample(Selector(_mcPreview.selectorGender).getSelectedId());	
		}
		
		private function editMaskClicked(evt:MouseEvent):void
		{
			_apc.enterPostProcessingMaskStep();
			Selector(_mcMask.selectorWithMask).selectById(0);
			gotoStep(STEP_MASK);
		}
		
		private function maskingRadioSelected(evt:SelectorEvent):void
		{
			
			if (evt.id == 0)
			{
				//_mcAPCWin.visible = true;
				_apc.hideMask(false);
				//_mcMask._mcBullets.gotoAndStop(1);				
			}
			else
			{
				//_mcAPCWin.visible = false;
				_apc.hideMask(true);
				//_mcMask._mcBullets.gotoAndStop(2);							
			}
		}
		
		public function init():void
		{
			if (!_bInited)
			{
				//terms
				BaseButton(_mcTerms._mcBtnFAQ1).addEventListener(MouseEvent.ROLL_OVER, faqRollOver);
				BaseButton(_mcTerms._mcBtnFAQ2).addEventListener(MouseEvent.ROLL_OVER, faqRollOver);
				BaseButton(_mcTerms._mcBtnFAQ1).addEventListener(MouseEvent.ROLL_OUT, faqRollOut);
				BaseButton(_mcTerms._mcBtnFAQ2).addEventListener(MouseEvent.ROLL_OUT, faqRollOut);
				BaseButton(_mcTerms._mcBtnAgree).addEventListener(MouseEvent.CLICK, agreeClicked);
				
				//upload
				BaseButton(_mcUpload._mcBtnBrowse).addEventListener(MouseEvent.CLICK, browseClicked);
				//BaseButton(_mcUpload._mcBtnStartOver).addEventListener(MouseEvent.CLICK, startOverClicked);
				BaseButton(_mcUpload._mcBtnFAQ1).addEventListener(MouseEvent.ROLL_OVER, faqRollOver);
				BaseButton(_mcUpload._mcBtnFAQ2).addEventListener(MouseEvent.ROLL_OVER, faqRollOver);
				BaseButton(_mcUpload._mcBtnFAQ1).addEventListener(MouseEvent.ROLL_OUT, faqRollOut);
				BaseButton(_mcUpload._mcBtnFAQ2).addEventListener(MouseEvent.ROLL_OUT, faqRollOut);
				BaseButton(_mcUpload._mcBtnNext).addEventListener(MouseEvent.CLICK, uploadNextClicked);
				BaseButton(_mcUpload._mcBtnTerms).addEventListener(MouseEvent.CLICK, termsClicked);
				BaseButton(_mcUpload._mcBtnNext).text = "Next";
				
				//adjust
				MovieClip(_mcAdjust._mcZoomCtrls).addEventListener(MouseEvent.CLICK, zoomCtrlClicked);
				MovieClip(_mcAdjust._mcZoomCtrls).addEventListener(MouseEvent.MOUSE_DOWN, zoomCtrlPressed);
				MovieClip(_mcAdjust._mcZoomCtrls).addEventListener(MouseEvent.MOUSE_UP, zoomCtrlReleased);
				MovieClip(_mcAdjust._mcZoomCtrls).addEventListener(BaseButton.RELEASE_OUTSIDE, zoomCtrlReleased);
				MovieClip(_mcAdjust._mcZoomCtrls).addEventListener(BaseButton.MOUSE_HOLD, zoomCtrlHold);
				BaseButton(_mcAdjust._mcBtnStartOver).addEventListener(MouseEvent.CLICK, startOverClicked);
				BaseButton(_mcAdjust._mcBtnNext).addEventListener(MouseEvent.CLICK, adjustNextClicked);				
				BaseButton(_mcAdjust._mcBtnNext).text = "Next";
				
				//points
				BaseButton(_mcPoints._mcBtnStartOver).addEventListener(MouseEvent.CLICK, startOverClicked);
				BaseButton(_mcPoints._mcBtnNext).addEventListener(MouseEvent.CLICK, pointsNextClicked);
				BaseButton(_mcPoints._mcBtnPointsZoom).addEventListener(MouseEvent.CLICK, pointsZoomClicked);
				
				BaseButton(_mcPoints._mcBtnNext).text = "Next";
				
				//mask
				BaseButton(_mcMask._mcBtnStartOver).addEventListener(MouseEvent.CLICK, startOverClicked);
				BaseButton(_mcMask._mcBtnNext).addEventListener(MouseEvent.CLICK, maskNextClicked);
				BaseButton(_mcMask._mcBtnReset).addEventListener(MouseEvent.CLICK, maskResetClicked);
				BaseButton(_mcMask._mcBtnMaskingInfo).addEventListener(MouseEvent.CLICK, maskingInfoClicked);
				BaseButton(_mcMask._mcBtnNext).text = "Next";
				Selector(_mcMask.selectorWithMask).addEventListener(SelectorEvent.SELECTED, maskingRadioSelected);
				Selector(_mcMask.selectorWithMask).add(0, "Yes");
				Selector(_mcMask.selectorWithMask).add(1, "No");
				Selector(_mcMask.selectorWithMask).selectById(0);
				Selector(_mcMask.selectorWithMask).update();
				MovieClip(_mcMask._mcZoomCtrls).addEventListener(MouseEvent.CLICK, zoomCtrlClicked);
				MovieClip(_mcMask._mcZoomCtrls).addEventListener(MouseEvent.MOUSE_DOWN, zoomCtrlPressed);
				MovieClip(_mcMask._mcZoomCtrls).addEventListener(MouseEvent.MOUSE_UP, zoomCtrlReleased);
				MovieClip(_mcMask._mcZoomCtrls).addEventListener(BaseButton.RELEASE_OUTSIDE, zoomCtrlReleased);
				MovieClip(_mcMask._mcZoomCtrls).addEventListener(BaseButton.MOUSE_HOLD, zoomCtrlHold);
				
				if (osType == "MAC")
				{
					_mcMask._tfAddPoint.text = "To add a new point, click while holding down the CMD key";
					_mcMask._tfDeletePoint.text = "To delete a point , Click the point while pressing the CMD & SHIFT keys";					
				}
				var format:TextFormat = new TextFormat();
				format.letterSpacing = -0.4;
				_mcMask._tfAddPoint.setTextFormat(format);
				_mcMask._tfDeletePoint.setTextFormat(format);
				//preview
				BaseButton(_mcPreview._mcBtnStartOver).addEventListener(MouseEvent.CLICK, startOverClicked);
				BaseButton(_mcPreview._mcBtnSave).addEventListener(MouseEvent.CLICK, previewSaveClicked);
				BaseButton(_mcPreview._mcBtnPreview).addEventListener(MouseEvent.CLICK, previewAudioClicked);
				BaseButton(_mcPreview._mcBtnEditMask).addEventListener(MouseEvent.CLICK, editMaskClicked);
				BaseButton(_mcPreview._mcBtnPreview).disabled = true;
				TextField(_mcPreview._tfModelName).maxChars = 50;
				TextField(_mcPreview._tfModelName).restrict = "a-z A-Z 0-9 _&'";
				
				
				//BaseButton(_mcPreview._mcBtnSampleFemale).addEventListener(MouseEvent.CLICK, previewAudioSampleClicked);
				//BaseButton(_mcPreview._mcBtnSampleMale).addEventListener(MouseEvent.CLICK, previewAudioSampleClicked);
				Selector(_mcPreview.selectorGender).addEventListener(SelectorEvent.SELECTED, genderRadioSelected);
				Selector(_mcPreview.selectorGender).add(1, "Female");
				Selector(_mcPreview.selectorGender).add(2, "Male");
				Selector(_mcPreview.selectorGender).deselect();
				Selector(_mcPreview.selectorGender).update();
				_modelLoader = AutoPhotoModelLoader(_mcPreview._mcPreviewPlayerHolder._mcPlayer);
				//_mcExpressionSelector = _mcPreview._mcExpressionSelector;
				_mcTeethScrollBar = _mcPreview._mcTeethScrollBar;
				_mcTeethScrollBar.addEventListener(ScrollEvent.SCROLL, teethWhitenessChanged);
				_mcTeethScrollBar.addEventListener(ScrollEvent.RELEASE, teethWhitenessReleased);
				
				//close
				_mcBtnClose.addEventListener(MouseEvent.CLICK, onCloseClicked);
							
				//uploader
				/*
				_uploader.addEventListener(FileUploadEvent.ON_SELECT, imageSelected);
				_uploader.addEventListener(FileUploadEvent.ON_UPLOAD_START, uploadProcessingStarted);
				_uploader.addEventListener(FileUploadEvent.ON_ERROR, uploadError);
				_uploader.addEventListener(FileUploadEvent.ON_PROGRESS, uploadProgress);
				_uploader.addEventListener(FileUploadEvent.ON_DONE, uploadProgress);
				*/
				
				_mcNoticeNo3d.visible = (!SessionVars.photofaceSaveAllowed && SessionVars.mode != SessionVars.DEMO_MODE);
				
				_bInited = true;
				
			}
			else
			{
				Selector(_mcMask.selectorWithMask).selectById(0);
				Selector(_mcMask.selectorWithMask).update();
				TextField(_mcUpload._tfFilename).text = "";
			}
			if (_bAPCLoaded && _apc!=null)
			{
				_apc.restart();
			}
			if (_bAPCLoaded)
			{
				gotoStep(STEP_UPLOAD);
			}
			else
			{
				Security.allowDomain(SessionVars.apcBaseUrl.split("/")[2]);
				loadAPC();
			}
			//gotoStep(_bAPCLoaded ? STEP_UPLOAD : STEP_TERMS);						
		}
		
		
		
		
		private function teethWhitenessReleased(evt:ScrollEvent):void
		{
			_bTeethScrollerDragged = false;
			_modelAPI.clearExpressionList();
			_modelAPI.setEditValue(API_Constant.ADVANCED, "mouth brightness", evt.percent, 0);			
		}
		
		private function teethWhitenessChanged(evt:ScrollEvent):void
		{
			if (!_bTeethScrollerDragged)
			{
				_bTeethScrollerDragged = true;
				_modelAPI.clearExpressionList();			
				_modelAPI.setExpression("OpenSmile", 1.0, API_Constant.EXPRESSION_PERMENANT, API_Constant.EXPRESSION_PERMENANT);			
				
			}
			
			trace("teethWhitenessChanged " + evt.percent);
			_modelAPI.setEditValue(API_Constant.ADVANCED, "mouth brightness", evt.percent, 0);			
		}
		
		private function maskResetClicked(evt:MouseEvent):void
		{
			_apc.resetMask();
		}
		
		private function maskingInfoClicked(evt:MouseEvent):void
		{
			dispatchEvent(new AlertEvent("about", "sp608"));			
		}
		
		private function previewAudioSample(genderId:int):void
		{
			var audioUrl:String = SessionVars.contentPath + "vhss_editors/media/sample_";
			if (genderId==1)
			{
				audioUrl += "female.mp3"; 
			}
			else
			{
				audioUrl += "male.mp3";
			}
			_modelAPI.stopSpeech();
			_modelAPI.say(audioUrl);
		}
		
		private function onCloseClicked(evt:MouseEvent):void
		{
			if (STEP_UPLOAD != _sCurrentStep && _mcUpload._tfFilename.text.length>0)
			{
				dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "sp606", "You have not saved the following model. Click CANCEL to return and save this model. Click OK to discard this model.", null, closeConfirmed));			
			}
			else
			{
				closeConfirmed(true);
			}
		}
		
		private function closeConfirmed(ok:Boolean)
		{
			if (ok)
			{
				this.visible = false;
				dispatchEvent(new Event(Event.CLOSE));
				if (expiryTimer != null)
				{
					expiryTimer.stop();
				}
				if (_apc != null)
				{
					_apc.restart();
				}
			}
		}
		
		private function previewSaveClicked(evt:MouseEvent):void
		{
			trace("AutophotoWin::previewSaveClicked");		
			if (Selector(_mcPreview.selectorGender).getSelectedId() != 1 && Selector(_mcPreview.selectorGender).getSelectedId() != 2)
			{
				dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp605", "autophotoGenderMissingError"));
				return;
			}
			if (_mcPreview._tfModelName.text.length > 0)
			{				
				_modelAPI.clearExpressionList();
				//get optimized host
				if (autoPhotoModel != null && autoPhotoModel.is3d) {
					gotoStep(STEP_PROCESSING);					
					showLoading("Saving Character", 0);
					if (_sLastOA1Url != "")
					{
						doSaveModel();
						return;
					}
					var hostFileArr:Array = _modelAPI.getFile(API_Constant.OPTIMIZED_HOST);
					trace("AutophotoWin::previewSaveClicked hostFileArr.lenght=" + hostFileArr.length);				
					var hostFile:FileData = hostFileArr[0];
					var t:Timer = new Timer(50);
					t.addEventListener(TimerEvent.TIMER , function (evt:TimerEvent) {
						trace("AutophotoWin::previewSaveClicked hostFile size=" + hostFile.filesize + ", prgs=" + hostFile.progress + ", ext=" + hostFile.extension) 
						if (hostFile.progress == 1)
						{
							t.stop();						
							_oa1Uploader = new OA1_Uploader();
							_oa1Uploader.setOA1ChunkSize(SessionVars.oa1_chunk_size);
							_oa1Uploader.setUploadURL(SessionVars.localBaseURL + "oa1Uploader_multi.php");
							_oa1Uploader.addEventListener(ProcessingEvent.PROGRESS, onHostProgress);
							_oa1Uploader.upload_OA1(hostFile.byteArray, onOA1Saved, onOA1SaveError);
						}
					} );
					t.start();								
				}			
			}
			else
			{
				dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp604", "Model must have a name"));
			}
		}
		
		private function onOA1Saved(s:String):void
		{
			_sLastOA1Url = s;
			doSaveModel();
			
		}
		
		private function doSaveModel():void
		{
			var xmlList:XMLList = autoPhotoModel.charXml.url;
			var apUrls:Object = new Object();
			for each(var node:XML in xmlList)
			{				
				apUrls[node.@id] = node.@url;
			}
			
			//trace("onOA1Saved " + s);
			
			//call saveModel here with the new url
			_urlVarsLastAPData = new URLVariables();			
			_urlVarsLastAPData.modelName = _mcPreview._tfModelName.text;
			_urlVarsLastAPData.oa1File = _sLastOA1Url;
			_urlVarsLastAPData.fgFile = apUrls["fgfile"];
			_urlVarsLastAPData.imgFile = apUrls["photoface"];
			_urlVarsLastAPData.accId = SessionVars.acc;
			if (apUrls["alpha"]!=null)
				_urlVarsLastAPData.maskFile = apUrls["alpha"];
			_urlVarsLastAPData.thumbUrl = apUrls["thumb"];
			_urlVarsLastAPData.genderId = Selector(_mcPreview.selectorGender).getSelectedId();
			//if we add gender it should be set here
			_urlVarsLastAPData.genderId = Selector(_mcPreview.selectorGender).getSelectedId();
			if (SessionVars.mode == SessionVars.DEMO_MODE)
			{
				_iLastSavedModelId = demoModelCounter;// 1;// passing model id 1 for demo mode int(urlVars.ModelId);
				demoModelCounter--;
				dispatchEvent(new Event("onAutophotoModelSaved"));
			}
			else
			{
				XMLLoader.sendAndLoad(SessionVars.localBaseURL + "saveModel.php?rnd=" + (Math.random() * 100000),newModelSavedToDB, _urlVarsLastAPData, URLVariables);	
			}
			
		}
		
		public function getAPModel():SPHostStruct
		{
			return autoPhotoModel;
		}
		
		public function getLastSavedData():URLVariables
		{
			return _urlVarsLastAPData;
		}
		
		public function getLastSavedModelId():int
		{
			return _iLastSavedModelId;
		}
		
		private function newModelSavedToDB(urlVars:URLVariables):void
		{
			if (urlVars.Res == "OK")
			{
				_iLastSavedModelId = int(urlVars.ModelId);
				dispatchEvent(new Event("onAutophotoModelSaved"));
			}
			else
			{
				gotoStep(STEP_PREVIEW);
				if (String(urlVars.Res).toLowerCase().indexOf("auth") >= 0)
				{
					//<alert code="sp609" TYPE="ERROR" NAME="autophotoSaveModelAuthError">There was a problem saving your scene. Your login session has either changed or ended. Please close the editor, login and try editing again ({details})</alert>	
					dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp609", "There was a problem saving your scene. Your login session has either changed or ended. Please close the editor, login and try editing again ({details})",{details:String(urlVars.Res)}));
				}
				else
				{
					dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp603", "Error while saving model: " + String(urlVars.Res).split("-")[1], { details:String(urlVars.Res).split("-") } ));
				}
			}
		}
		
		private function onOA1SaveError(e:AlertEvent):void
		{
			dispatchEvent(e);
		}
		
		private function zoomCtrlClicked(evt:MouseEvent) {			
			if (evt.target.name=="btnReset") _apc.reset();
		}
		
		private function zoomCtrlPressed(evt:MouseEvent) {
			if (evt.target.name == "btnZoomIn") _apc.startZooming(10);
			else if (evt.target.name == "btnZoomOut") _apc.startZooming( -10);
			else if (evt.target.name == "btnMoveLeft") _apc.startPanning(-20,false);
			else if (evt.target.name == "btnMoveRight") _apc.startPanning(20,false);
			else if (evt.target.name == "btnMoveUp") _apc.startPanning(-20,true);
			else if (evt.target.name == "btnMoveDown") _apc.startPanning(20, true);			
			else if (evt.target.name == "btnRotateLeft") _apc.rotate(-1);
			else if (evt.target.name == "btnRotateRight") _apc.rotate(1);
		}
		
		private function zoomCtrlHold(evt:MouseEvent) {
			if (evt.target.name == "btnRotateLeft") _apc.rotate(-5);
			else if (evt.target.name == "btnRotateRight") _apc.rotate(5);
		}
		
		private function zoomCtrlReleased(evt:MouseEvent) {
			if (evt.target.name.indexOf("btnZoom")==0) _apc.stopZooming();
			else if (evt.target.name.indexOf("btnMove")==0) _apc.stopPanning();			
		}
		
		private function gotoStep(step:String):void
		{
			_mcTerms.visible = (step == STEP_TERMS);
			_mcUpload.visible = (step == STEP_UPLOAD);
			_mcAdjust.visible = (step == STEP_ADJUST);
			_mcPoints.visible = (step == STEP_POINTS);
			_mcMask.visible = (step == STEP_MASK);
			_mcPreview.visible = (step == STEP_PREVIEW);
			_mcProcessing.visible = (step == STEP_PROCESSING);
			_mcAPCWin.visible = (step == STEP_ADJUST || step == STEP_POINTS || step == STEP_POINTS || step==STEP_MASK);
			
			_sCurrentStep = step;
			
			if (step != STEP_PROCESSING) 
			{
				_sErrorReturnStep = step;
				_mcBtnClose.disabled = false;
			}
			else
			{
				_mcBtnClose.disabled = true;
			}
			
			
			
		}
		
		//expressions stuff:
		/*
		private function initExpressions() {			
			_timerExpression = new Timer(EXPRESSION_TIME);
			_timerExpression.addEventListener(TimerEvent.TIMER, onExpressionDone);
			DynamicClassGetter.APP_DOMAIN = ApplicationDomain.currentDomain;
			var expressionsArr:Array = _modelAPI.getEditorList(API_Constant.EXPRESSION);	
			
			_modelAPI.clearExpressionList();						
			_mcExpressionSelector.addEventListener(SelectorEvent.SELECTED, expressionChanged);			
			var selectorThumb:LibraryThumbSelectorData = new LibraryThumbSelectorData("exp_none_enable", "exp_none_rollover", "exp_none_press", null, "");
			_mcExpressionSelector.add(0, "None", selectorThumb);
			for (var i:int=0;i<expressionsArr.length;++i)
			{			
				trace("AutophotoWin::initExpressions "+expressionsArr[i]);
				if (expressionsMap[expressionsArr[i]] != null)
				{
					var expDisplayName:String = expressionsMap[expressionsArr[i]];
					var enableLibName:String = "exp_" + expDisplayName.toLowerCase() + "_enable";
					var rolloverLibName:String = "exp_" + expDisplayName.toLowerCase() + "_rollover";
					var pressLibName:String = "exp_" + expDisplayName.toLowerCase() + "_press";
					trace("enableLibName=" + enableLibName + ", rolloverLibName=" + rolloverLibName);
					selectorThumb = new LibraryThumbSelectorData(enableLibName, rolloverLibName, pressLibName, null, expressionsArr[i]);
					_mcExpressionSelector.add(i+1, expDisplayName, selectorThumb);
				}				
			}
			_mcExpressionSelector.selectById(0);
		}						
		
		private function expressionChanged(evt:SelectorEvent):void
		{
			_modelAPI.clearExpressionList();			
			if (evt.id > 0)
			{
				_modelAPI.setExpression(String(LibraryThumbSelectorData(evt.obj).obj), 1.0, API_Constant.CURRENT_TIME, API_Constant.CURRENT_TIME + EXPRESSION_TIME);			
				_timerExpression.start();
			}
		}	
		
		private function onExpressionDone(evt:TimerEvent):void
		{
			_modelAPI.clearExpressionList();
			_mcExpressionSelector.selectById(0);
			_timerExpression.reset();
			_timerExpression.stop();
		}
		*/
	}
	
}