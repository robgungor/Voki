﻿package com.voki  {
	import com.oddcast.assets.structures.EngineStruct;
	import com.oddcast.ui.OComboBox;
	import com.oddcast.utils.MoveZoomUtil;
	import com.voki.ui.StudioMoveZoomControls;
	//import com.oddcast.audio.AudioData;
	import com.oddcast.audio.TTSVoiceList;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.AudioEvent;
	//import com.oddcast.event.ModelEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.event.SendEvent;
	import com.oddcast.event.SkinSelectEvent;
	import com.oddcast.event.VHSSEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.StickyButton;
	import com.oddcast.utils.CustomCursor;
	import com.oddcast.utils.XMLLoader;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import com.voki.data.AlertLookup;
	import com.voki.data.SceneStruct;
	import com.voki.data.SessionVars;
	import com.voki.data.ShowStruct;
	import com.voki.data.SkinConfiguration;
	import com.voki.data.SPAudioList;
	import com.voki.data.SPHostStruct;
	import com.voki.data.SPModelList;
	import com.voki.data.SPSkinStruct;
	import com.voki.events.AssetIdEvent;
	import com.voki.nav.NavigationBar;
	import com.voki.nav.NavigationController;
	import com.voki.nav.NavPanelStruct;
	import com.voki.nav.NavWindow;
	import com.voki.nav.PopupController;
	import com.voki.panels.AccessoryPanel;
	import com.voki.panels.AISkinPanel;
	import com.voki.panels.AlertPopup;
	import com.voki.panels.InfoPopup;
	//import sitepal.panels.BackgroundPanel;
	//import sitepal.panels.BuyModelPopup;
	import com.voki.panels.ColorPanel;
	import com.voki.panels.ExpressionsPanel;
	import com.voki.panels.FAQSkinPanel;
	import com.voki.panels.LeadSkinPanel;
	import com.voki.panels.CopySettingsPopup;
	//import sitepal.panels.MicPanel;
	//import sitepal.panels.ModelPanel;
	//import sitepal.panels.PhonePanel;
	//import sitepal.panels.PhotoFacePanel;
	//import sitepal.panels.SavedAudioPanel;
	//import sitepal.panels.SavedBGPanel;
	//import sitepal.panels.SavedCharPanel;
	import com.voki.panels.SizingPanel;
	import com.voki.panels.SkinPanel;
	import com.voki.panels.SkinSettingsPanel;
	import com.voki.panels.StandardSkinPanel;
	//import sitepal.panels.TTSPanel;
	import com.voki.panels.UpgradePopup;
	//import sitepal.panels.UploadAudioPanel;
	//import sitepal.panels.VoiceTalentPanel;
	import com.voki.player.PlayerController;
	import com.voki.player.ThumbSaver;
	import com.voki.processing.ASyncProcess;
	import com.voki.processing.ASyncProcessEvent;
	import com.voki.tracking.SPEventTracker;
	//import sitepal.ui.MoveZoomControls;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SceneEditor extends MovieClip {
		private var show:ShowStruct;
		
		public var loadingBar:MovieClip;
		public var navBar:NavigationBar;
		public var navWin:NavWindow;
		public var navController:NavigationController;
		public var playerMC:MovieClip;
		public var playerController:PlayerController;
		public var popups:PopupController;
		
		private var previewBtn:StickyButton;
		private var thumbSaver:ThumbSaver;
		
		//private var modelList:SPModelList;
		private var audioList:SPAudioList;
		private var alertLookup:AlertLookup;
		private var publishMode:String;
		private var publishEvent:SendEvent;
		private var savedSkin:SPSkinStruct;
		
		//private var modelPanel:ModelPanel;
		//private var photoFacePanel:PhotoFacePanel;
		//private var bgPanel:BackgroundPanel;
		//private var savedBgPanel:SavedBGPanel;
		//private var savedCharPanel:SavedCharPanel;
		//private var colorPanel:ColorPanel;
		private var expressionsPanel:ExpressionsPanel;
		//private var sizingPanel:SizingPanel;
		//private var accPanel:AccessoryPanel;
		//private var ttsPanel:TTSPanel;
		//private var micPanel:MicPanel;
		//private var uploadAudioPanel:UploadAudioPanel;
		//private var phonePanel:PhonePanel;
		//private var savedAudioPanel:SavedAudioPanel;
		private var skinPanel:SkinPanel;
		private var standardSkinPanel:StandardSkinPanel;
		private var leadSkinPanel:LeadSkinPanel;
		private var aiSkinPanel:AISkinPanel;
		private var faqSkinPanel:FAQSkinPanel;
		
		//public var upgradeTTSWin:UpgradePopup;
		//public var upgradePhotofaceWin:UpgradePopup;
		public var upgradeSkinWin:UpgradePopup;
		//public var upgradeModelWin:BuyModelPopup;		
		private var _mcComboGoToScene:OComboBox;
		private var _mcBtnCopySettings:BaseButton;
		
		//public var _mcBtnTest:MovieClip;
		public var btnSitepal:BaseButton;
		private var _bIntroClosed:Boolean;
		private var _bOriginalSceneWas2D:Boolean;
		private var _bHostInvisibleMode:Boolean;
		
		private var _bFirstModelLoaded:Boolean;
		public var panel_copy_settings:CopySettingsPopup;
		private var moveZoomControls:StudioMoveZoomControls;
		
		public var _mcBigViewBlocker:MovieClip;
		private var origPlayerX:Number;
		private var origPlayerY:Number;
		private var bigPlayerView:Boolean;
		public var _mcOddcastLogo:MovieClip;
		
		private var skinSettingsPanel:SkinSettingsPanel;
		private var _bIsFrozen:Boolean;
		
		public function SceneEditor() {
			SessionVars.editorMode = "SceneEditor";
			SessionVars.editorVer = "07.21.2010 10:46";
			showLoadingMessage("Loading interface");
			initContextMenu();
			
			
			
		}
		
		private function initContextMenu() {
			var myMenu:ContextMenu = new ContextMenu();
			myMenu.hideBuiltInItems();

			var menuItem1:ContextMenuItem = new ContextMenuItem("Powered by Oddcast");
			var menuItem2:ContextMenuItem = new ContextMenuItem("SceneEditor Ver "+SessionVars.editorVer);
			menuItem1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, openOddcastSite);
			myMenu.customItems.push(menuItem1);
			myMenu.customItems.push(menuItem2);
			contextMenu = myMenu; 			
		}
				
		
		private function onSceneWithInvisibleHost(evt:Event):void
		{
			_bHostInvisibleMode = true;			
		}
		
		public function swfLoaded() {
			//_mcBtnTest.addEventListener(MouseEvent.CLICK, testClicked);
			SessionVars.setLoaderInfo(loaderInfo);
			navBar.visible = false;
			navBar.addEventListener(SelectorEvent.SELECTED, onNavBarWinSelected);
			_mcBigViewBlocker.visible = false;
			origPlayerX = playerMC.x;
			origPlayerY = playerMC.y;
			playerMC.visible = false;
			playerMC.playerHolder.mask = playerMC.playerMask;
			playerMC.playerMask.visible = false;			
			_mcComboGoToScene = playerMC._mcComboGoToScene;
			_mcComboGoToScene.addEventListener(SelectorEvent.SELECTED, sceneSelected);
			_mcBtnCopySettings = playerMC._mcBtnCopySettings;
			_mcBtnCopySettings.addEventListener(MouseEvent.CLICK, copySettingsClicked);
			playerController = new PlayerController(playerMC.playerHolder);
			playerController.addEventListener(PlayerController.HOST_LOADED, hostLoaded);
			playerController.addEventListener(PlayerController.SCENE_LOADED, sceneLoaded);
			playerController.addEventListener(PlayerController.SKIN_LOADED, skinLoaded);
			playerController.addEventListener(PlayerController.SKIN_TYPE_CHANGED, skinTypeChanged);
			
			
			playerController.processList.addEventListener(ASyncProcessEvent.STARTED,onProcessingStarted);
			playerController.processList.addEventListener(ASyncProcessEvent.DONE,onProcessingEnded);
			playerController.addEventListener(VHSSEvent.TALK_STARTED, onTalkStarted);
			playerController.addEventListener(VHSSEvent.TALK_ENDED, onTalkEnded);
			playerController.addEventListener(VHSSEvent.SCENE_PLAYBACK_COMPLETE, onSceneAudioEnded);
			playerController.addEventListener(VHSSEvent.PLAYER_DATA_ERROR, onPlayerDataError);
			playerController.addEventListener(VHSSEvent.AUDIO_ERROR, onAudioError);
			playerController.addEventListener(PlayerController.HOST_INVISIBLE, onSceneWithInvisibleHost);
					
			previewBtn = playerMC.bottomPanel.playBtn as StickyButton;
			previewBtn.addEventListener(SelectorEvent.SELECTED, onPreviewScene);
			previewBtn.addEventListener(SelectorEvent.DESELECTED, onStopScene);
			
			popups = new PopupController(this);
			CustomCursor.setStage(stage);
			getSessionInfo();
			_mcOddcastLogo.visible = false;
			//getAccountInfo();
			XMLLoader.retries = 2;
		}
		
		private function copySettingsClicked(evt:MouseEvent):void
		{
			panel_copy_settings.setPlayer(playerController);
			panel_copy_settings.openPanel();
		}
		
		private function sceneSelected(evt:SelectorEvent):void
		{
			playerController.gotoScene(_mcComboGoToScene.getSelectedId());
		}
		
		private function showLoadingMessage(msg:String, percent:Number = Number.NaN) {
			if (loadingBar.tf_loading != null) loadingBar.tf_loading.text = msg;
		}
		
		
		private function getSessionInfo() {
			showLoadingMessage("Loading session info");
			var rand:String = Math.floor(Math.random() * 1000000).toString();
			var url:String = SessionVars.localBaseURL + "getSessionV5.php?dr=" + SessionVars.doorId;
			if (SessionVars.sessionId != null)
			{
				url += "&PHPSESSID=" + SessionVars.sessionId;
			}
			XMLLoader.loadVars(url, gotSessionInfo);
			//setInterval(this,"preventSessionExpiry",900000)
		}
		
		private function gotSessionInfo(urlVars:URLVariables) {
			if (urlVars != null)
			{
				if (int(urlVars.showId) > 0 && SessionVars.sessionId==null)
				{
					SessionVars.showId = urlVars.showId;
				}
				SessionVars.sessionId = urlVars.PHPSESSID;
				SessionVars.acc = urlVars.accId;
				SessionVars.userId = int(urlVars.gUserId);
				SessionVars.userEmail = String(urlVars.email);
			}			
			getAccountInfo();
		}
		
		private function getAccountInfo() {
			showLoadingMessage("Loading account info");
			var rand:String = Math.floor(Math.random() * 1000000).toString();
			if (SessionVars.loggedIn)
			{
				XMLLoader.loadXML(SessionVars.localBaseURL + "getAccountInfoV5.php?acc=" + SessionVars.acc, gotAccountInfo);				
			}
			else
			{
				XMLLoader.loadXML(SessionVars.baseURL + "getAccountInfoV5/acc=" + SessionVars.acc, gotAccountInfo);
			}			
			//setInterval(this,"preventSessionExpiry",900000)
		}
		
		private function gotAccountInfo(_xml:XML) {
			if (_xml != null)
			{
				SessionVars.setFromXML(_xml);
			}			
			getAlertText();
		}
		
		private function getAlertText() {
			showLoadingMessage("Loading alerts");
			//alertLoader = new AlertLoader(SessionVars.localBaseURL + "xml/alertsv4.xml");
			XMLLoader.loadXML(SessionVars.contentPath + "vhss_editors/xml/alertsv5.xml", gotAlertText);
		}
		
		private function gotAlertText(_xml:XML) {
			if (_xml!=null) alertLookup = new AlertLookup(_xml);
			loadPlayer();
		}
		
		private function loadPlayer() {
			showLoadingMessage("Loading scene");
			playerController.addEventListener(Event.INIT, playerLoaded);			
			var rand:Number = Math.floor(Math.random() * 100000);
			var url:String=SessionVars.acceleratedURL + "/php/playScene/acc=" + SessionVars.acc + "/ss=" + SessionVars.showId+"/editor=1/&rand="+rand
			playerController.init(url);
		}
		
		private function playerLoaded(evt:Event) {
			playerController.removeEventListener(Event.INIT, playerLoaded);
			show = playerController.getShow();
			playerController.gotoScene(SessionVars.slideIndex);
			
			if (SessionVars.sessionId.length > 0) {
				var url:String = SessionVars.acceleratedURL + "/vhss_editors/getSession.php?PHPSESSID=" + SessionVars.sessionId;
				//XMLLoader.sendAndLoad(url, null, null, String);
			}
			//updateAccessoryPanelVisibility();
			
			
			//updateAccessoryPanelVisibility();
			_bOriginalSceneWas2D = playerController.scene.model.type.toLowerCase().indexOf("2d") >= 0;
			SessionVars.origCharId = show.scene.char.id;			
			trace("Sitepal::SessionVars.origCharId=" + SessionVars.origCharId);
			//modelList = new SPModelList();
			audioList = new SPAudioList();
			savedSkin = show.scene.skin;
			SessionVars.trackingURL = show.trackingUrl;
			if (SessionVars.hasTracking) {				//initTracker;
				var skinId:int;
				if (savedSkin != null) skinId = savedSkin.id;
				//SPEventTracker.init(SessionVars.trackingURL, { apt:"S", acc:SessionVars.acc, shw:SessionVars.showId, skn:skinId, prt:SessionVars.partnerId, dom:SessionVars.domain } )
			}
			
			//trace("show.scene = " + show.scene);
			moveZoomControls = playerMC.bottomPanel.moveZoomPanel as StudioMoveZoomControls;
			moveZoomControls.setTarget(playerController.zoomer);
			moveZoomControls.addEventListener("viewChange", playerViewChanged);
			
			trace("SessionVars.userEmail=" + SessionVars.userEmail);
			/*
			if (SessionVars.userEmail == "jon@oddcast.com")
			{
				SessionVars.noIntro = true;
			}
			*/
			btnSitepal.addEventListener(MouseEvent.CLICK, openOddcastSite);	
			startAnimation();	
			/*
			if (SessionVars.noIntro || SessionVars.mode == SessionVars.PARTNER_MODE)
			{
				_bIntroClosed = true;
				startAnimation();	
			}
			else
			{
				popups.openPopup(popups.introWin);				
				popups.introWin.addEventListener(Event.CLOSE, onIntroWinClosed);
				popups.introWin.addEventListener("introReady", onIntroReady);
				playerController.freeze();
				popups.introWin.visible = false;
				popups.introWin.init();
			}
			*/
		}				
		
		private function playerViewChanged(evt:Event):void
		{
			if (!bigPlayerView)
			{
				playerMC.scaleX = playerMC.scaleY = 2.06;
				playerMC.x = 67;
				playerMC.y = 11;
				_mcBigViewBlocker.visible = true;
				bigPlayerView = true;
				_mcOddcastLogo.visible = false;
			}
			else
			{
				playerMC.scaleX = playerMC.scaleY = 1;
				playerMC.x = origPlayerX;
				playerMC.y = origPlayerY;
				_mcBigViewBlocker.visible = false;
				bigPlayerView = false;
				_mcOddcastLogo.visible = true;
			}
		}
		
		private function startAnimation() {
			loadingBar.addEventListener("animationComplete", loadingAnimationComplete);
			loadingBar.gotoAndPlay(2);
		}
		
		private function loadingAnimationComplete(evt:Event) {
			navBar.visible = true;
			navBar.initShareButtons();
			_mcOddcastLogo.visible = true;
			showScene();			
		}
		
		private function openOddcastSite(evt:*):void
		{									
			var req:URLRequest = new URLRequest(SessionVars.oddcast_url); 			
			if (!ExternalInterface.available) {
				trace("Terms Clicked: navigateToURL EI not available");
				navigateToURL(req, "sitepalWin");					
			} else {
				var strUserAgent:String = String(ExternalInterface.call("function() {return navigator.userAgent;}")).toLowerCase();
				if (strUserAgent.indexOf("firefox") != -1 || (strUserAgent.indexOf("msie") != -1 && uint(strUserAgent.substr(strUserAgent.indexOf("msie") + 5, 3)) >= 7)) {
					trace("Terms Clicked: window.open");
					ExternalInterface.call("window.open", req.url, "sitepalWin");
				} else {
					trace("Terms Clicked: navigateToURL based on user agent");
					navigateToURL(req, "sitepalWin");
				}
			}							
			
		}
				
		
		private function showScene() {
			playerMC.visible = true;
			
			//don't play intro audio if not logged in, or if there is no model
			//if (show.scene.model != null && SessionVars.loggedIn) playerController.playAudio(show.scene.audio);
			
			//navBar = loadingBar.navBar;
			
			navController = new NavigationController(navBar, navWin);
			navController.addEventListener("panelOpened", navPanelOpened);
			navController.addEventListener("winTabSelectedManually", navPanelOpenedManually);
			navController.addEventListener(AlertEvent.ERROR, catchError);
			
						
			navBar.addEventListener("saveClick", onSaveClick);
			
			
			initPanels();
			if (_bHostInvisibleMode)
			{
				playerController.addEventListener(PlayerController.HOST_LOADED, function (evt:Event)
				{
					playerController.setHostToVisible(true);
					_bHostInvisibleMode = false;					
				});
				//modelPanel.selectFirstModel();	
				
			}
			//upgradeModelWin.addEventListener(AssetIdEvent.MODEL_PURCHASED, modelPurchased);
			addEventListener(AlertEvent.ERROR, catchError);
			SessionVars.navController = navController;
			
			navController.selectPanel(skinPanel);
			navBar.selectedTab = 4;	
			var type:String = show.sceneArr[SessionVars.slideIndex - 1].model.type;
			if (navController == null) return;
			
			/*
			if (type == "host_2d" || type.toUpperCase()=="2D")
			{										
									
				navBar.step2Btn.disabled = true;				
			}
			*/
			//updateAccessoryPanelVisibility();
			//navBar.selectedTab = 1;
			//navController.selectPanel(accPanel);
		}
		
		
		
		private function initPanels() {	
			var ttsVoiceList:TTSVoiceList = new TTSVoiceList();
			ttsVoiceList.url = SessionVars.baseURL + "getTTSList/partnerId=" + SessionVars.partnerId;
			
			//audioList.addEventListener("accountAudiosUpdated", privateAudioCountUpdated);
			
			//popups.editTTSWin.voiceList = ttsVoiceList;
			popups.selectAudioWin.data = audioList;
			//popups.selectAudioWin.addEventListener("createNewAudio", gotoCreateAudioPanel);
			popups.skinPromoWin.addEventListener("select", skinTypeSelected);
			popups.aboutWin.alertLookup = alertLookup;
			popups.alertWin.alertLookup = alertLookup;
			popups.confirmWin.alertLookup = alertLookup;
			popups.upgradeWin.alertLookup = alertLookup;
			popups.infoWin.alertLookup = alertLookup;
			
			/*
			modelPanel = new sp_panel_model() as ModelPanel;
			modelPanel.data = modelList;
			modelPanel.setPlayer(playerController);
			modelPanel.addEventListener(ModelEvent.SELECT, modelSelected);
			modelPanel.addEventListener("modelDataReady", onModelsDataReady);
			
			navController.addPanel(1, 1, "2D Illustrated", modelPanel);
			
			photoFacePanel = new sp_panel_photoFace() as PhotoFacePanel;			
			photoFacePanel.setPlayer(playerController);
			photoFacePanel.addEventListener(ModelEvent.SELECT, modelSelected);
			photoFacePanel.addEventListener("hidePlayer", hidePlayer);
			photoFacePanel.addEventListener("showPlayer", hidePlayer);
			photoFacePanel.addEventListener(AlertEvent.ALERT, catchError);
			navController.addPanel(1, 2, "3D Photoface", photoFacePanel);
			
			
			savedCharPanel = new sp_panel_savedChar() as SavedCharPanel;
			savedCharPanel.setPlayer(playerController);
			savedCharPanel.addEventListener(ModelEvent.SELECT, modelSelected);
			navController.addPanel(1, 3, "Saved Models", savedCharPanel);
			*/
			/*
			accPanel = new sp_panel_acc() as AccessoryPanel;
			accPanel.setPlayer(playerController);
			accPanel.addEventListener(AlertEvent.ALERT, catchError);
			navController.addPanel(2, 1, "Style", accPanel);
			

			colorPanel = new sp_panel_color() as ColorPanel;
			colorPanel.player = playerController;
			navController.addPanel(2, 2, "Color", colorPanel);
			
			sizingPanel = new sp_panel_sizing() as SizingPanel;
			sizingPanel.player = playerController;
			navController.addPanel(2, 3, "Attributes", sizingPanel);
			*/
			expressionsPanel = new sp_panel_expressions() as ExpressionsPanel;
			expressionsPanel.player = playerController;
			expressionsPanel.addEventListener(Event.SELECT, expressionSelected);
			navController.addPanel(2, 1, "Expressions", expressionsPanel);
			
			/*
			bgPanel = new sp_panel_bg();
			bgPanel.setPlayer(playerController);
			bgPanel.addEventListener("upload", onGotoBGUpload);
			navController.addPanel(3, 1, "Background Gallery", bgPanel);
			
			savedBgPanel = new sp_panel_savedBG();
			savedBgPanel.setPlayer(playerController);
			savedBgPanel.popups = popups;
			navController.addPanel(3, 2, "My Background", savedBgPanel);
			
			savedAudioPanel = new sp_panel_savedAudio();
			savedAudioPanel.data = audioList;
			savedAudioPanel.popupController = popups;
			savedAudioPanel.setPlayer(playerController);
			savedAudioPanel.addEventListener(Event.INIT, privateAudiosReady)
			savedAudioPanel.addEventListener(AlertEvent.ALERT, catchError);
			navController.addPanel(4, 1, "Saved", savedAudioPanel);
			
			ttsPanel = new sp_panel_tts();
			ttsPanel.voiceList = ttsVoiceList;
			ttsPanel.setPlayer(playerController);
			ttsPanel.addEventListener(AudioEvent.SELECT, onAudioSelected);
			ttsPanel.addEventListener(AudioEvent.STOP, onStopAudio);
			
			navController.addPanel(4, 2, "TTS", ttsPanel);
			
			micPanel = new sp_panel_mic();
			micPanel.addEventListener(AudioEvent.SELECT, onAudioSelected);
			micPanel.addEventListener(AudioEvent.STOP, onStopAudio);
			navController.addPanel(4, 3, "Mic", micPanel);
			
			uploadAudioPanel = new sp_panel_uploadAudio();
			uploadAudioPanel.addEventListener(AudioEvent.SELECT, onAudioSelected);
			uploadAudioPanel.addEventListener(AudioEvent.STOP, onStopAudio);
			uploadAudioPanel.addEventListener(AlertEvent.ALERT, catchError);
			navController.addPanel(4, 4, "Upload", uploadAudioPanel);
			
			phonePanel = new sp_panel_phone();
			phonePanel.addEventListener(AudioEvent.SELECT, onAudioSelected);
			phonePanel.addEventListener(AudioEvent.STOP, onStopAudio);
			navController.addPanel(4, 5, "Phone", phonePanel);
			
			var voiceTalentPanel:VoiceTalentPanel = new sp_panel_voiceTalent();
			navController.addPanel(4, 6, "Voice Talent", voiceTalentPanel);
			*/
			skinPanel = new sp_panel_skin();
			skinPanel.setPlayer(playerController);
			skinPanel.addEventListener(SkinSelectEvent.SELECT, skinSelected);
			skinPanel.addEventListener("openSkinPromoWin", openSkinPromoWin);
			navController.addPanel(5, 1, "Select Player", skinPanel);
			
			
			skinSettingsPanel = new sp_panel_skinSettings();
			skinSettingsPanel.player = playerController;
			skinSettingsPanel.addEventListener("update", updateSkinSettings);
			navController.addPanel(5, 2, "Display Settings", skinSettingsPanel);
			
			standardSkinPanel = new sp_panel_skinStandard();
			standardSkinPanel.addEventListener("select", skinTypeSelected);
			navController.addPanel(5, 3, "Functions (Standard)",standardSkinPanel);
						
			leadSkinPanel = new sp_panel_skinLead();
			leadSkinPanel.player = playerController;
			leadSkinPanel.popups = popups;
			leadSkinPanel.addEventListener("update", updateSkinSettings);
			
			aiSkinPanel = new sp_panel_skinAI();
			aiSkinPanel.player = playerController;
			aiSkinPanel.voiceList = ttsVoiceList;
			aiSkinPanel.addEventListener("update", updateSkinSettings);
			
			faqSkinPanel = new sp_panel_skinFaq();
			faqSkinPanel.player = playerController;
			faqSkinPanel.popups = popups;
			faqSkinPanel.addEventListener("update", updateSkinSettings);
			
			//updateColorTabVisibility();
			updateSkinTabType(show.scene.skin);			
			panel_copy_settings.addEventListener(AlertEvent.ALERT, catchError);
		}
		
		private function skinLoaded(evt:Event):void
		{
			
			if (skinPanel != null)
			{
				skinPanel.setIsLoadingData(false);
			}			
			
			if (playerController.scene!=null && playerController.scene.skin != null && playerController.scene.skinConfig != null)
			{
				if (faqSkinPanel != null)
				{
					faqSkinPanel.openPanel();
				}		
				if (skinSettingsPanel != null)
				{
					skinSettingsPanel.openPanel();
				}
				if (aiSkinPanel != null)
				{
					aiSkinPanel.openPanel();
				}
				if (leadSkinPanel != null)
				{
					leadSkinPanel.openPanel();
				}								
			}
		}
		
		private function expressionSelected(evt:Event):void
		{
			playerController.scene.expression = expressionsPanel.getExpression();
		}
		
		private function onModelsDataReady(evt:Event):void
		{
			//photoFacePanel.setData(modelPanel.data);			
		}
		
		private function catchError(evt:AlertEvent) {
			if (evt.alertType == AlertEvent.CONFIRM) {
				popups.openPopup(popups.confirmWin);
				popups.confirmWin.alert(evt);
			}
			else if (evt.alertType == "about") {
				popups.openPopup(popups.aboutWin);
				popups.aboutWin.alert(evt);
			}
			else if (evt.alertType == "upgrade") {
				popups.openPopup(popups.upgradeWin);
				popups.upgradeWin.alert(evt);
			}
			else if (evt.alertType == "info") {
				popups.openPopup(popups.infoWin);
				popups.infoWin.alert(evt);
			}
			else if (evt.alertType == "fatal")
			{
				popups.openPopup(popups.alertWin);
				popups.alertWin.alert(evt, true);				
			}
			else {
				popups.openPopup(popups.alertWin);
				popups.alertWin.alert(evt);
			}
		}

		private function hidePlayer(evt:Event):void
		{
			trace("SitepalV5::hidePlayer "+evt.type);
			playerMC.visible = evt.type == "hidePlayer"?false:true;
			navBar.disable(evt.type == "hidePlayer");
			navBar.visible = evt.type != "hidePlayer"
			/*
			if (upgradePhotofaceWin != null)
			{
				
				if (!SessionVars.photofaceSaveAllowed && !show.scene.model.isOwned && show.scene.model.is3d)
				{
					upgradePhotofaceWin.visible = evt.type == "hidePlayer"?false:true;					
				}
				else if (show.scene.model != null && !show.scene.model.isOwned && !show.scene.model.is3d)
				{
					upgradeModelWin.visible = evt.type == "hidePlayer"?false:true;		
				}
			}
			*/
		}
		
		/*
		private function privateAudiosReady(evt:Event):void
		{
			ttsPanel._arrExistingAudioNames = savedAudioPanel._arrExistingAudioNames;
			micPanel._arrExistingAudioNames = savedAudioPanel._arrExistingAudioNames;
			uploadAudioPanel._arrExistingAudioNames = savedAudioPanel._arrExistingAudioNames;
			phonePanel._arrExistingAudioNames = savedAudioPanel._arrExistingAudioNames;
		}
		
		private function onAudioSelected(evt:AudioEvent) {
			playerController.loadAudio(evt.audio);
			if (evt.target == savedAudioPanel) {
				playerController.playAudio(evt.audio);
			}
			else {
				evt.audio.isPrivate = true;
				audioList.addAccountAudio(evt.audio);
				navController.selectPanel(savedAudioPanel);
				if (evt.audio.type == AudioData.TTS) SPEventTracker.event("astts")
				if (evt.audio.type == AudioData.MIC) SPEventTracker.event("asmic")
				if (evt.audio.type == AudioData.PHONE) SPEventTracker.event("asup")
				if (evt.audio.type == AudioData.UPLOADED) SPEventTracker.event("asph")
				else SPEventTracker.event("as")
				savedAudioPanel.resetMultiple(evt.audio);
				savedAudioPanel.catSelector.selectById(SPAudioList.PRIVATE_CATEGORY);
				savedAudioPanel.getAudios();
				
				//if it's uploaded audio, preview it
				if (evt.target == uploadAudioPanel) playerController.playAudio(evt.audio);
			}
		}
		*/
		
		private function onStopAudio(evt:AudioEvent) {
			trace("Sitepal::onStopAudio");
			playerController.stopAudio();
		}
		/*
		private function privateAudioCountUpdated(evt:Event) {
			//do a check to make sure the number of private audios the user has doesn't exceed the max
			//if it does, disabled the "create audio" tabs and display an alert
			var maxExceeded:Boolean = (audioList.getAccountAudioArr().length >= SessionVars.audioLimit);
			navController.setTabDisabled(ttsPanel, maxExceeded);
			navController.setTabDisabled(micPanel, maxExceeded);
			navController.setTabDisabled(phonePanel, maxExceeded);
			navController.setTabDisabled(uploadAudioPanel, maxExceeded);
			if (maxExceeded) dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp403","You have reached the maximum number of audios for your account.  To create a new audio, you must first delete one of your existing audios."));
		}
		*/
		private function updateAccessoryPanelVisibility() {
			//disable colour tab if there are no color sections for this model			
			
			if (show!=null && show.sceneArr != null && show.sceneArr[playerController.curSceneIndex - 1] != null)
			{
				if (skinPanel!=null && navController.getActivePanel() == skinPanel)
				{
					skinPanel.updateSelectionPerScene();
				}
				trace("show.scenes[].model.type = " + show.sceneArr[playerController.curSceneIndex-1].model.type+" navController="+navController);
				var type:String = show.sceneArr[playerController.curSceneIndex - 1].model.type;
				if (navController == null) return;
				
				if (type == "host_2d" || type.toUpperCase()=="2D")
				{
					/*
					var numColors:uint = playerController.getColors().length;
					navController.setTabDisabled(colorPanel, (numColors == 0));
					navController.setTabDisabled(sizingPanel, false);
					navController.setTabDisabled(accPanel, false);
					navController.setTabDisabled(expressionsPanel, true);
					if (navController.getActivePanel() == expressionsPanel)
					{
						navController.selectPanel(accPanel);
					}
					*/
					/*
					if (navBar.selectedTab!=4)
					{
						navController.selectPanel(skinPanel);
						navBar.selectedTab = 4;						
					}
					else if (navBar.selectedTab == 4 && navController.getActivePanel() == skinSettingsPanel)
					{
						skinSettingsPanel.openPanel();
					}
					*/
					if (navController.getActivePanel() == expressionsPanel)
					{
						expressionsPanel.showModelTypeMessage();
					}
					//navBar.step2Btn.disabled = true;						
				}
				else
				{
					/*
					navController.setTabDisabled(accPanel, false);
					navController.setTabDisabled(sizingPanel, true);
					navController.setTabDisabled(colorPanel, true);
					navController.setTabDisabled(accPanel, true);
					navController.setTabDisabled(expressionsPanel, false);
					*/
					trace("updateAccessoryPanelVisibility winId=" + navController.getActiveWinId());
					if (navController.getActiveWinId() == 2)//accessories
					{
						navController.selectPanel(expressionsPanel);
					}
					if (navController.getActivePanel() == expressionsPanel)
					{
						expressionsPanel.openPanel();
					}
					expressionsPanel.showModelTypeMessage(false);
					
					//navBar.step2Btn.disabled = false;
				}
				/*
				if (playerController.curSceneIndex > 1 && SPSkinStruct(playerController.scene.skin).type.toLowerCase()==SPSkinStruct.STANDARD_TYPE)
				{
					navController.setTabDisabled(standardSkinPanel, true);
				}
				else if (SPSkinStruct(playerController.scene.skin).type.toLowerCase()==SPSkinStruct.STANDARD_TYPE)
				{
					navController.setTabDisabled(standardSkinPanel, false);
				}
				*/
			}			
		}
		
		private function updateSkinTabType(skin:SPSkinStruct) {
			if (navController == null) return;
			if (skin == null) {
				navController.setTabVisibleById(5, 2, false);
				navController.setTabVisibleById(5, 3, false);
			}
			else {
				navController.setTabVisibleById(5, 2, true);
				if (!SessionVars.loggedIn && SessionVars.mode == SessionVars.PARTNER_MODE) { 
					// only standard skins are available - you can't choose others
					navController.setTabVisibleById(5, 3, false);
				}
				else navController.setTabVisibleById(5, 3, true);
				
				trace("updateskinTabType : " + skin.type);
				if (skin.type == SPSkinStruct.LEAD_TYPE) {
					navController.addPanel(5, 3, "Functions (Lead)", leadSkinPanel);					
				}
				else if (skin.type == SPSkinStruct.AI_TYPE) {
					navController.addPanel(5, 3, "Functions (AI)", aiSkinPanel);					
				}
				else if (skin.type == SPSkinStruct.FAQ_TYPE) {
					navController.addPanel(5, 3, "Functions (FAQ)", faqSkinPanel);					
				}
				else 
				{
					navController.addPanel(5, 3, "Functions (Standard)", standardSkinPanel);
					if (playerController.curSceneIndex > 1)
					{
						navController.setTabVisibleById(5, 3, false);
					}
				}
			}
		}
		
		/*
		private function onGotoBGUpload(evt:Event) {
			navController.selectPanel(savedBgPanel);
			savedBgPanel.uploadBg();
		}
		*/
		
		private function onNavBarWinSelected(evt:SelectorEvent) {
			//if (navController.getActiveWinId() == 5			
			//playerController.stopAudio();
			/*
			if (navBar.selectedTab+1 == 5&&!SessionVars.noSkinPromo&&popups.skinPromoWin.firstOpen&&!show.isEdited) {
				popups.openPopup(popups.skinPromoWin);
				popups.skinPromoWin.init();
			}
			else popups.closePopup(popups.skinPromoWin);						
			*/
		}
		
		private function navPanelOpened(evt:Event) {
			//updateAccessoryPanelVisibility();
			/*
			if (navController.getActivePanel() == accPanel)
			{
				navController.selectPanel(expressionsPanel);				
			}
			*/
			updateUpgradeAlerts();
		}
		
		private function navPanelOpenedManually(evt:Event):void
		{
			
			/*
			if (navController.getActivePanel() == accPanel)
			{
				navController.selectPanel(expressionsPanel);				
			}
			*/
			
		}
		
		private function updateUpgradeAlerts() {
			if (navController.getActivePanel() == null||show==null||show.scene==null) {
				upgradeSkinWin.visible = false;
				//upgradeTTSWin.visible = false;
				//upgradePhotofaceWin.visible = false;
				//upgradeModelWin.closeWin();
				return;
			}
			if (navController.getActiveWinId() == 5 && SessionVars.loggedIn && show.scene.skin != null && !show.scene.skin.isOwned) {
				upgradeSkinWin.visible = true;
				if (show.scene.skin.type == SPSkinStruct.AI_TYPE) upgradeSkinWin.gotoAndStop(2);
				else upgradeSkinWin.gotoAndStop(1);
			}
			else upgradeSkinWin.visible = false;			
		}
		
		
		private function modelPurchased(evt:AssetIdEvent) {
			
		}
		
		private function skinSelected(evt:SkinSelectEvent) {
			updateSkinTabType(evt.skin as SPSkinStruct);
			updateUpgradeAlerts();			
		}
		
		private function skinTypeChanged(evt:Event):void
		{
			//panel_copy_settings.setPlayer(playerController);
			//panel_copy_settings.copySettings(0,false);
		}
		
		private function skinTypeSelected(evt:TextEvent) {
			trace("skinTypeSelected : " + evt.text);
			skinPanel.selectPopularSkinType(evt.text);
			if (navController.getActivePanel() == skinPanel) skinPanel.openPanel(); //re-initialize panel
			else navController.selectPanel(skinPanel);
		}
		private function openSkinPromoWin(evt:Event) {
			popups.openPopup(popups.skinPromoWin);
			popups.skinPromoWin.init();
		}
		private function updateSkinSettings(evt:Event) {
			playerController.updateSkinSettings();
		}
		private function gotoCreateAudioPanel(evt:Event) {
			
			/*
			navController.selectPanel(savedAudioPanel);
			navBar.selectedTab = 3;
			*/			
		}
		private function onPreviewScene(evt:SelectorEvent) {
			/*
			if (show.scene.audioArr.length > 0)
			{
				var rnd:int = int(Math.random() * show.scene.audioArr.length);
				playerController.playAudio(show.scene.audioArr[rnd]);
			}
			else
			{
				playerController.playAudio(show.scene.audio);
			}
			*/
			if (_bIsFrozen)
			{
				playerController.resume();
			}
			else
			{
				trace("Sitepal::onPreviewScene calling replay()");
				playerController.replay();
			}
		}
		private function onStopScene(evt:SelectorEvent) {
			trace("Sitepal::onStopScene");
			playerController.stopAudio();
			_bIsFrozen = false;
		}
		/*
		private function modelSelected(evt:ModelEvent) {
			//modelBlocker._visible=true;
			
			//reload the model and reset the model accessories/colors if it is selected from the "scene characters" panel
			var forceReload:Boolean;
			if (evt.target == savedCharPanel) forceReload = true;
			else forceReload = false;
			
			
			
			var model:SPHostStruct = evt.model as SPHostStruct;
			//hostModule.loadOH(model.hostUrl+"&pd="+SessionVars.swfDomain,forceReload);
			trace("model is owned : " + model == null?null:model.isOwned);
			playerController.addEventListener(VHSSEvent.MODEL_LOAD_ERROR, onModelLoadError);
			playerController.loadModel(model, forceReload);	
			
			updateUpgradeAlerts();
			//add to private list			
		}
		*/
	
		//player controller callbacks
		
		
		private function onModelLoadError(evt:VHSSEvent):void
		{
			trace("Sitepal::onModelLoadError");
			//modelPanel.returnToPreviousModel();
			popups.closePopup(popups.modelBlocker);
			dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp213", "Character could not be loaded"));
			playerController.removeEventListener(VHSSEvent.MODEL_LOAD_ERROR, onModelLoadError);
		}
		
		private function onPlayerDataError(evt:VHSSEvent):void
		{
			addEventListener(AlertEvent.ERROR, catchError);
			dispatchEvent(new AlertEvent(AlertEvent.FATAL, "sp702", "Error loading scene's data. Please close the editor and make sure you are properly logged in."));
		}
		
		private function onAudioError(evt:VHSSEvent):void
		{
			
			dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp466", "There is a problem with playing this audio. Please try a different one."));
		}
		
		
		private function sceneLoaded(evt:Event):void
		{
			if (!_bFirstModelLoaded)
			{
				_mcComboGoToScene.clear();
				for (var i:int = 1; i <= show.sceneArr.length; ++i)
				{
					_mcComboGoToScene.add(i, "Scene #" + i);
				}
				_mcComboGoToScene.selectById(SessionVars.slideIndex);
				_mcComboGoToScene.update();
				playerController.removeEventListener(VHSSEvent.MODEL_LOAD_ERROR, onModelLoadError);
				//modelBlocker._visible=false;			
				//trace("SitepalV5::hostLoaded type=" + show .sceneArrplayerController.scene.model.type); //good place to disable stuff (not on intro)
				show = playerController.getShow();
				_bFirstModelLoaded = true;				
			}
			else
			{
				moveZoomControls.getZoomer().matrix = playerController.scene.char.hostPos;				
				_mcComboGoToScene.selectById(playerController.curSceneIndex);
			}
			
			if (playerController.scene.expression != null && expressionsPanel!=null)
			{
				expressionsPanel.setExpression(playerController.scene.expression, true);
			}
			if (moveZoomControls!=null)
			{
				moveZoomControls.updateFromZoomer(null);
			}
			updateAccessoryPanelVisibility();
			updateSkinTabType(playerController.scene.skin);
		}
		
		private function hostLoaded(evt:Event) {
			//if (firstTime) introStart();
			
			//updateAccessoryPanelVisibility();
			
			//hostModule.getController().setInitialAccessories(OHUrlParser.getOHObject(hosturl));
		}
		
		private function onProcessingStarted(evt:ASyncProcessEvent) {
			if (evt.process.processType==ASyncProcess.PROCESS_MODEL) {
				popups.openPopup(popups.modelBlocker);
			}
			else if (evt.process.processType==ASyncProcess.PROCESS_AUDIO) {
				popups.openPopup(popups.audioBlocker);
			}
			else if (evt.process.processType==ASyncProcess.PROCESS_SCENE) {
				popups.openPopup(popups.sceneBlocker);
			}
			
		}
		
		private function onProcessingEnded(evt:ASyncProcessEvent) {
			if (evt.process.processType==ASyncProcess.PROCESS_MODEL) {
				popups.closePopup(popups.modelBlocker);
			}
			else if (evt.process.processType==ASyncProcess.PROCESS_AUDIO) {
				popups.closePopup(popups.audioBlocker);
			}
			else if (evt.process.processType==ASyncProcess.PROCESS_SCENE) {
				popups.closePopup(popups.sceneBlocker);
			}
		}
		
		private function onPlayerFreeze(evt:Event):void
		{
			previewBtn.selected = false;	
			_bIsFrozen = true;
		}
		
		private function onPlayerResume(evt:Event):void
		{
			previewBtn.selected = true;
			_bIsFrozen = false;
		}
		
		private function onTalkStarted(evt:VHSSEvent) {
			trace("talkStarted in main")
			previewBtn.selected = true;
		}
		
		private function onTalkEnded(evt:VHSSEvent) {
			trace("talkEnded in main")
			if (playerController.manualStopAudio)
			{
				previewBtn.selected = false;
				playerController.manualStopAudio = false;
			}
			_bIsFrozen = false;
			//previewBtn.selected = false;
		}
		
		private function onSceneAudioEnded(evt:VHSSEvent) {
			trace("scenePlaybackComplete in main")
			previewBtn.selected = false;
		}
		
		
		/*
		public function ev_soundError() {
			audioBlocker._visible=false;
			showAlert("audioTimeout")
			panels.getCurrentPanel().talkEnded();
		}
		
		public function accessoryIncompatible(typeId:Number,state:Boolean,typeName:String) {
			panels.getCurrentPanel().accessoryIncompatible(typeId,state,typeName)
		}
		
		public function accessoryLoaded(typeId:Number,mcs:Array) {
			trace("accessory loaded")
			accBlocker._visible=false;
		}
		
		public function accessoryLoadError() {
			accBlocker._visible=false;
			showAlert("accessoryLoadError")
		}*/
	
		
		
		
		//save/cancel
		
		private function onSaveClick(evt:SendEvent) {
			var btnName:String = evt.sendMode;
			
			if (btnName=="saveBtn") saveWithMode("save");		
			else if (btnName == "cancelBtn") {
				publishMode="cancel";
				closeWin();
			}
		}
		
		private function saveWithMode($publishMode:String) {
			trace("main::saveWithMode - " + $publishMode);
			publishMode = $publishMode;
			playerController.compileScene();
			var saveSkinXML:XML = new XML("<SKINLIST />");
			saveSkinXML.@DEFAULT = "0";
			saveSkinXML.@ACC = SessionVars.acc;
			saveSkinXML.@SHOWID = SessionVars.showId;
			if (SceneStruct(playerController.getShow().sceneArr[0]).skin != null)
			{
				var skinId:int = SceneStruct(playerController.getShow().sceneArr[0]).skin.id;
				var typeName:String = SceneStruct(playerController.getShow().sceneArr[0]).skin.type.toUpperCase();
			}
			else
			{
				var noSkin:Boolean = true;
			}
			for (var i:int = 0; i < playerController.getShow().sceneArr.length; ++i)
			{
				var s:SceneStruct = playerController.getShow().sceneArr[i];
				var skinNode:XML
				if (!noSkin)
				{
					var conf:SkinConfiguration = s.skinConfig;				
					var skinAlert:AlertEvent = conf.validateConfig();
					if (skinAlert != null) {
						dispatchEvent(skinAlert);
						return;
					}
					skinNode = new XML("<SKIN />");
					var title:String = encodeURI(conf.title);
					var align:String = conf.align;
					skinNode.@TYPE = typeName;
					skinNode.@ID = skinId;
					skinNode.@SLIDE = s.id;
					skinNode.@MUTE = conf.showMute?"1":"0";
					skinNode.@VOL=conf.showVolume?"1":"0";
					skinNode.@PLAY=conf.showPlay?"1":"0";
					skinNode.@PREV= conf.showPrev?"1":"0";
					skinNode.@NEXT = conf.showNext?"1":"0";
					for (var j:int=0;j<conf.colorArr.length;j++) {
						skinNode["@C"+(j+1).toString()]="0x"+conf.colorArr[j].toString(16);
					}
					if (conf.lead != null) skinNode.appendChild(conf.lead.getXML(true));
					if (conf.faq != null) skinNode.appendChild(conf.faq.getXML(true).children());
					if (conf.ai != null)
					{
						var aiXML:XML = conf.ai.getXML();
						skinNode.appendChild(aiXML.children());
						skinNode.@ENGINE = aiXML.@ENGINE;
						skinNode.@LANG = aiXML.@LANG;
						skinNode.@VOICE = aiXML.@VOICE;
						skinNode.@BOT = aiXML.@BOT;
						skinNode.@RESPONSE = aiXML.@RESPONSE;						
					}
				}
				else
				{
					skinNode = new XML("<SKIN />");
					skinNode.@TYPE = "NONE";
					skinNode.@ID = "-1";
					skinNode.@SLIDE = s.id;
				}
				
				var titleNode:XML = new XML("<TITLE />");
				titleNode.@ALIGN = noSkin? "center" : conf.align;
				titleNode.@VISIBLE = noSkin? "0" : (conf.showTitle?"1":"0");
				titleNode.appendChild(noSkin? (s.title!=null? s.title:""): title);
				
				var hostPos:Object = MoveZoomUtil.matrixToObject(s.char.hostPos);
				var modelNode:XML = new XML("<HOST />");
				modelNode.@X=hostPos.x.toFixed(2);
				modelNode.@Y=hostPos.y.toFixed(2);
				modelNode.@SCALE = (hostPos.scaleX * 100).toFixed(2);
				
				if (s.expression != null && s.expression!="")
				{
					var expressionNode:XML = new XML("<EXPRESSION />");
					expressionNode.@AMP = "1";
					expressionNode.appendChild(s.expression);
				}
				
				
				skinNode.appendChild(titleNode);
				skinNode.appendChild(modelNode);
				if (s.expression != null && expressionNode!=null)
				{
					skinNode.appendChild(expressionNode);
				}
				saveSkinXML.appendChild(skinNode);
			}
			trace("saveSkinXML " + saveSkinXML.toXMLString());
			var url:String = SessionVars.adminURL + "saveskin.php?rand="+Math.floor(Math.random()*1000000);
			XMLLoader.sendXML(url,saveDone,saveSkinXML);
			/*
			 * node.@ALIGN=align;
			node.@TITLE=encodeURI(title);
			node.@VTITLE=showTitle?"1":"0";
			node.@VOL=showVolume?"1":"0";
			node.@PLAY=showPlay?"1":"0";
			node.@MUTE=showMute?"1":"0";
			node.@PREV="0";
			node.@NEXT = "0";
			for (var i:int=0;i<colorArr.length;i++) {
				node["@C"+(i+1).toString()]="0x"+colorArr[i].toString(16);
			}
			//node.attributes.EMAIL=email;
			trace("type in getXMLNode: " + type)
			if (lead != null) node.appendChild(lead.getXML());
			if (faq != null) node.appendChild(faq.getXML());
			if (ai != null) node.appendChild(ai.getXML());
			
			return node;
			*/
			
			/*
			//only show these alerts if user is logged in
			if (SessionVars.mode != SessionVars.DEMO_MODE) {
				if (show.scene.model != null && !show.scene.model.isOwned && !show.scene.model.is3d) {
					dispatchEvent(new AlertEvent(AlertEvent.ERROR,"sp105","You must purchase this model before saving."));
					return;
				}
				if (show.scene.skin != null && !show.scene.skin.isOwned) {
					dispatchEvent(new AlertEvent("upgrade", "sp106", "You don't own this player.  You must upgrade your account or choose another player before saving."));
					return;
				}
				
				if (show.scene.model.is3d && !SessionVars.photofaceSaveAllowed && !show.scene.model.isOwned)
				{
					dispatchEvent(new AlertEvent("upgrade", "sp110", "You can't save the scene with this model. You must upgrade your account or choose another model before saving."));
					return;
				}
			}
			
			if (show.scene.skin!= null) {
				//returns null if skin passes validation, or an AlertEvent if there is a problem
				var skinAlert:AlertEvent = show.scene.skinConfig.validateConfig();
				if (skinAlert != null) {
					dispatchEvent(skinAlert);
					return;
				}
			}

			if (publishMode == "email") {
				popups.emailWin.addEventListener(SendEvent.SEND, onEmail);
				popups.openPopup(popups.emailWin);
				popups.emailWin.init();
			}
			else if (publishMode == "publish" || publishMode == "embedcode") {
				popups.publishWin.addEventListener(SendEvent.SEND, onPublishScene);
				popups.openPopup(popups.publishWin);
				popups.publishWin.init(show.scene);
			}
			else saveRegistered();
			*/
		}
		/*
		private function onEmail(evt:SendEvent) {
			publishEvent = evt;
			save();
		}
		
		private function onPublishScene(evt:SendEvent) {
			evt.messageXML.@PARTNERID=SessionVars.partnerId;
			for (var paramName:String in loaderInfo.parameters) {
				if (paramName.indexOf("partner_")==0) evt.messageXML["@"+paramName.toUpperCase()]=loaderInfo.parameters[paramName];
			}
			evt.messageXML.@JUSTREGISTERED=SessionVars.justRegistered?"1":"0";
			publishEvent = evt;
			saveRegistered();
		}
		
		private function onEmbedClose(evt:Event) {
			closeWin();
		}
		
		private function saveRegistered() {
			if (SessionVars.mode==SessionVars.PARTNER_MODE&&!SessionVars.loggedIn) {
				ExternalInterface.call("RegisterSitePal", publishMode);
				ExternalInterface.addCallback("registerDone", registerDone);
			}
			else save();	
		}
			
		public function registerDone(in_userId:String,in_acc:String,in_show:String=null) {
			SessionVars.userId = parseInt(in_userId);
			SessionVars.acc = parseInt(in_acc);
			SessionVars.showId = in_show == null?0:parseInt(in_show);
			SessionVars.justRegistered = true;
			save();
		}
		
		private function charSavedToDB(urlVars:URLVariables):void
		{
			if (int(urlVars.OK) == 1)
			{
				SPHostStruct(playerController.scene.model).isDirty = false;				
				//show.scene.model.charId = urlVars.charId;
				show.scene.char.id = urlVars.charId
				//SPHostStruct(playerController.scene.model).charId = urlVars.charId;
				saveScene();
			}
			else
			{
				if (urlVars.ERROR == undefined)
				{
					dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp109", "Error saving character : "+urlVars.Res.split(":")[1],{details:urlVars.Res.split(":")[1]}));	
				}
				else
				{
					dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp109", "Error saving character : "+urlVars.ERROR,{details:urlVars.ERROR}));	
				}
				
			}
		}
		
		private function saveScene():void
		{
			if (SceneStruct(show.scene).skin!=null)
			{
				var alrt:AlertEvent = SkinConfiguration(SceneStruct(show.scene).skinConfig).validateConfig();
				if (alrt != null)
				{
					dispatchEvent(alrt);
					return;
				}
			}
			var sendXML = show.getSaveXML();
			if (expressionsPanel.getExpression() != "")
			{
				sendXML.scenes.scene.avatar.expression = expressionsPanel.getExpression();
				sendXML.scenes.scene.avatar.expression.@amp = expressionsPanel.EXPRESSION_AMP;
			}
			trace("sendXML::"+sendXML.toString());
			var paramsXML = <params />;
			paramsXML.email = (publishMode=="email")?"1":"0";
			paramsXML.mode = publishMode;
			paramsXML.version = "5";
			paramsXML.mouse = show.mouseFollow?"1":"0";
			paramsXML.userid = SessionVars.userId.toString();
			paramsXML.showid = SessionVars.mode == SessionVars.DEMO_MODE? 0 : SessionVars.showId.toString();
			//paramsXML.showname="";
			paramsXML.account = SessionVars.acc.toString();
			sendXML.appendChild(paramsXML);
			
			if (publishMode=="email") popups.saveBlocker.tf_msg.text="Sending ......";
			else popups.saveBlocker.tf_msg.text="Saving ......";
			popups.openPopup(popups.saveBlocker);
			
			if (publishEvent != null && publishEvent.messageXML != null) sendXML.appendChild(publishEvent.messageXML);
			
			trace("sending XML : " + sendXML);
			var url:String = SessionVars.adminURL + "savesceneV5.php?rand="+Math.floor(Math.random()*1000000);
			XMLLoader.sendXML(url,saveDone,sendXML);
		}
		
		private function save() {			
			playerController.compileScene();
			var postVars:URLVariables = new URLVariables();
			if (SPHostStruct(playerController.scene.model).is3d || SPHostStruct(playerController.scene.model).type.toLowerCase()=="3d" || SPHostStruct(playerController.scene.model).type.toLowerCase()=="host_3d")
			{
				
				postVars.charId = SessionVars.mode != SessionVars.DEMO_MODE ? SessionVars.origCharId : 0;
				postVars.charURL = SPHostStruct(playerController.scene.model).url;// origVars.oa1File
				//postVars.thumbURL = SPHostStruct(playerController.scene.model).thumbUrl;// origVars.thumbUrl;
				postVars.charName = SPHostStruct(playerController.scene.model).name; // origVars.modelName;
				postVars.modelId = SPHostStruct(playerController.scene.model).id;
				postVars.showId = SessionVars.showId;
				postVars.accId = SessionVars.acc;
				postVars.charType = 1;				
			}
			else
			{				
				postVars.charId = SessionVars.mode != SessionVars.DEMO_MODE ? SessionVars.origCharId : 0;
				postVars.charURL = playerController.scene.char.url;
				//postVars.thumbURL = SPHostStruct(playerController.scene.model).thumbUrl;// origVars.thumbUrl;
				postVars.charName = SPHostStruct(playerController.scene.model).name; // origVars.modelName;
				postVars.modelId = SPHostStruct(playerController.scene.model).id;
				postVars.showId = SessionVars.showId;
				postVars.accId = SessionVars.acc;
				postVars.charType = 0;
				
				//saveScene();
			}	
			postVars.charName = postVars.charName.length > 0? postVars.charName : "untitled";
			XMLLoader.sendAndLoad(SessionVars.localBaseURL + "savecharacterV5.php?rnd=" + (Math.random() * 100000),charSavedToDB, postVars, URLVariables);		
		}
		*/
		public function saveDone(_xml:XML) {
			trace("saveDone: " + _xml);	
			popups.closePopup(popups.saveBlocker);

			if (_xml == null || _xml.@RES.toString().toLowerCase() != "ok") {
				var reason:String = (_xml == null)?"Invalid xml":_xml.@MSG;
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp107", "Error saving scene : "+reason,{details:reason}));
				return;
			}
			
			SPEventTracker.event("edsv")
			
			if (!matchSkinDimensions(show.scene.skin, savedSkin)) {
				dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp102", "Your changes have been saved, but you may need to re-embed your scene.", null, sendDoneOK));
			}			
			else dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp101", "Save successful.", null, sendDoneOK));
			
		}
		
		private function sendDoneOK(b:Boolean) {
			closeWin();
		}
	
		private function matchSkinDimensions(skin1:SPSkinStruct, skin2:SPSkinStruct):Boolean {
			//returns false if 2 skins have different dimensions
			//returns true if 2 skins have same dimensions, or skins are null
			
			if (skin1 == null || skin2 == null) return(true);
			if (skin1.width==0||skin1.height==0||skin2.width==0||skin2.height==0) return(true);
			
			//test if skin aspect ratios are within 1% of each other
			var aspect1:Number = Math.round(skin1.width * 100 / skin1.height);
			var aspect2:Number = Math.round(skin2.width * 100 / skin2.height);
			return(aspect1==aspect2)
		}
	
		public function closeWin() { //close down sitepal window
			if (publishMode == null) publishMode = "cancel";
			trace("closeWin in main : publishMode=" + publishMode)
			
			//getURL("javascript: saveDone('"+publishMode+"',"+SessionVars.showId+");");
			ExternalInterface.call("saveDone", publishMode, SessionVars.showId);
			publishMode = null;
			publishEvent = null;
		}
	}
	
}