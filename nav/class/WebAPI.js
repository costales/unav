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

function WebAPI(nav, ui, settings) {
	this.nav = nav;
	this.ui = ui;
	this.settings = settings;
	this.confirm_route = '';
	
	this.route_status = '';
	this.t_prev = $.now() - 1;
}


// Route
WebAPI.prototype.set_route = function(lat1, lng1, lat2, lng2, confirm_route) {
	if (this.nav.get_route_status() == 'calculating' || this.nav.get_route_status() == 'calculating_from_out')
		return;
	
	if (confirm_route || this.t_prev < $.now()) { // Avoid several calls in a small time
		
		this.confirm_route = confirm_route;
		if (this.nav.get_route_status() == "errorAPI") // Avoid so many calls
			this.t_prev = $.now() + 60000;
		else
			this.t_prev = $.now() + 20000;
		
		this.route_status = this.nav.get_route_status();
		if (this.route_status == 'calc_from_out')
			this.nav.set_route_status('calculating_from_out');
		else
			this.nav.set_route_status('calculating');
		
		// API parameters
		var options = '';
		switch (this.settings.get_routing_mode()) {
			case 2:
				var routing_mode = 'cycling-regular';
				break;
			case 1:
				var routing_mode = 'foot-walking';
				break;
			default:
				var routing_mode = 'driving-car';
		}
		
		// API https://go.openrouteservice.org/documentation/#/reference/directions
		$.ajax({
		url: 'https://api.openrouteservice.org/directions',
			data: {
				api_key: '58d904a497c67e00015b45fca1a64e1896454ed08c81a552841363bc',
				coordinates: lng1 + ',' + lat1 + '|' + lng2 + ',' + lat2,
				profile: routing_mode,
				options: options
			},
			dataType: 'json',
			timeout: 52000,
			success: this.OK_callback_set_route.bind(this),
			error: this.KO_callback_set_route.bind(this)
		});
		
	}
}

WebAPI.prototype.OK_callback_set_route = function(data) {
	if (this.nav.get_route_status() == 'no' || this.nav.get_route_status() == 'yes') // Stop calc route if users canceled or returned to route between response of API
		return;
	
	if (!data.hasOwnProperty('error')) {
		this.nav.set_route((data.routes[0].summary.distance),	// totals meters
							data.routes[0].summary.duration,	// totals seconds
							data.routes[0].geometry,			// Map line
							data.routes[0].segments[0].steps	// Route stracks
		);
		gps_loop(this.nav.get_route_status()); // Show route = Avoid wait for GPS
	}
	else {
		if (this.route_status == 'calc_from_out') { // recalculate
			this.nav.set_route_status('calc_from_out');
			qml_show_notification('critical', 'calcfromout_error');
		}
		else {
			this.nav.set_route_status('errorAPI');
			qml_show_notification('critical', 'webapi_error');
		}
	}
}

WebAPI.prototype.KO_callback_set_route = function() {
	if (this.nav.get_route_status() == 'no' || this.nav.get_route_status() == 'yes') // Stop route if users canceled between calculation or returned to route
		return;
	
	if (this.route_status == 'calc_from_out') { // recalculate
		this.nav.set_route_status('calc_from_out');
		qml_show_notification('critical', 'calcfromout_error');
	}
	else {
		if (this.confirm_route) {
			this.nav.set_route_status('calculating_error');
			this.ui.route(false);
			this.ui.btns_confirm_route(false);
		}
		else {
			this.nav.set_route_status('errorAPI');
			qml_show_notification('critical', 'webapi_error');
		}
	}
}


