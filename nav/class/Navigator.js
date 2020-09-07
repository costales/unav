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

Navigator.prototype.IS_IN_ROUTE = 70;
Navigator.prototype.DIST4INDICATION = 100;
Navigator.prototype.CITY = 58;
Navigator.prototype.HIGHWAY = 80;
Navigator.prototype.HIGHSPEED = 100;

function Navigator() {
	this.pos = new Object();
		this.pos.lng = null;
		this.pos.lat = null;
		this.pos.accuracy = null;
		this.pos.speed = null;
	
	this.pos_prev = new Object();
		this.pos_prev.lng = null;
		this.pos_prev.lat = null;
		
	this.pos_start = new Object();
		this.pos_start.lng = null;
		this.pos_start.lat = null;
		
	this.pos_end = new Object();
		this.pos_end.lng = null;
		this.pos_end.lat = null;
		
	this.mode = 'exploring';

	this.route = new Object();
		this.route.ind = 0;
		this.route.distance = null;
		this.route.duration = null;
		this.route.percentage = 0;
		this.route.distance_total = 0;
		this.route.steps = []; // type + instruction + name + distance + time
		this.route.points = [];
		this.route.bbox = [];
		this.route.turf = [];
}

Navigator.prototype.set_data = function(data) {
	if ('undefined' !== typeof data.mode)
		this.mode = data.mode;
		
	if ('undefined' !== typeof data.lng) {
		this.pos_prev.lng = this.pos.lng;
		this.pos.lng = data.lng;
	}
	
	if ('undefined' !== typeof data.lat) {
		this.pos_prev.lat = this.pos.lat;
		this.pos.lat = data.lat;
	}
	
	if ('undefined' !== typeof data.accuracy)
		this.pos.accuracy = Math.trunc(data.accuracy);
		
	if ('undefined' !== typeof data.speed)
		this.pos.speed = maths.speed2human(data.speed);
		
	if ('undefined' !== typeof data.lng_start)
		this.pos_start.lng = data.lng_start;
		
	if ('undefined' !== typeof data.lat_start)
		this.pos_start.lat = data.lat_start;
		
	if ('undefined' !== typeof data.lng_end)
		this.pos_end.lng = data.lng_end;
		
	if ('undefined' !== typeof data.lat_end)
		this.pos_end.lat = data.lat_end;
}

Navigator.prototype.get_data = function() {
	return {
		mode: this.mode,

		lng: this.pos.lng,
		lat: this.pos.lat,
		accuracy: this.pos.accuracy,
		speed: this.pos.speed,

		lng_prev: this.pos_prev.lng,
		lat_prev: this.pos_prev.lat,
		
		lng_start: this.pos_start.lng,
		lat_start: this.pos_start.lat,
		lng_end: this.pos_end.lng,
		lat_end: this.pos_end.lat
	};
}

Navigator.prototype.get_data_navigation = function() {
	return {
		ind: this.route.ind,
		distance: this.route.distance,
		duration: this.route.duration,
		percentage: this.route.percentage,
		steps: this.route.steps
	};
}

Navigator.prototype.get_data_line = function() {
	return {
		bbox: this.route.bbox,
		points: this.route.points,
		turf: this.route.turf
	}
}

Navigator.prototype.parse_type_online = function(step) {
	// 0 Left
	// 1 Right
	// 2 Sharp left
	// 3 Sharp right
	// 4 Slight left
	// 5 Slight right
	// 6 Straight
	// 70 Enter roundabout
	//   71 exit number 1
	//   72 exit number 2
	//   73 exit number 3
	//   74 exit number 4
	// 8 Exit roundabout (without voice)
	// 9 U-turn
	// 10 Goal
	// 11 Depart
	// 12 Keep left
	// 13 Keep right
	// 99 Nothing (without voice)
	var type_aux = step.type;
	if (type_aux == 7)
		switch(step.exit_number) {
			case 1:
				type_aux = 71;
				break;
			case 2:
				type_aux = 72;
				break;
			case 3:
				type_aux = 73;
				break;
			case 4:
				type_aux = 74;
				break;
			default:
				type_aux = 70;
		}
	return type_aux;
}

