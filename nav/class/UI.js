/*
 * uNav http://launchpad.net/unav
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

function UI() {
	this.center_pos = false;
	this.searchPageWith2Columns = 1;
}

UI.prototype.get_search2columns = function() {
	return this.searchPageWith2Columns;
}
UI.prototype.set_search2columns = function(columns) {
	this.searchPageWith2Columns = columns;
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
		$("#panelRecenterRoute").hide();
	}
	else {
		$("#pulsePosBtn").css("background", "#4d4d4d");
		$("#geo").attr("src", "img/ui/geoDisabled.svg");
		$("#pulsePosBtn").css("animation", "");
	}

	if (!status && nav.get_data().mode.startsWith('route_'))
		$("#panelRecenterRoute").show();	
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
		$.doTimeout('autohideMsg', 2000, function(){
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
		$("#btnCenter").html(t("Center"));
		$("#btnCancel").html(t("Cancel"));
		$("#btnStart").html(t("Start"));
}

// Search page has a big height and the panels are hidden
UI.prototype.topPanelsMargin = function(page, columns) {
	if (columns > 1 && page == "search")
		$(".topPanels").css("margin-top", "84px");
	else
		$(".topPanels").css("margin-top", "50px");
}

UI.prototype.update_lower_panel = function(duration, distance, percentage) {
	var txt_time = maths.time2human(duration);
	var txt_distance = maths.dist2human(distance, settings.get_unit());
	var txt_ETA = maths.time2human(duration, true);
	$("#totalProgress").css("width", percentage+"%");
	$('#endTime').html(txt_time);
	$('#endDistance').html(txt_distance);
	$('#endHour').html(txt_ETA);
	$("#totalProgress").css("width", percentage+"%");
	$('#confirmEndTime').html(txt_time);
	$('#confirmEndDistance').html(txt_distance);
	$('#confirmEndHour').html(txt_ETA);
}

UI.prototype.update_nav_panel = function(type, name, instruction, distance) {
	if (name != '' && name != '-')
		$('#stepTxt').html(name);
	else
		$('#stepTxt').html(instruction);
	$('#stepImg').html('<img src="img/steps/' + type + '.svg">');
	$('#distance').html(maths.dist2human(distance, settings.get_unit()));
}

UI.prototype.speak = function(speak, type) {
	if (speak != 1)
		return;
	if (type != 8 && type != 99)
		$('#'+type).trigger('play');
}

UI.prototype.update_pos = function(nav_data) {
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
			var rotation = maths.get_angle(nav_data.mode, false, nav_data.lng_prev, nav_data.lat_prev, nav_data.lng, nav_data.lat);
			mapUI.set_map_rotate(0);
			if (rotation != null)
				mapUI.set_marker_rotate(rotation);
			break;
		case 'route_driving':
		case 'route_out':
		case 'route_out_returned':
		case 'route_out_waiting_result':
		case 'route_out_calculating_error':
			// Rotate
			if (settings.get_rotate_map()) {
				this.map_resize("140%");
				if (this.get_center_pos()) {
					var rotation = maths.get_angle(nav_data.mode, true, nav_data.lng_prev, nav_data.lat_prev, nav_data.lng, nav_data.lat);
					if (rotation != null)
						mapUI.set_map_rotate(rotation);
					mapUI.set_marker_rotate(0);
				}
				else {
					var rotation = maths.get_angle(nav_data.mode, false, nav_data.lng_prev, nav_data.lat_prev, nav_data.lng, nav_data.lat);
					mapUI.set_map_rotate(0);
					if (rotation != null)
						mapUI.set_marker_rotate(rotation);
				}
			}
			else {
				this.map_resize("100%");
				var rotation = maths.get_angle(nav_data.mode, false, nav_data.lng_prev, nav_data.lat_prev, nav_data.lng, nav_data.lat);
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
