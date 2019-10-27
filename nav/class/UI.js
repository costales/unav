/*
 * uNav http://launchpad.net/unav
 * Copyright (C) 2015-2018 Marcos Alvarez Costales https://launchpad.net/~costales
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

function UI(map, nav, settings, maths, lang_root) {
	this.map = map;
	this.nav = nav;
	this.settings = settings;
	this.maths = maths;
	this.lang_root = lang_root.toLowerCase();
	
	this.pos_prev = new Object();
		this.pos_prev['lat'] = null;
		this.pos_prev['lng'] = null;
	
	this.center_onpos = true;
	this.center_1st_pos = true;
	this.zoom_unav = true;
	this.map_stretched = true;
	
	this.marker_pos = new ol.Overlay({
		positioning: 'center-center',
		element: document.getElementById('marker_pos')
	});
	this.map.addOverlay(this.marker_pos);
	$('#marker_pos').click(function () {
		window.location = 'http://clicked_on_map?follow/' + nav.get_pos_data()['now_lat'] + '/' + nav.get_pos_data()['now_lng'] + '/none/none/none/' + t("Current Position");
	});
	
	this.marker_start = new ol.Overlay({
		positioning: 'bottom-center',
		element: document.getElementById('marker_pos_start')
	});
	this.map.addOverlay(this.marker_start);
	$('#marker_pos_start').click(function () {
		window.location = 'http://clicked_on_map?nofollow/' + nav.get_pos_data()['start_lat'] + '/' + nav.get_pos_data()['start_lng'] + '/none/none/none/' + t("Current Start");
	});
	
	this.marker_end = new ol.Overlay({
		positioning: 'bottom-center',
		element: document.getElementById('marker_pos_end')
	});
	this.map.addOverlay(this.marker_end);
	$('#marker_pos_end').click(function () {
		window.location = 'http://clicked_on_map?nofollow/' + nav.get_pos_data()['end_lat'] + '/' + nav.get_pos_data()['end_lng'] + '/none/none/none/' + t("Current End");
	});
	
	$('#img_north').click(function () {
		map.getView().setRotation(0);
	});

	this.markers_POI = [];
	for (i=0 ; i<50; i++) {
		var POI = new ol.Overlay({
		  positioning: 'bottom-center',
		  element: document.getElementById('POI'+i)
		});
		this.markers_POI.push(POI);
		this.map.addOverlay(this.markers_POI[i]);
	}
	this.map_pois_extend = new ol.source.Vector({});

	this.markers_radar = [];
	for (i=0 ; i<nav.NUM_RADARS_MAX; i++) {
		var radar = new ol.Overlay({
		  positioning: 'bottom-center',
		  element: document.getElementById('radar'+i)
		});
		this.markers_radar.push(radar);
		this.map.addOverlay(this.markers_radar[i]);
	}

	this.routeSource = new ol.source.Vector({});
	var route_line = new ol.layer.Vector({
		source: this.routeSource,
		style: [
			new ol.style.Style({
				stroke: new ol.style.Stroke({
					color: '#D2DDFF',
					width: 6
				})
			}),
			new ol.style.Style({
				stroke: new ol.style.Stroke({
					color: '#4169E1',
					width: 4
				})
			})
		]
	});
	this.map.addLayer(route_line);
	
	this.online_layer = 0;
	
	this.scaleline = new ol.control.ScaleLine();
	this.map.addControl(this.scaleline);
	
	this.map_attributions = {
		0: {
			name:    "Carto Voyager",
			license: "<span onclick=\"qml_go_url('https://openrouteservice.org')\">© Openroute Service</span> <span onclick=\"qml_go_url('https://carto.com')\">© Carto</span> <span onclick=\"qml_go_url('http://www.openstreetmap.org/copyright')\">© OpenStreetMap contributors</span>",
			width:   "400px",
			left:    "-191px"
		},
		1: {
			name:    "Mapbox",
			license: "<span onclick=\"qml_go_url('https://openrouteservice.org')\">© Openroute Service</span>  <span onclick=\"qml_go_url('https://www.mapbox.com')\">© Mapbox</span> <span onclick=\"qml_go_url('http://www.openstreetmap.org/copyright')\">© OpenStreetMap contributors</span>",
			width:   "400px",
			left:    "-191px"
		},
		2: {
			name:    "Terrain",
			license: "<span onclick=\"qml_go_url('https://openrouteservice.org')\">© Openroute Service</span> <span onclick=\"qml_go_url('http://stamen.com')\">© Stamen</span> <span onclick=\"qml_go_url('http://www.openstreetmap.org/copyright')\">© OpenStreetMap contributors</span>",
			width:   "400px",
			left:    "-191px"
		},
		3: {
			name:    "Toner Lite",
			license: "<span onclick=\"qml_go_url('https://openrouteservice.org')\">© Openroute Service</span> <span onclick=\"qml_go_url('http://stamen.com')\">© Stamen</span> <span onclick=\"qml_go_url('http://www.openstreetmap.org/copyright')\">© OpenStreetMap contributors</span>",
			width:   "400px",
			left:    "-191px"
		},
		4: {
			name:    "OpenTopoMap",
			license: "<span onclick=\"qml_go_url('https://openrouteservice.org')\">© Openroute Service</span>  <span onclick=\"qml_go_url('http://opentopomap.org')\">© OpenTopoMap</span> <span onclick=\"qml_go_url('http://www.openstreetmap.org/copyright')\">© OpenStreetMap contributors</span>",
			width:   "440px",
			left:    "-211px"
		},
		5: {
			name:    "Carto Positron",
			license: "<span onclick=\"qml_go_url('https://openrouteservice.org')\">© Openroute Service</span> <span onclick=\"qml_go_url('https://carto.com')\">© Carto</span> <span onclick=\"qml_go_url('http://www.openstreetmap.org/copyright')\">© OpenStreetMap contributors</span>",
			width:   "400px",
			left:    "-191px"
		},
		6: {
			name:    "Carto Dark Matter",
			license: "<span onclick=\"qml_go_url('https://openrouteservice.org')\">© Openroute Service</span> <span onclick=\"qml_go_url('https://carto.com')\">© Carto</span> <span onclick=\"qml_go_url('http://www.openstreetmap.org/copyright')\">© OpenStreetMap contributors</span>",
			width:   "400px",
			left:    "-191px"
		},
		7: {
			name:    "dummy",
			license: "dummy",
			width:   "400px",
			left:    "-191px"
		}
	};
}

UI.prototype.ZOOM_CITY = 17;
UI.prototype.ZOOM_POI = 17;
UI.prototype.ZOOM_NOW2EXIT = 16;
UI.prototype.ZOOM_NEAR2EXIT = 13;
UI.prototype.ZOOM_FAR2EXIT = 12;
UI.prototype.DIST_NEAR2EXIT = 525;
UI.prototype.DIST_FAR2EXIT = 4500;
UI.prototype.DIST4ROTATION = 3;
UI.prototype.SPEED4ROTATION = 5;
UI.prototype.COLOR_ORANGE = '#DD4814';
UI.prototype.COLOR_BLACK = '#292929';
UI.prototype.MAP_VIEW_DEFAULT = new ol.View({
	center: ol.proj.transform([4.666389, 50.009167], 'EPSG:4326', 'EPSG:3857'),
	zoom: 4,
	minZoom: 3,
	maxZoom: 18
});
UI.prototype.MAP_VIEW_TOPO = new ol.View({
	center: ol.proj.transform([4.666389, 50.009167], 'EPSG:4326', 'EPSG:3857'),
	zoom: 4,
	minZoom: 3,
	maxZoom: 17
});

UI.prototype.set_map_stretched = function(status) {
	this.map_stretched = status;
}

UI.prototype.set_center_onpos = function(status) {
	this.center_onpos = status;
}

UI.prototype.get_center_onpos = function() {
	return this.center_onpos;
}

UI.prototype.get_map_layer = function() {
	return this.online_layer;
}

UI.prototype.set_confirm_btn_color = function(mode) {
	switch (mode) {
		case 0: 
			$("#btn1_set_car").css(   {"background": this.COLOR_ORANGE, "border-color":this.COLOR_ORANGE});
			$("#btn1_set_walk").css(  {"background": this.COLOR_BLACK,  "border-color":this.COLOR_BLACK});
			$("#btn1_set_bike").css(  {"background": this.COLOR_BLACK,  "border-color":this.COLOR_BLACK});
			$("#btn2_set_car").css(   {"background": this.COLOR_ORANGE, "border-color":this.COLOR_ORANGE});
			$("#btn2_set_walk").css(  {"background": this.COLOR_BLACK,  "border-color":this.COLOR_BLACK});
			$("#btn2_set_bike").css(  {"background": this.COLOR_BLACK,  "border-color":this.COLOR_BLACK});
			break;
		case 1: 
			$("#btn1_set_car").css(   {"background": this.COLOR_BLACK,  "border-color":this.COLOR_BLACK});
			$("#btn1_set_walk").css(  {"background": this.COLOR_ORANGE, "border-color":this.COLOR_ORANGE});
			$("#btn1_set_bike").css(  {"background": this.COLOR_BLACK,  "border-color":this.COLOR_BLACK});
			$("#btn2_set_car").css(   {"background": this.COLOR_BLACK,  "border-color":this.COLOR_BLACK});
			$("#btn2_set_walk").css(  {"background": this.COLOR_ORANGE, "border-color":this.COLOR_ORANGE});
			$("#btn2_set_bike").css(  {"background": this.COLOR_BLACK,  "border-color":this.COLOR_BLACK});
			break;
		case 2: 
			$("#btn1_set_car").css(   {"background": this.COLOR_BLACK,  "border-color":this.COLOR_BLACK});
			$("#btn1_set_walk").css(  {"background": this.COLOR_BLACK,  "border-color":this.COLOR_BLACK});
			$("#btn1_set_bike").css(  {"background": this.COLOR_ORANGE, "border-color":this.COLOR_ORANGE});
			$("#btn2_set_car").css(   {"background": this.COLOR_BLACK,  "border-color":this.COLOR_BLACK});
			$("#btn2_set_walk").css(  {"background": this.COLOR_BLACK,  "border-color":this.COLOR_BLACK});
			$("#btn2_set_bike").css(  {"background": this.COLOR_ORANGE, "border-color":this.COLOR_ORANGE});
			break;
	}
}

UI.prototype.set_map_layer = function(layer) {
	var aux_center = this.map.getView().getCenter();
	var aux_zoom = this.map.getView().getZoom();
	var layers_max_ind = this.map.getLayers().getArray().length - 2; // 2 Extra layers: map + line route
	
	if (layer == 99) // Independent of number of layers
		layer = layers_max_ind; 
	if (layer > layers_max_ind) // Assure auto works if a layer is removed in future
		layer = 0;
	this.online_layer = layer;

	// 0 Carto Voyager, 1 Mapbox, 2 Terrain, 3 Toner, 4 OpenTopoMap, 5 Carto Positron, 6 Carto Dark, 7 Last=Offline
	for (i=0; i<=layers_max_ind; i++) {
		if (i == layer) {
			this.map.getLayers().getArray()[i].setVisible(true);
			$('#map_attribution').html(this.map_attributions[i]['license']);
			$('#map_attribution').css({'width': this.map_attributions[i]['width'], 'left': this.map_attributions[i]['left']});
			
			switch (this.map_attributions[i]['name']) {
				case 'OpenTopoMap':
					this.map.setView(this.MAP_VIEW_TOPO);
					break;
				default:
					this.map.setView(this.MAP_VIEW_DEFAULT);
			}
			
			this.map.getView().setCenter(aux_center);
			this.map.getView().setZoom(aux_zoom);
		}
		else {
			this.map.getLayers().getArray()[i].setVisible(false);
		}
	}
	
	if (layer == layers_max_ind) { // Offline = unknow tiles
		$('#map_attribution').hide();
		$(".map").addClass('body_bg');
	}
	else {
		$('#map_attribution').show();
		$(".map").removeClass('body_bg');
	}
}

UI.prototype.set_center_1st_pos = function(status) {
	this.center_1st_pos = status;
}

UI.prototype.get_center_1st_pos = function() {
	return this.center_1st_pos;
}

UI.prototype.set_zoom_unav = function(zoom) {
	this.zoom_unav = zoom;
}

UI.prototype.markers = function(start_lat, start_lng, end_lat, end_lng) {
	this.marker_start.setPosition(undefined);
	this.marker_end.setPosition(undefined);
	$('#marker_pos_start').hide();
	$('#marker_pos_end').hide();
	
	if (this.nav.get_route_status() == '2review' || this.nav.get_route_status() == 'yes' || this.nav.get_route_status() == 'out' || this.nav.get_route_status() == 'ended' || this.nav.get_route_status().startsWith('simulate_done')) {
		if (start_lat != null && start_lng != null) {
			$('#marker_pos_start').show();
			this.marker_start.setPosition(ol.proj.transform([start_lng, start_lat], 'EPSG:4326', 'EPSG:3857'));
		}
	}
	
	if (end_lat != null && end_lng != null) {
		$('#marker_pos_end').show();
		this.marker_end.setPosition(ol.proj.transform([end_lng, end_lat], 'EPSG:4326', 'EPSG:3857'));
	}
}

UI.prototype.btns_confirm_route = function(show) {
	if (show) {
		$('#btn_start').show();
		$('#btn_cancel').show();
		$('#btn_notfound').hide();
		$('#p_review_time2left').show();
		$('#p_review_total_dist').show();
		$('#p_review_time2arrive').show();
	}
	else {
		$('#btn_start').hide();
		$('#btn_cancel').hide();
		$('#btn_notfound').show();
		$('#p_review_time2left').hide();
		$('#p_review_total_dist').hide();
		$('#p_review_time2arrive').hide();
	}
}

UI.prototype.route = function(redraw_map) {
	if (this.nav.get_route_status() !== 'drawing' && this.nav.get_route_status() !== 'simulate_drawing') {
		this.routeSource.clear();
		return;
	}
	
	this.map.getView().setRotation(0);
	
	this.routeSource.clear();
	
	var lineString = new ol.geom.LineString(this.nav.get_route_line());
	lineString.transform('EPSG:4326', 'EPSG:3857');
	this.routeSource.addFeature(
		new ol.Feature({
			geometry: lineString
		})
	);
	
	// Fit route to view
	if (redraw_map) {
		var pan = ol.animation.pan({duration: 600, source: map.getView().getCenter(), easing: ol.easing.linear});
		var zoom = ol.animation.zoom({duration: 600, resolution: map.getView().getResolution(), easing: ol.easing.linear});
		this.map.beforeRender(pan, zoom);

		var aux_height = 0;
		if ($('#panel_review_btns').is(':visible'))
			aux_height = aux_height + $('#panel_review_btns').height();
		if ($('#panel_review_summary').is(':visible'))
			aux_height = aux_height + $('#panel_review_summary').height();
		if ($('#panel_summary').is(':visible'))
			aux_height = aux_height + $('#panel_summary').height();
		if ($('#panel_txt_ind').is(':visible'))
			aux_height = aux_height + $('#panel_txt_ind').height();
		if ($('#panel_msg').is(':visible'))
			aux_height = aux_height + $('#panel_msg').height();
		aux_height = aux_height + 110;
		this.map.getView().fit(this.routeSource.getExtent(), this.map.getSize(), {padding: [150, 25, aux_height, 25]});
		map.updateSize();
	}
}

UI.prototype.pos = function(lat, lng, accu) {
	this.marker_pos.setPosition(undefined);
	$('#marker_pos').hide();
	
	if (lat === null || lng === null)
		return;
	
	switch (this.settings.get_routing_mode()) {
		case 0:
			$('#marker_pos').attr('src', "img/marker/car.png");
			break;
		case 1:
			$('#marker_pos').attr('src', "img/marker/walk.png");
			break;
		case 2:
			$('#marker_pos').attr('src', "img/marker/bike.png");
			break;
		case 3:
			$('#marker_pos').attr('src', "img/marker/walk.png");
			break;
	}
	
	$('#marker_pos').show();
	this.marker_pos.setPosition(ol.proj.transform([lng, lat], 'EPSG:4326', 'EPSG:3857'));

	if (accu <= this.nav.ACCU4DRIVE)
		$('#marker_pos').css('opacity', '1.0');
	else if (accu <= this.nav.ACCU4DRIVE * 2)
		$('#marker_pos').css('opacity', '0.9');
	else if (accu <= this.nav.ACCU4DRIVE * 4)
		$('#marker_pos').css('opacity', '0.7');
	else
		$('#marker_pos').css('opacity', '0.5');
}

UI.prototype.map_center = function(lat, lng) {
	if (!this.center_onpos)
		return;
	
	if (lat === null && lng === null)
		return;
	
	this.map.getView().setCenter(ol.proj.transform([lng, lat], 'EPSG:4326', 'EPSG:3857'));
}

UI.prototype.map_zoom = function(speed, dist2turn, dist_track_done, radar) {
	if (!this.zoom_unav)
		return;

	if (this.nav.get_route_status() != 'yes') {
		this.map.getView().setZoom(this.ZOOM_POI); // Looking position = POI
		return;
	}
	
	if (speed <= this.nav.SPEED_CITY) {
		this.map.getView().setZoom(this.ZOOM_CITY); // City
	}
	else {
		if (!radar && dist2turn > this.DIST_FAR2EXIT && dist_track_done > this.DIST_FAR2EXIT)
			this.map.getView().setZoom(this.ZOOM_FAR2EXIT);
		else if (!radar && dist2turn > this.DIST_NEAR2EXIT && dist_track_done > this.DIST_NEAR2EXIT)
			this.map.getView().setZoom(this.ZOOM_NEAR2EXIT);
		else
			this.map.getView().setZoom(this.ZOOM_NOW2EXIT);
	}
}

UI.prototype.markers_POI_clear = function() {
	for (i=0; i<this.markers_POI.length; i++) {
		this.markers_POI[i].setPosition(undefined);
		$('#POI'+i).unbind("click");
	}
}

UI.prototype.markers_POI_set = function(pois, img_inside) {
	var osm_type = '';
	var osm_id = '';
	var phone = '';
	
	// Map
	this.set_center_onpos(false);
	this.set_center_1st_pos(false);
	this.set_zoom_unav(false);
	this.set_map_stretched(false);
	this.map_height();
	
	// Clear
	this.markers_POI_clear();
	this.map_pois_extend.clear();
	
	if (typeof img_inside === 'undefined') {
		$('.POI_img_inside').hide();
		$('.POI_img').attr('src', 'img/marker/POI.png');
		$('.POI_img').show();
	}
	else {
		$('.POI_img_inside').attr('src', 'img/poi/' + img_inside + '.svg');
		$('.POI_img_inside').show();
		$('.POI_img').attr('src', 'img/marker/POI_img.png');
		$('.POI_img').show();
	}
	
	for (i=0; i<pois.length; i++) {
		// More POIs than expected?
		if (i>=this.markers_POI.length)
			break;
		
		// Show POI
		this.markers_POI[i].setPosition(ol.proj.transform([pois[i].lng, pois[i].lat], 'EPSG:4326', 'EPSG:3857'));
		
		// POI Click
		osm_type = 'none';
		osm_id = 'none';
		phone = 'none';
		if (typeof pois[i].phone !== 'undefined')
			phone = pois[i].phone;
		if (typeof pois[i].osm_type !== 'undefined')
			osm_type = pois[i].osm_type;
		if (typeof pois[i].osm_id !== 'undefined')
			osm_id = pois[i].osm_id;

		$('#POI'+i).bind('click', {title: pois[i].title, lat: pois[i].lat, lng: pois[i].lng, osm_type: osm_type, osm_id: osm_id, phone: phone}, function(event) {
			ui.set_center_onpos(false);
			ui.set_center_1st_pos(false);
			
			map.beforeRender(ol.animation.pan({
				duration: 600, 
				source: map.getView().getCenter(),
				easing: ol.easing.linear
			}));
			map.getView().setCenter(ol.proj.transform([event.data.lng, event.data.lat], 'EPSG:4326', 'EPSG:3857'));
			
			window.location = 'http://clicked_on_map?nofollow/' + event.data.lat + '/' + event.data.lng + '/' + event.data.osm_type  + '/' + event.data.osm_id + '/' + event.data.phone + '/' + event.data.title.replace(/\//g, "¿¿¿");
		});
		
		// For fit map
		var iconFeature = new ol.Feature({
			geometry: new ol.geom.Point(ol.proj.transform([pois[i].lng, pois[i].lat], 'EPSG:4326', 'EPSG:3857'))
		});
		this.map_pois_extend.addFeature(iconFeature);
	}
	
	// Show PopUp if poi.length = 1
	var pan = ol.animation.pan({duration: 600, source: map.getView().getCenter(), easing: ol.easing.linear});
	var zoom = ol.animation.zoom({duration: 600, resolution: map.getView().getResolution(), easing: ol.easing.linear});
	this.map.beforeRender(pan, zoom);
	if (pois.length === 1) {
		// Adjust zoom if so big
		if (this.map.getView().getZoom() < 8)
			this.map.getView().setZoom(8);
		// Adjust map to boundbox
		if (typeof pois[0].boundingbox !== 'undefined' && pois[0].boundingbox !== 'undefined') {
			var coords_bound = pois[0].boundingbox.split(',');
			var extent_aux = [parseFloat(coords_bound[2]), parseFloat(coords_bound[0]), parseFloat(coords_bound[3]), parseFloat(coords_bound[1])];
			extent_aux = ol.extent.applyTransform(extent_aux, ol.proj.getTransform("EPSG:4326", "EPSG:3857"));
			this.map.getView().fit(extent_aux, this.map.getSize(), this.map.getSize(), {padding: [200, 15, 200, 15]});
		}
		// Center on POI
		this.map.getView().setCenter(ol.proj.transform([pois[0].lng, pois[0].lat], 'EPSG:4326', 'EPSG:3857'));
		
		osm_type = 'none';
		osm_id = 'none';
		phone = 'none';
		if (typeof pois[0].phone !== 'undefined')
			phone = pois[0].phone;
		if (typeof pois[0].osm_type !== 'undefined')
			osm_type = pois[0].osm_type;
		if (typeof pois[0].osm_id !== 'undefined')
			osm_id = pois[0].osm_id;
		
		window.location = 'http://clicked_on_map?nofollow/' + pois[0].lat + '/' + pois[0].lng + '/' + osm_type + '/' + osm_id + '/' + phone + '/' + pois[0].title.replace(/\//g, "¿¿¿");
	}
	else { // Fit
		var aux_height = 0;
		if ($('#panel_review_btns').is(':visible'))
			aux_height = aux_height + $('#panel_review_btns').height();
		if ($('#panel_review_summary').is(':visible'))
			aux_height = aux_height + $('#panel_review_summary').height();
		if ($('#panel_summary').is(':visible'))
			aux_height = aux_height + $('#panel_summary').height();
		if ($('#panel_txt_ind').is(':visible'))
			aux_height = aux_height + $('#panel_txt_ind').height();
		if ($('#panel_msg').is(':visible'))
			aux_height = aux_height + $('#panel_msg').height();
		aux_height = aux_height + 110;
		this.map.getView().fit(this.map_pois_extend.getExtent(), this.map.getSize(), {padding: [150, 15, aux_height, 15]});
	}
}

UI.prototype.panels = function(route_indicator) {
	$('#panel_msg, #panel_navigation, #panel_review, #max_speed_alert').hide();
	
	switch(this.nav.get_route_status()) {
		case 'waiting4signal':
			$('#p_msg').html(t("Waiting for a GPS signal…"));
			$('#panel_msg').show();
			break;
		case 'calc':
		case 'calc_from_out':
		case 'calculating':
		case 'calculating_from_out':
			$('#p_msg').html(t("Searching for a route…"));
			$('#panel_msg').show();
			break;
		case 'drawing':
			$('#p_msg').html(t("Drawing route…"));
			$('#panel_msg').show();
			break;
		case 'errorAPI':
			$('#p_msg').html(t("Trying search again soon…"));
			$('#panel_msg').show();
			break;
		case 'out':
			$('#p_msg').html(t("Recalculating route…"));
			$('#panel_msg').show();
			break;
		case '2review':
		case 'calculating_error':
			$('#p_review_time2left').html(this.maths.time2human(route_indicator['time'], false));
			$('#p_review_total_dist').html(this.maths.dist2human(route_indicator['distance_total'], this.settings.get_unit()));
			$('#p_review_time2arrive').html(this.maths.time2human(route_indicator['time'], true));
			$('#panel_review').show();
			break;
		case 'yes':
			$('#p_time2left').html(this.maths.time2human(route_indicator['time'], false));
			$('#p_total_dist').html(this.maths.dist2human(route_indicator['distance_total'], this.settings.get_unit()));
			$('#p_speed').html(this.maths.get_speed(route_indicator['speed'], this.settings.get_unit()));
			$('#p_time2arrive').html(this.maths.time2human(route_indicator['time'], true));
			$('#p_img_ind').attr('src', 'img/steps/'+route_indicator['indication']+'.svg');
			$('#p_next_dist').html(this.maths.dist2human(route_indicator['dist2turn'], this.settings.get_unit()));
			$('#p_txt_ind').html(route_indicator['msg']);
			$('#panel_navigation').show();
			if (this.settings.get_ui_speed())
				$('#p_speed').show();
			else
				$('#p_speed').hide();
			
			if (route_indicator['voice'])
				this.speak(route_indicator['indication']);
				
			if (route_indicator['speaked'])
				$('#panel_indication').css('background-color', this.COLOR_ORANGE);
			else
				$('#panel_indication, #panel_txt_ind').css('background-color', this.COLOR_BLACK);
			
			// Radar
			if (route_indicator['radar']) {
				$('#max_speed_alert').show();
				$('#txt_mapspeed').html(route_indicator['radar_speed']);
				if (route_indicator['radar_sound'])
					this.play_sound(0);
			}
			break;
		case 'ended':
			$('#p_msg').html(t("You have arrived at your destination"));
			$('#panel_msg').show();
			if (route_indicator['voice'])
				this.speak(route_indicator['indication']);
			break;
		case 'simulate_calculating':
		case 'simulate_drawing':
			$('#p_msg').html(t("Simulating route…"));
			$('#panel_msg').show();
			break;
		case 'simulate_error':
			$('#p_time2left').html('');
			$('#p_total_dist').html('');
			$('#p_time2arrive').html('');
			$('#p_speed').hide();
			$('#p_next_dist').html('');
			$('#p_txt_ind').html(this.compose_btns_routing());
			this.set_confirm_btn_color(this.settings.get_routing_mode());
			$('#p_img_ind').attr('src', 'img/mode/noroute.svg');
			$('#panel_navigation').show();
			$('#panel_indication, #panel_txt_ind').css('background-color', this.COLOR_BLACK);
			break;
		case 'simulate_done_bike':
		case 'simulate_done_walk':
		case 'simulate_done_car':
			$('#p_time2left').html(this.maths.time2human(route_indicator['time'], false));
			$('#p_total_dist').html(this.maths.dist2human(route_indicator['distance_total'], this.settings.get_unit()));
			$('#p_time2arrive').html(this.maths.time2human(route_indicator['time'], true));
			$('#p_speed').hide();
			$('#p_next_dist').html('');
			$('#p_txt_ind').html(this.compose_btns_routing());
			this.set_confirm_btn_color(this.settings.get_routing_mode());
			$('#p_img_ind').attr('src', 'img/mode/steps.svg');
			$('#panel_navigation').show();
			$('#panel_indication, #panel_txt_ind').css('background-color', this.COLOR_BLACK);
			break;
	}
}

UI.prototype.compose_btns_routing = function() {
	return "<table class='tg' id='panel_review_btns'> \
		  <tr> \
			<th class='tg-yw4l'> \
				<button data-role='button' id='btn2_set_car' class='btns2_mode_route negative' onClick='javascript:set_simulate_mode(0)'><img class='img2_btn_route' src='img/mode/car.svg'></button> \
				<button data-role='button' id='btn2_set_walk' class='btns2_mode_route negative' onClick='javascript:set_simulate_mode(1)'><img class='img2_btn_route' src='img/mode/walk.svg'></button> \
				<button data-role='button' id='btn2_set_bike' class='btns2_mode_route negative' onClick='javascript:set_simulate_mode(2)'><img class='img2_btn_route' src='img/mode/bike.svg'></button> \
			</th> \
		  </tr> \
		</table>";
}

UI.prototype.scale_line = function() {
	switch(this.nav.get_route_status()) {
		case 'no':
			$('.ol-scale-line').css({top: 'auto', bottom: '8px'});
			break;
		case '2review':
			$('.ol-scale-line').css({top: (window.innerHeight - $('#panel_review_btns').height() - $('#panel_review_summary').height() - 22), bottom: 'auto'});
			break;
		case 'yes':
		case 'simulate_done_bike':
		case 'simulate_done_car':
		case 'simulate_done_walk':
			$('.ol-scale-line').css({top: (window.innerHeight - $('#panel_summary').height() - $('#panel_txt_ind').height() - 22), bottom: 'auto'});
			break;
		default:
			$('.ol-scale-line').css({top: (window.innerHeight - $('#panel_msg').height() - 22), bottom: 'auto'});
	}
}

UI.prototype.map_height = function() {
	// car + route = car on bottom
	if (this.map_stretched && this.settings.get_routing_mode() != 1 && this.settings.get_routing_mode() != 3 && this.nav.get_route_status() == 'yes') {
		var aux_height = 0;
		if ($('#panel_summary').is(':visible'))
			aux_height = aux_height + $('#panel_summary').height();
		if ($('#panel_txt_ind').is(':visible'))
			aux_height = aux_height + $('#panel_txt_ind').height();
		if ($('#panel_msg').is(':visible'))
			aux_height = aux_height + $('#panel_msg').height();
		if (window.innerWidth <= window.innerHeight) // Portraid
			$('.map').css({height: ((window.innerHeight * 2) - (aux_height * 2) - 120)});
		else // Landscape
			$('.map').css({height: ((window.innerHeight * 2) - (aux_height * 2) - 68)});
	}
	else {
		$('.map').css({height: '100%'});
	}
	
	this.map.updateSize(); // Hack: Force reload map
	
	// Attribution pos
	if (this.nav.get_route_status() != 'no')
		$('#map_attribution').css({"margin-top": "-40px"});
	else
		$('#map_attribution').css({"margin-top": "auto"});

}

UI.prototype.play_sound = function(sound) {
	if (this.settings.get_sound() == 2)
		return;
	
	if (sound == 0) // Radar
		$('#radar_alert').trigger('play');
	if (sound == 1) // Error
		$('#error_alert').trigger('play');
}

UI.prototype.markers_radar_clear = function() {
	for (i=0; i<this.markers_radar.length; i++) {
		this.markers_radar[i].setPosition(undefined);
		$('#radar'+i).hide();
		$('#radar'+i).unbind("click");
	}
}

UI.prototype.markers_radar_set = function(radars) {
	// Not show speed cameras position for France users. +info: http://goo.gl/ulXvG8
	if (this.lang_root == 'fr' || this.lang_root == 'br')
		return;
	
	for (i=0; i<radars.length; i++) {
		// More radars than expected?
		if (i>=this.markers_radar.length)
			break;
		// Show radar
		this.markers_radar[i].setPosition(ol.proj.transform([radars[i]['lng'], radars[i]['lat']], 'EPSG:4326', 'EPSG:3857'));
		$('#radar'+i).show();
	}
}

UI.prototype.map_rotation = function(status_route, speed, prev_lat, prev_lng, now_lat, now_lng) {
	if (!this.center_onpos || prev_lat === null || prev_lng === null)
		return;
	if (this.center_onpos && (this.settings.get_routing_mode() == 1 || this.settings.get_routing_mode() == 3)) {
		this.map.getView().setRotation(0);
		return;
	}
	
	switch(status_route) {
		case 'yes':
		case 'ended':
		case 'errorAPI':
		case 'drawing':
		case 'calc':
		case 'calc_from_out':
		case 'calculating':
		case 'calculating_from_out':
		case 'out':
			if (speed > this.SPEED4ROTATION) {
				var dist = geolib.getDistance(
					{latitude: prev_lat, longitude: prev_lng},
					{latitude: now_lat, longitude: now_lng}
				);
				if (dist >= this.DIST4ROTATION) { // Only if there is an enough distance for calculate
					var angle = this.maths.get_angle(prev_lat, prev_lng, now_lat, now_lng);
					this.map.getView().setRotation(angle);
				}
			}
			break;
		default:
			this.map.getView().setRotation(0);
	}
}

UI.prototype.set_north = function(degress) {
	if (degress == 0 && this.nav.get_route_status() == 'no') {
		$('#map_north').hide();
	}
	else {
		$('#img_north').css('transform', 'rotate('+degress+'deg)');
		$('#map_north').show();
	}
}

UI.prototype.speak = function(indication) {
	switch (this.settings.get_sound()) {
		case 0:
			$('#'+indication).trigger('play');
			break;
		case 1:
			$('#voice_notif').trigger('play');
			break;
	}
}

UI.prototype.play_test = function() {
	load_custom_voices(true);
}

UI.prototype.set_scale_unit = function(unit) {
	if (unit == 'km')
		this.scaleline.setUnits('metric');
	else
		this.scaleline.setUnits('imperial');
}

UI.prototype.update = function() {
	var gps_data = this.nav.get_pos_data();
	var route_indicator = this.nav.get_route_indication();
	
	this.markers(gps_data['start_lat'], gps_data['start_lng'], gps_data['end_lat'], gps_data['end_lng']);
	
	this.panels(route_indicator);

	this.scale_line();
	
	this.pos(gps_data['now_lat'], gps_data['now_lng'], gps_data['accu']);
	
	if (this.center_1st_pos) {
		this.center_1st_pos = false;
		this.center_onpos = true;
		this.zoom_unav = true;
		
		var rotate = ol.animation.rotate({duration: 600, rotation: map.getView().getRotation(), easing: ol.easing.linear});
		var pan = ol.animation.pan({duration: 600, source: map.getView().getCenter(), easing: ol.easing.linear});
		var zoom = ol.animation.zoom({duration: 600, resolution: map.getView().getResolution(), easing: ol.easing.linear});
		this.map.beforeRender(pan, zoom, rotate);
	}
	
	this.map_height();
	this.map_rotation(this.nav.get_route_status(), gps_data['speed'], this.pos_prev['lat'], this.pos_prev['lng'], gps_data['now_lat'], gps_data['now_lng']);
	this.map_center(gps_data['now_lat'], gps_data['now_lng']);
	this.map_zoom(gps_data['speed'], route_indicator['dist2turn'], route_indicator['dist_track_done'], route_indicator['radar']);
	
	this.pos_prev['lat'] = gps_data['now_lat'];
	this.pos_prev['lng'] = gps_data['now_lng'];
}