Navigator.prototype.parse_type_offline = function(step) {
	// Convert valhalla types to openrouteservice types for using same voices and steps. Review kBecomes
	switch(step.type) {
		case 15: // kLeft
			return 0; // Left
		case 10: // kRight
			return 1; // Right
		case 14: // kSharpLeft
			return 2; // Sharp left
		case 11: // kSharpRight 
			return 3; // Sharp right
		case 16: // kSlightLeft
		case 21: // kExitLeft
		case 19: // kRampLeft
			return 4; // Slight left
		case 9: // kSlightRight
		case 20: // kExitRight
		case 18: // kRampRight
			return 5; // Slight right
		case 8: // kContinue
		case 17: // kRampStraight
		case 22: // kStayStraight
		case 25: // kMerge
		case 7: // kBecomes
			return 6; // Straight
		case 26: // kRoundaboutEnter
			switch(step.roundabout_exit_count) {
				case 1:
					return 71; // Roundabout exit 1
				case 2:
					return 72; // Roundabout exit 2
				case 3:
					return 73; // Roundabout exit 3
				case 4:
					return 74; // Roundabout exit 4
				default:
					return 70; // Roundabout
			}
		case 27: // kRoundaboutExit
			return 8; // Exit roundabout
		case 12: // kUturnRight
		case 13: // kUturnLeft
			return 9; // U-turn
		case 4: // kDestination
		case 5: // kDestinationRight
		case 6: // kDestinationLeft
			return 10; // Goal
		case 1: // kStart
		case 2: // kStartRight
		case 3: // kStartLeft
			return 11; // Depart
		case 24: // kStayLeft
			return 12; // Keep left
		case 23: // kStayRight
			return 13; // Keep right
		case 0: //kNone
		case 28: // kFerryEnter
		case 29: // kFerryExit
		case 30: // kTransit
		case 31: // kTransitTransfer
		case 32: // kTransitRemainOn
		case 33: // kTransitConnectionStart
		case 34: // kTransitConnectionTransfer
		case 35: // kTransitConnectionDestination
		case 36: // kPostTransitConnectionDestination
			return 99; // Review the map > Beep
		default:
			return 99; // Review the map > Beep
	}
}

Navigator.prototype.parse_name = function(type, name) {
	switch(type) {
		case 10:
			return t("Your destination is near");
		case 70:
			return t("Enter the roundabout");
		case 71:
			return t("Enter the roundabout and take 1st exit");
		case 72:
			return t("Enter the roundabout and take 2nd exit");
		case 73:
			return t("Enter the roundabout and take 3th exit");
		case 74:
			return t("Enter the roundabout and take 4th exit");
		case 99:
			return t("Follow the route line");
		case 8:
			if (name)
				return t("Exit at") + " " + name;
			else
				return t("Exit the roundabout");
		default:
			return name;
	}
}

Navigator.prototype.parse_data_online = function(data) {
	this.route.ind = 0;
	this.route.distance = parseInt(data.features[0].properties.summary.distance);
	this.route.distance_total = this.route.distance;
	this.route.duration = parseInt(data.features[0].properties.summary.duration);
	this.route.percentage = 0;

	this.route.bbox = [];
	this.route.points = [];
	this.route.turf = [];

	for (i=0; i<(data.bbox.length); i=i+2)
		this.route.bbox.push([data.bbox[i], data.bbox[i+1]]);
	
	this.route.steps = [];
	for (i=0; i<data.features[0].properties.segments[0].steps.length; i++) { // For each step
		var points_aux = [];
		for (j=0; j<data.features[0].properties.segments[0].steps[i].way_points.length-1; j++) { // Get all way points
			var ind_aux = data.features[0].properties.segments[0].steps[i].way_points[j];
			while (ind_aux <= data.features[0].properties.segments[0].steps[i].way_points[j+1]) {
				points_aux.push(data.features[0].geometry.coordinates[ind_aux]);
				ind_aux++;
			}
		}
		if (points_aux.length < 2)
			points_aux.push(points_aux[0]);
		this.route.points.push(points_aux);
		this.route.turf.push(turf.lineString(points_aux));
		var type_parsed = this.parse_type_online(data.features[0].properties.segments[0].steps[i]);
		var name_parsed = this.parse_name(type_parsed, data.features[0].properties.segments[0].steps[i].name);
		this.route.steps.push({
			type: type_parsed,
			name: name_parsed,
			instruction: data.features[0].properties.segments[0].steps[i].instruction,
			distance: parseInt(data.features[0].properties.segments[0].steps[i].distance),
			distance_step: parseInt(data.features[0].properties.segments[0].steps[i].distance),
			duration: parseInt(data.features[0].properties.segments[0].steps[i].duration),
			duration_step: parseInt(data.features[0].properties.segments[0].steps[i].duration),
			speaked: 0
		});
	}
	if (nav.get_data().mode.startsWith('calculating'))
		nav.set_data({mode: 'drawing'});
	else
		nav.set_data({mode: 'route_out_drawing'});
}