// Simulate
WebAPI.prototype.simulate = function(lat1, lng1, lat2, lng2) {
	// API parameters
	var options = '';
	switch (this.settings.get_routing_mode()) {
		case 2:
			var routing_mode = 'cycling-regular';
			break;
		case 1:
			var routing_mode = 'foot-walking';
			break;
		default:
			var routing_mode = 'driving-car';
	}
	
	// API https://go.openrouteservice.org/documentation/#/reference/directions
	$.ajax({
		url: 'https://api.openrouteservice.org/directions',
		data: {
			api_key: '58d904a497c67e00015b45fca1a64e1896454ed08c81a552841363bc',
			coordinates: lng1 + ',' + lat1 + '|' + lng2 + ',' + lat2,
			profile: routing_mode,
			options: options
		},
		dataType: 'json',
		timeout: 52000,
		success: this.OK_callback_simulate.bind(this),
		error: this.KO_callback_simulate.bind(this)
	});
	
}

WebAPI.prototype.OK_callback_simulate = function(data) {
	if (this.nav.get_route_status() == 'no') // Stop route if users canceled between calculation
		return;
	
	if (!data.hasOwnProperty('error')) {
		this.nav.set_route((data.routes[0].summary.distance),	// totals meters
							data.routes[0].summary.duration,	// totals seconds
							data.routes[0].geometry,			// Map line
							data.routes[0].segments[0].steps	// Route stracks
		);
		// Avoid wait for GPS
		this.nav.set_route_status('simulate_drawing');
		this.ui.markers_POI_clear();
		this.ui.route(true);
		switch (this.settings.get_routing_mode()) {
			case 2:
				this.nav.set_route_status('simulate_done_bike');
				break;
			case 1:
				this.nav.set_route_status('simulate_done_walk');
				break;
			default:
				this.nav.set_route_status('simulate_done_car');
		}
	}
	else {
		click_cancel_route();
		
		this.nav.set_route_status('simulate_error');
	}
	this.ui.update();
}

WebAPI.prototype.KO_callback_simulate = function() {
	if (this.nav.get_route_status() == 'no') // Stop route if users canceled between calculation
		return;
	
	click_cancel_route();
	
	this.nav.set_route_status('simulate_error');
	this.ui.update();
}


