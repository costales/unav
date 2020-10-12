/*
 * uNav https://github.com/costales/unav
 * Copyright (C) 2015-2020 Marcos Alvarez Costales https://costales.github.io
 *
 * uNav is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * uNav is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

UI.prototype.ZOOM = 17;
UI.prototype.POSBTN_HEIGHT = 50;

function UI() {
	this.center_pos = false;
	this.pickingPoint = 0;
	this.pickingCoordLng1 = null;
	this.pickingCoordLat1 = null;
	this.pickingCoordLng2 = null;
	this.pickingCoordLat2 = null;
	this.radar_beep = false;
}

UI.prototype.get_center_pos = function() {
	return this.center_pos;
}

UI.prototype.set_center_pos = function(status) {
	this.center_pos = status;

	if (status) {
		$("#pulsePosBtn").css("background", "white");
		$("#geo").attr("src", "img/ui/geoEnabled.svg");
		$("#pulsePosBtn").css("animation", "pulse 3s infinite");
	}
	else {
		$("#pulsePosBtn").css("background", "#4d4d4d");
		$("#geo").attr("src", "img/ui/geoDisabled.svg");
		$("#pulsePosBtn").css("animation", "");

		mapUI.set_map_rotate(0);
		this.map_resize("100%");
	}
}		

UI.prototype.play_test = function() {
	load_custom_voices(true);
}

UI.prototype.POIPanel = function(data) {
	var msgShow = data.msgShow || 'default';
	var msgAutohide = data.msgAutohide || false;
	var msgText = data.msgText || '';
	var msgBGColor = data.msgBGColor || '#F7F7F7';
	switch(msgBGColor) {
		case 'success':
			msgBGColor = '#c9ffbb';
			break;
		case 'error':
			msgBGColor = '#ffa3c2';
			break;
		case 'warning':
			msgBGColor = '#fbffbb';
			break;
	}

	var iconsShow = data.iconsShow || 'auto';
	var iconsClickedOwnPos = data.iconsClickedOwnPos || false;
	var iconsIsFavorite = data.iconsIsFavorite || false;
	var iconIsPickingPos = data.iconIsPickingPos || false;
	var iconsPhone = data.iconsPhone || '';
	var iconsWebsite = data.iconsWebsite || '';
	var iconsEmail = data.iconsEmail || '';
	var iconsLng = data.iconsLng || null;
	var iconsLat = data.iconsLat || null;

	$.doTimeout('autohideMsg');

	if (msgText)
		$('#topPanelMsgContent').html('<p>' + msgText.substring(0,120) + '</p>');

	if (iconsShow == 'yes') {
		var html_content = '<center>';
		if (!iconIsPickingPos) {
			if (!iconsClickedOwnPos)
				html_content = html_content + '<img src="img/panel/send.svg" onclick="event.stopPropagation();BtnGo(' + iconsLng + ',' + iconsLat + ')">';
			if (!iconsIsFavorite)
				html_content = html_content + '<img src="img/panel/non-starred.svg" onclick="event.stopPropagation();BtnFavorite(' + iconsLng + ',' + iconsLat + ')">';
			html_content = html_content + '<img src="img/panel/share.svg" onclick="event.stopPropagation();BtnShare(' + iconsLng + ',' + iconsLat + ')">';
			if (iconsPhone)
				html_content = html_content + '<img src="img/panel/phone.svg" onclick="event.stopPropagation();BtnPhone(\'' + iconsPhone + '\')">';
			if (iconsWebsite)
				html_content = html_content + '<img src="img/panel/website.svg" onclick="event.stopPropagation();BtnWebsite(\'' + iconsWebsite + '\')">';
			if (iconsEmail)
				html_content = html_content + '<img src="img/panel/email.svg" onclick="event.stopPropagation();BtnEmail(\'' + iconsEmail + '\')">';
		}
		else {
			html_content = html_content + '<img src="img/panel/close.svg" onclick="event.stopPropagation();ui.set_pickingOnMap(0)"><img src="img/panel/tick.svg" onclick="event.stopPropagation();ui.set_pickingOnMap(' + (ui.get_pickingOnMap()+1) + ')">';
		}
		html_content = html_content + '</center>';
		$('#topPanelIconsContent').html(html_content);
	}
	
	if (msgShow == 'yes') {
		if ($("#topPanelMsg").is(":visible"))
			$("#topPanelMsg").hide();
		$("#topPanelMsg").slideDown();
	}
	if (iconsShow == 'yes') {
		if ($("#topPanelIcons").is(":visible"))
			$("#topPanelIcons").hide();
		$("#topPanelIcons").slideDown();
	}
	if (msgShow == 'no')
		$("#topPanelMsg").hide();
	if (iconsShow == 'no') {
		$("#topPanelIcons").hide();
		longtouch_id++; // Avoid message after clicks
	}

	if (msgAutohide)
		$.doTimeout('autohideMsg', 3500, function(){
			$('#topPanelMsg').slideUp();
			$("#topPanelIcons").css("box-shadow", "0px 2px 2px 0px rgba(184,184,184,1)");
		});

	$("#topPanelMsg").css("background", msgBGColor);

	if (msgShow == 'yes' && (iconsShow == 'yes' || iconsShow == 'auto')) {
		$("#topPanelIcons").css("box-shadow", "");
		$("#topPanelMsg").css("height", "100px");
		$("#topPanelMsg").css("max-height", "100px");
		$("#topPanelMsg").css("min-height", "100px");
	}
	if (msgShow == 'no' && (iconsShow == 'yes' || iconsShow == 'auto'))
		$("#topPanelIcons").css("box-shadow", "0px 2px 2px 0px rgba(184,184,184,1)");
	if (msgShow == 'yes' && iconsShow == 'no') {
		$("#topPanelMsg").css("height", "48px");
		$("#topPanelMsg").css("max-height", "48px");
		$("#topPanelMsg").css("min-height", "48px");
	}
}

UI.prototype.set_confirm_btns = function(mode) {
	switch(mode) {
		case 'car':
			$("#btnModeCarConfirm").css("background-color", "#335280");
			$("#btnModeBikeConfirm").css("background-color", "#CDCDCD");
			$("#btnModeWalkConfirm").css("background-color", "#CDCDCD");
			break;
		case 'bike':
			$("#btnModeCarConfirm").css("background-color", "#CDCDCD");
			$("#btnModeBikeConfirm").css("background-color", "#335280");
			$("#btnModeWalkConfirm").css("background-color", "#CDCDCD");
			break;
		case 'walk':
			$("#btnModeCarConfirm").css("background-color", "#CDCDCD");
			$("#btnModeBikeConfirm").css("background-color", "#CDCDCD");
			$("#btnModeWalkConfirm").css("background-color", "#335280");
			break;
		}
		$("#btnCancel").html(t("Cancel"));
		$("#btnStart").html(t("Start"));
		$("#btnCancelSimulate").html(t("Close"));
}

UI.prototype.pos_btn_height = function() {
	if ($("#panelsNav").is(":visible"))
		$("#posBtn").css('bottom', $("#panelsNav").height()+ui.POSBTN_HEIGHT+"px");
	if ($("#panelConfirmRoute").is(":visible"))
		$("#posBtn").css('bottom', $("#panelConfirmRoute").height()+ui.POSBTN_HEIGHT+"px");
	if ($("#panelsNav").is(":hidden") && $("#panelConfirmRoute").is(":hidden"))
		$("#posBtn").css('bottom', ui.POSBTN_HEIGHT+"px");
}
UI.prototype.show_panels = function(panel) {
	$("#panelConfirmRoute").hide();
	$("#panelSimulateRoute").hide();
	$("#panelsNav").hide();
	$(".ol-compassctrl.compass").hide();
	$("#btnCancel").hide();
	$("#btnStart").hide();
	$("#btnCancelSimulate").hide();
	$("#confirmEndTime").hide();
	$("#confirmEndDistance").hide();
	$("#confirmEndHour").hide();
	$("#bottomConfirmMessage").hide();
	this.set_confirm_btns(settings.get_route_mode());
	switch(panel) {
		case 'navigate':
			$("#panelsNav").show();
			$(".ol-compassctrl.compass").show();
			break;
		case 'confirm':
			$("#panelConfirmRoute").show();
			$("#btnCancel").show();
			$("#btnStart").show();
			$("#confirmEndTime").show();
			$("#confirmEndDistance").show();
			$("#confirmEndHour").show();
			break;
		case 'confirm_error':
			$("#panelConfirmRoute").show();
			$("#btnCancel").show();
			$("#bottomConfirmMessage").html(t("Try other route mode"));
			$("#bottomConfirmMessage").show();
			break;
		case 'simulate':
			$("#panelConfirmRoute").show();
			$("#btnCancelSimulate").show();
			$("#confirmEndTime").show();
			$("#confirmEndDistance").show();
			$("#confirmEndHour").show();
			break;
		case 'simulate_error':
			$("#panelConfirmRoute").show();
			$("#btnCancelSimulate").show();
			$("#bottomConfirmMessage").html(t("Try other route mode"));
			$("#bottomConfirmMessage").show();
			break;
	}
	this.pos_btn_height();
}

// Search page has a big height and the panels are hidden
UI.prototype.topPanelsMargin = function(header_height) {
	$(".topPanels").css("margin-top", header_height);
}

UI.prototype.get_picked_coords = function() {
	return {
		lng1: this.pickingCoordLng1,
		lat1: this.pickingCoordLat1,
		lng2: this.pickingCoordLng2,
		lat2: this.pickingCoordLat2
	}
}
UI.prototype.get_pickingOnMap = function() {
	return this.pickingPoint;
}
UI.prototype.set_pickingOnMap = function(value) {
	this.pickingPoint = value;
	switch(value) {
		case 0:
			this.POIPanel({msgShow: 'no', iconsShow: 'no'});
			break;
		case 1:
			longtouch_id++; // Avoid message after click
			nav.set_data({mode: 'simulating'});
			ui.set_center_pos(false);
			mapUI.clear_layer('poi');
			mapUI.clear_layer('route');
			mapUI.clear_layer('radar');		
			poiStart.hide();
			poiEnd.hide();
			this.show_panels('none');
			this.POIPanel({msgShow: 'yes', msgText: t("Long click on origin"), iconsShow: 'no'});
			break;
		case 2:
			this.pickingCoordLng1 = utils.fix_lng(ol.proj.transform(poiClick.getPosition(), 'EPSG:3857', 'EPSG:4326')[0]);
			this.pickingCoordLat1 = ol.proj.transform(poiClick.getPosition(), 'EPSG:3857', 'EPSG:4326')[1];
			this.POIPanel({msgShow: 'yes', msgText: t("Long click on destination"), iconsShow: 'no'});
			break;
		case 3:
			this.pickingCoordLng2 = utils.fix_lng(ol.proj.transform(poiClick.getPosition(), 'EPSG:3857', 'EPSG:4326')[0]);
			this.pickingCoordLat2 = ol.proj.transform(poiClick.getPosition(), 'EPSG:3857', 'EPSG:4326')[1];
			this.set_pickingOnMap(0);
			BtnSimulate(this.pickingCoordLng1, this.pickingCoordLat1, this.pickingCoordLng2, this.pickingCoordLat2);
			break;
	}
	poiClick.hide();
}

UI.prototype.update_lower_panel = function(duration, distance, speed, percentage) {
	var txt_time = maths.time2human(duration);
	var txt_distance = maths.dist2human(distance, settings.get_unit());
	var txt_ETA = maths.time2human(duration, true);
	if (settings.get_unit() == 'km')
		var txt_speed = Math.trunc(speed) + "km/h";
	else
		var txt_speed = Math.trunc(maths.km2mi(speed)) + "mi/h";
	$("#totalProgress").css("width", percentage+"%");
	$('#endTime').html(txt_time);
	$("#speed").html(txt_speed);
	$('#endDistance').html(txt_distance);
	$('#endHour').html(txt_ETA);
	$("#totalProgress").css("width", percentage+"%");
	$('#confirmEndTime').html(txt_time);
	$('#confirmEndDistance').html(txt_distance);
	$('#confirmEndHour').html(txt_ETA);
}

UI.prototype.update_nav_panel = function(type, name, distance) {
	$('#stepTxt').html(name);
	$('#stepImg').html('<img src="img/steps/' + type + '.svg">');
	$('#distance').html(maths.dist2human(distance, settings.get_unit()));
}

UI.prototype.get_radar_beep = function() {
	return this.radar_beep;
}
UI.prototype.set_radar_beep = function(value) {
	this.radar_beep = value;
}
UI.prototype.play_radar_beep = function() {
	this.radar_beep = false;
	$('#radar').trigger('play');
}

UI.prototype.speak = function(speak, type) {
	if (type == 8)
		return;
	if (speak != 1)
		return;
	$('#'+type).trigger('play');
}

UI.prototype.update_pos = function(nav_data) {
	if (nav_data.lng === null || nav_data.lat === null)
		return;

	if (!mapUI.layerPos.getVisible())
		mapUI.layerPos.setVisible(true);

	mapUI.posFeature.getGeometry().setCoordinates(ol.proj.fromLonLat([nav_data.lng, nav_data.lat]));
}

UI.prototype.map_resize = function(percentage) {
	if ($(".map")[0].style.height != percentage) {
		$(".map").css("height", percentage);
		map.updateSize();
	}
}

UI.prototype.update_map_view = function(nav_data) {
	if (nav_data.lng === null || nav_data.lat === null)
		return;
	
	// Center map?
	if (this.get_center_pos())
		mapUI.set_map_center(nav_data.lng, nav_data.lat);
	
	// Compass
	if (nav_data.mode == 'route_driving' && settings.get_rotate_map())
		$(".ol-compassctrl.compass").show();
	else
		$(".ol-compassctrl.compass").hide();

	// Rotate / Zoom
	switch(nav_data.mode) {
		case 'exploring':
		case 'GPS_waiting':
		case 'calculating_simulating_error':
		case 'calculating_simulating_call_API':
		case 'simulating':
		case 'drawing_simulating':
		case 'GPS_waiting_for_calculating':
		case 'calculating_changed_mode':
		case 'calculating_call_API':
		case 'calculating_waiting_result':
		case 'calculating_error':
		case 'drawing':
		case 'route_confirm':
		case 'route_end':
		case 'route_ended':		
			// Rotate
			this.map_resize("100%");
			var rotation = maths.get_angle(false, nav_data.lng_prev, nav_data.lat_prev, nav_data.lng, nav_data.lat);
			mapUI.set_map_rotate(0);
			if (rotation != null)
				mapUI.set_marker_rotate(rotation);
			break;
		case 'route_driving':
		case 'route_out':
		case 'route_out_returned':
		case 'route_out_waiting_result':
		case 'route_out_calculating_error':
		case 'route_out_drawing':
			// Rotate
			if (settings.get_rotate_map() && this.get_center_pos()) {
				this.map_resize("140%");
				if (this.get_center_pos()) {
					var rotation = maths.get_angle(true, nav_data.lng_prev, nav_data.lat_prev, nav_data.lng, nav_data.lat);
					if (rotation != null)
						mapUI.set_map_rotate(rotation);
					mapUI.set_marker_rotate(0);
				}
				else {
					var rotation = maths.get_angle(false, nav_data.lng_prev, nav_data.lat_prev, nav_data.lng, nav_data.lat);
					mapUI.set_map_rotate(0);
					if (rotation != null)
						mapUI.set_marker_rotate(rotation);
				}
			}
			else {
				this.map_resize("100%");
				var rotation = maths.get_angle(false, nav_data.lng_prev, nav_data.lat_prev, nav_data.lng, nav_data.lat);
				mapUI.set_map_rotate(0);
				if (rotation != null)
					mapUI.set_marker_rotate(rotation);
			}
			
			// Zoom
			if (this.get_center_pos()) {
				var max_zoom = this.ZOOM;
				if (nav_data.speed > nav.CITY)
					max_zoom--; 
				if (nav_data.speed > nav.HIGHWAY)
					max_zoom--; 
				if (nav_data.speed > nav.HIGHSPEED)
					max_zoom--; 
				mapUI.set_map_zoom(max_zoom);
			}
			break;
	}
}