Navigator.prototype.parse_data_offline = function(data) {
	this.route.ind = 0;
	this.route.duration = parseInt(data.trip.summary.time);
	this.route.distance = parseInt(data.trip.summary.length);
	this.route.distance_total = this.route.distance;
	this.route.percentage = 0;

	this.route.bbox = [];
	this.route.points = [];
	this.route.turf = [];

	this.route.bbox.push([data.trip.summary.min_lon, data.trip.summary.min_lat], [data.trip.summary.max_lon, data.trip.summary.max_lat]);
	
	this.route.steps = [];
	var coords_aux = maths.decode_API_line(data.trip.legs[0].shape);
	for (i=0; i<data.trip.legs[0].maneuvers.length; i++) { // For each step
		var points_aux = [];
		var ind_aux = data.trip.legs[0].maneuvers[i].begin_shape_index;
		while (ind_aux <= data.trip.legs[0].maneuvers[i].end_shape_index) { // Get all way points
			points_aux.push(coords_aux[ind_aux]);
			ind_aux++;
		}
		if (points_aux.length < 2)
			points_aux.push(points_aux[0]);
		this.route.points.push(points_aux);
		this.route.turf.push(turf.lineString(points_aux));
		var type_parsed = this.parse_type_offline(data.trip.legs[0].maneuvers[i]);
		var name = "";
		if (data.trip.legs[0].maneuvers[i].hasOwnProperty('street_names'))
			name = data.trip.legs[0].maneuvers[i].street_names[0];
		var name_parsed = this.parse_name(type_parsed, name);
		this.route.steps.push({
			type: type_parsed,
			name: name_parsed, // Name could be empty, then use instruction
			instruction: data.trip.legs[0].maneuvers[i].instruction,
			distance: parseInt(data.trip.legs[0].maneuvers[i].length),
			distance_step: parseInt(data.trip.legs[0].maneuvers[i].length),
			duration: parseInt(data.trip.legs[0].maneuvers[i].time),
			duration_step: parseInt(data.trip.legs[0].maneuvers[i].time),
			speaked: 0
		});
	}
	if (nav.get_data().mode.startsWith('calculating'))
		nav.set_data({mode: 'drawing'});
	else
		nav.set_data({mode: 'route_out_drawing'});
}

Navigator.prototype.update = function() {
	// Nearest point to the route lines
	var out_meters = 999999999;
	var nearest_point = null;
	var pt_now = turf.point([this.pos.lng, this.pos.lat]);
	for (i=0; i < this.route.turf.length; i++) {
		var pt_near = turf.nearestPointOnLine(this.route.turf[i], pt_now);
		if ((pt_near.properties.dist * 1000) < out_meters) {
			this.route.ind = i;
			out_meters = Math.trunc(pt_near.properties.dist * 1000);
			nearest_point = pt_near.geometry.coordinates;
		}
	}

	// From nearest point to end of current step
	pt_near = turf.point(nearest_point);
	var pt_end_of_step = turf.point(this.route.points[this.route.ind][this.route.points[this.route.ind].length-1]);
	var distance_to_end_of_step = Math.trunc(turf.distance(pt_near, pt_end_of_step) * 1000);

	// Get percentage of route done and update values
	var percentage_step_remain = Math.trunc((distance_to_end_of_step * 100) / this.route.steps[this.route.ind].distance_step);
	this.route.steps[this.route.ind].distance = distance_to_end_of_step;
	this.route.distance = distance_to_end_of_step;
	this.route.duration = Math.trunc((this.route.steps[this.route.ind].duration_step * percentage_step_remain) / 100);
	for (i=this.route.ind+1; i<this.route.steps.length; i++) {
		this.route.distance = this.route.distance + this.route.steps[i].distance_step;
		this.route.duration = this.route.duration + this.route.steps[i].duration_step;
	}
	this.route.percentage = Math.trunc(100 - ((this.route.distance * 100) / this.route.distance_total));

	// On route?
	if (out_meters > this.IS_IN_ROUTE)
		if (nav.get_data().mode.startsWith('route_driving'))
			nav.set_data({mode: 'route_out'});
	else // Return to the route
		if (nav.get_data().mode.startsWith('route_out'))
			nav.set_data({mode: 'route_out_returned'});

	// Calculate distance to end of step for end of route and speak depeding of speed and mode route
	switch(settings.get_route_mode()) {
		case 'car':
			var speak4speed = 1.1;
			if (this.pos.speed > this.CITY)
				speak4speed = 3;
			if (this.pos.speed > this.HIGHWAY)
				speak4speed = 5;
			if (this.pos.speed > this.HIGHSPEED)
				speak4speed = 7;
			break;
		case 'bike':
			var speak4speed = 0.75;
			break;
		case 'walk':
			var speak4speed = 0.40;
			break;
	}
	var dist4indication_aux = this.DIST4INDICATION * speak4speed;

	// Speak?
	if (this.route.steps[this.route.ind].speaked == 1) // Disable if speaked previously
		this.route.steps[this.route.ind].speaked = 2;
	
	if (this.route.steps[this.route.ind].speaked == 0 && distance_to_end_of_step < dist4indication_aux) {
		this.route.steps[this.route.ind].speaked = 1;
	}

	// End of route?
	if (this.route.steps[this.route.ind+1].type == 10 && distance_to_end_of_step < dist4indication_aux) {
		nav.set_data({mode: 'route_end'});
		if (this.route.steps[this.route.ind].speaked == 0)
			this.route.steps[this.route.ind].speaked = 1;
	}
}