// Radars
WebAPI.prototype.set_radars = function() {
	if (this.nav.get_route_status() != '2review' && this.nav.get_route_status() != 'yes')
		return;
	
	// Refresh current radars
	this.nav.radars_clear();
	this.ui.markers_radar_clear();
	
	// Search radars?
	if (!this.settings.get_alert_radars() || this.settings.get_routing_mode() != 0)
		return;

	var lng1, lat1, lng2, lat2, lng2_ext, lat2_ext, lng1_ext, lat1_ext;
	var lng_rt, lat_rt, rt_l, lng_rt_n, lat_rt_n;
	var n1, n2, n_l, n1_n, n2_n, k;

	var routeBoundaryPolygon_1 = "";
	var routeBoundaryPolygon_2 = "";

	// MAXPOINTS: maximum fixpoints for the Polygon (2x +4).
	// The higher the value, the higher the accuracy.
	// the faster getting all relevant radars
	// the closer to the route you are. might be limited by overpass.
	var MAXPOINTS = 75;

	//complete_line:
	var line = this.nav.route['complete_line'].geometry.coordinates
	var iter = Math.ceil(line.length/MAXPOINTS);
	lng1 = line[0][0];
	lat1 = line[0][1];

	//iterate over fixpoints:
	for (i = 0; i < line.length; i+=iter) {

		k = (i+iter).toFixed(0);
		if (k >= line.length) {k = line.length-1;}
		lng2 = line[k][0];
		lat2 = line[k][1];

		// route segment vector:
		lng_rt = lng2 - lng1;
		lat_rt = lat2 - lat1;
		// normalized (|1|) vector components
		rt_l = Math.sqrt(lat_rt*lat_rt + lng_rt*lng_rt);
		lng_rt_n = lng_rt/rt_l
		lat_rt_n = lat_rt/rt_l

		//route segment normal vector components to line
		n1 = lat2 - lat1; //lng
		n2 = lng1 - lng2; //lat
		// normalized (|1|) normal vector components
		n_l = Math.sqrt(n1*n1 + n2*n2);
		n1_n = n1/n_l;
		n2_n = n2/n_l;

		// init tolerance of route segment expansion:
		var d_neg_min = -0.005;
		var d_pos_max =  0.005;
		// extent route segment start/end points
		lng1_ext = lng1 - lng_rt_n*0.0005;
		lat1_ext = lat1 - lat_rt_n*0.0005;
		lng2_ext = lng2 + lng_rt_n*0.0005;
		lat2_ext = lat2 + lat_rt_n*0.0005;

		// iterate over route segment points to get max expansion of the route segment
		for (j = i+1; j < k; j++) {
			var lng_pt = line[j][0];
			var lat_pt = line[j][1];
			var lng_d_pt = lng1 - lng_pt;
			var lat_d_pt = lat1 - lat_pt;
			var distance_to_pt = (lng_rt*lat_d_pt - lng_d_pt*lat_rt) / Math.sqrt( lng_rt*lng_rt + lat_rt*lat_rt )
			if (distance_to_pt <= 0 && distance_to_pt < d_neg_min) { d_neg_min = distance_to_pt - 0.001; }
			if (distance_to_pt > 0 && distance_to_pt > d_pos_max) { d_pos_max = distance_to_pt + 0.001 ; }
		}

		// add fixpoints to polygon point set (routeBoundaryPolygon_x):
		if (i==0) { routeBoundaryPolygon_1 = Number(lat1_ext + n2_n*d_pos_max - lat_rt_n*0.005).toFixed(5) +
                    " " + Number(lng1_ext + n1_n*d_pos_max - lng_rt_n*0.005).toFixed(5) + " " ;
					routeBoundaryPolygon_2 = Number(lat1_ext + n2_n*d_neg_min - lat_rt_n*0.005).toFixed(5) +
                    " " + Number(lng1_ext + n1_n*d_neg_min- lng_rt_n*0.005).toFixed(5);
		}
		routeBoundaryPolygon_1 = //forward
				routeBoundaryPolygon_1 +
				Number(lat2_ext + n2_n*d_pos_max).toFixed(5) + " " + Number(lng2_ext + n1_n*d_pos_max).toFixed(5) + " " ;
		routeBoundaryPolygon_2 = //backward
				Number(lat2_ext + n2_n*d_neg_min).toFixed(5) + " " + Number(lng2_ext + n1_n*d_neg_min).toFixed(5) + " " +
				routeBoundaryPolygon_2;

		//set segment end to segment start
		lat1 = lat2;
		lng1 = lng2;
	}

	// Search radars POI http://wiki.openstreetmap.org/wiki/Overpass_API
	var poly_box = '(poly:\"' + routeBoundaryPolygon_1 + routeBoundaryPolygon_2 + '\");out;'
	$.ajax({
		url: 'https://overpass-api.de/api/interpreter?data=node[highway=speed_camera]' + poly_box,
		timeout: 120000,
		dataType: 'xml',
		success: this.OK_callback_set_radars.bind(this),
		error: this.KO_callback_set_radars.bind(this)
	});
}

WebAPI.prototype.OK_callback_set_radars = function(xml) {
	if (this.nav.get_route_status() != '2review' && this.nav.get_route_status() != 'yes')
		return;
	
	// For each radar...
	var aux_nav = this.nav;
	$(xml).find('node').each(function() {
		var xml_lat = parseFloat($(this).attr("lat"));
		var xml_lng = parseFloat($(this).attr("lon"));
		var xml_maxspeed = '!';
		$(this).find('tag').each(function(){
			if ($(this).attr("k") == 'maxspeed')
				xml_maxspeed = $(this).attr("v");
		});
		// Set radars for navigation
		aux_nav.set_radar(xml_lat, xml_lng, xml_maxspeed);
	});
	
	// Show them
	this.ui.markers_radar_set(this.nav.get_radars());
}

WebAPI.prototype.KO_callback_set_radars = function() {
	if (this.nav.get_route_status() != '2review' && this.nav.get_route_status() != 'yes')
		return;
	
	this.ui.play_sound(1);
	qml_show_notification('warning', 'speed_camera_error');
}
