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

function Navigator(maths, lang_root) {
	this.maths = maths;
	this.lang_root = lang_root.toLowerCase();
	
	this.pos_now = new Object();
		this.pos_now['lat'] = null;
		this.pos_now['lng'] = null;
	
	this.pos_start = new Object();
		this.pos_start['lat'] = null;
		this.pos_start['lng'] = null;
	
	this.pos_end = new Object();
		this.pos_end['lat'] = null;
		this.pos_end['lng'] = null;
	
	this.accuracy = this.ACCU4DRIVE + 1;
	this.speed = null;
	
	this.route = new Object();
		this.route['start_check_out'] = false;
		this.route['status'] = 'no'; // no | errorAPI | waiting4signal | calc | drawing | 2review | yes | out | ended
		this.route['total'] = {
			distance: 0,
			time: 0
		}
		this.route['track'] = {
			ind: 0,
			total: 0,
			percent: 100
		};
		this.route['tracks'] = [];
		this.route['turf'] = null;
		this.route['radars'] = [];

	this.nearest = new Object();
		this.nearest['indication'] = '1';
		this.nearest['dist2turn'] = 0;
		this.nearest['msg'] = '';
		this.nearest['distance'] = 0;
		this.nearest['dist_track_done'] = 0;
		this.nearest['distance_total'] = 0;
		this.nearest['time'] = 0;
		this.nearest['voice'] = false;
		this.nearest['speaked'] = false;
		this.nearest['radar'] = false;
		this.nearest['radar_sound'] = false;
		this.nearest['radar_speed'] = '!';
}

Navigator.prototype.ACCU4DRIVE = 250;
Navigator.prototype.IS_IN_ROUTE = 55;
Navigator.prototype.MAX_START_CHECK_OUT = 250;
Navigator.prototype.DIST4INDICATION = 99; // Never > 99 for preserve voices
Navigator.prototype.SPEED_CITY = 62;
Navigator.prototype.SPEED_INTERCITY = 85;
Navigator.prototype.DIST_RADAR_IN_ROUTE = 32;
Navigator.prototype.NUM_RADARS_MAX = 100;


Navigator.prototype.set_gps_data = function(lat, lng, accu, speed) {
	if (lat === null || lng === null)
		return;
	
	this.pos_now['lat'] = parseFloat(lat.toFixed(5));
	this.pos_now['lng'] = parseFloat(lng.toFixed(5));
	this.accuracy = parseInt(accu);
	this.speed = this.maths.speed2human(speed);
}

Navigator.prototype.get_pos_data = function() {
	return {
		now_lat:	this.pos_now['lat'],
		now_lng:	this.pos_now['lng'],
		start_lat:	this.pos_start['lat'],
		start_lng:	this.pos_start['lng'],
		end_lat:	this.pos_end['lat'],
		end_lng:	this.pos_end['lng'],
		accu:		this.accuracy, 
		speed:		this.speed
	};
}

Navigator.prototype.radars_clear = function() {
	this.route['radars'] = [];
}

Navigator.prototype.set_radar = function(lat, lng, speed) {
	var dist2line = 0;
	var pt_radar = turf.point([lng, lat]);
	var pt_near = turf.pointOnLine(this.route['complete_line'], pt_radar);
	
	dist2line = geolib.getDistance(
		{latitude: lat, longitude: lng},
		{latitude: pt_near.geometry.coordinates[1], longitude: pt_near.geometry.coordinates[0]}
	);
	
	if (dist2line <= this.DIST_RADAR_IN_ROUTE && this.route['radars'].length <= this.NUM_RADARS_MAX) { // Add radar
		this.route['radars'].push({
			lat: lat,
			lng: lng,
			speed: speed,
			alerted: false
		});
	}
}

Navigator.prototype.get_radars = function () {
	return this.route['radars'];
}

Navigator.prototype.compose_instruction_simple = function(type, street_name) {
	// Initial instructions
	switch (type) {
		case 0: // Left
			return t("Turn left");
		case 1: // Right
			return t("Turn right");
		case 2: // Sharp left
			return t("Make a sharp left");
		case 3: // Sharp right
			return t("Make a sharp right");
		case 4: // Slight left
			return t("Bear left");
		case 5: // Slight right
			return t("Bear right");
		case 6: // Straight
			return t("Continue on the road");
		case 70: // Roundabouts
			return t("Enter the roundabout and take the designated exit");
		case 71:
			return t("Enter the roundabout and take the first exit");
		case 72:
			return t("Enter the roundabout and take the second exit");
		case 73:
			return t("Enter the roundabout and take the third exit");
		case 74:
			return t("Enter the roundabout and take the fourth exit");
		case 75:
			return t("Enter the roundabout and take the fifth exit");
		case 77:
			return t("Enter the roundabout and take the sixth exit");
		case 77:
			return t("Enter the roundabout and take the seventh exit");
		case 78:
			return t("Enter the roundabout and take the eighth exit");
		case 79:
			return t("Enter the roundabout and take the ninth exit");
		case 9:  // U-turn
			return t("Make a U-turn");
		case 10: // Goal
			return t("You have arrived at your destination");
		case 11: // Unknown (probably start)
			return street_name
		case 12: // Keep left
			return t("Keep left");
		case 13: // Keep right
			return t("Keep right");
	}
}

Navigator.prototype.get_route_tracks = function() {
	return nav.route['tracks'];
}

Navigator.prototype.get_route_line = function() {
	return this.route['line'];
}

Navigator.prototype.get_route_indication = function() {
	var voice_tmp = this.nearest['voice'];
	if (voice_tmp) // Need because ended will call here several times
		this.nearest['voice'] = false;
	
	return {
		indication:			this.nearest['indication'],
		dist2turn:			this.nearest['dist2turn'],
		msg:				this.nearest['msg'],
		time:				this.nearest['time'],
		distance:			this.nearest['distance'],
		dist_track_done:	this.nearest['dist_track_done'],
		distance_total:		this.nearest['distance_total'],
		speed:				this.speed,
		voice:				voice_tmp,
		speaked:			this.nearest['speaked'],
		radar:				this.nearest['radar'],
		radar_sound:		this.nearest['radar_sound'],
		radar_speed:		this.nearest['radar_speed']
	};
}

Navigator.prototype.set_route = function(total_m, total_s, line_encoded, tracks) {
	// Set cycle route
	this.route['status'] = 'drawing';
	
	// Total
	this.nearest['distance_total'] = Math.round(total_m);
	this.nearest['time'] = Math.round(total_s);
	
	// For draw line
	this.route['start_check_out'] = false;
	this.route['line'] = this.maths.decode(line_encoded, false);
	
	// Set new start/end points for markers
	var coords = this.maths.decode(line_encoded, true);
	
	this.pos_start['lat'] = coords[0][0];
	this.pos_start['lng'] = coords[0][1];
	this.pos_end['lat'] = coords[(coords.length)-1][0];
	this.pos_end['lng'] = coords[(coords.length)-1][1];
	
	// All tracks
	this.route['tracks'] = [];
	this.route['turf'] = [];
	this.route['complete_line'] = {
		"type": "Feature",
		"properties": {},
		"geometry": {
			"type": "LineString",
			"coordinates": this.route['line']
		}
	};
	
	var instruction = '';
	var i_next = 0;
	
	// Hack API: Several continues on the road
	var i = 0;
	while (i < tracks.length) {
		if (tracks[i].type == 6 && tracks[(i+1)].type == 6) {
			tracks[i].distance = tracks[i].distance + tracks[(i+1)].distance;
			tracks[i].duration = tracks[i].duration + tracks[(i+1)].duration;
			tracks[i].way_points[1] = tracks[(i+1)].way_points[1];
			tracks.splice((i+1), 1);
		}
		else {
			i = i + 1;
		}
	}


	for (i=0; i < (tracks.length-1); i++) {
		i_next = i + 1;
		
		// Hack roundabouts
		if (tracks[i_next].type == 7) { // Enter roundabout
			switch (tracks[i_next].exit_number) {
				case 1:
					tracks[i_next].type = 71;
					break;
				case 2:
					tracks[i_next].type = 72;
					break;
				case 3:
					tracks[i_next].type = 73;
					break;
				case 4:
					tracks[i_next].type = 74;
					break;
				case 5:
					tracks[i_next].type = 75;
					break;
				case 6:
					tracks[i_next].type = 76;
					break;
				case 7:
					tracks[i_next].type = 77;
					break;
				case 8:
					tracks[i_next].type = 78;
					break;
				case 9:
					tracks[i_next].type = 79;
					break;
				default:
					tracks[i_next].type = 70;
			}
		}
		if (tracks[i_next].type == 8) { // Exit roundabout
			if (i > 0)
				tracks[i_next].type = tracks[i-1].type
			else
				tracks[i_next].type = 70;
		}
		
		// Compose instruction
		try {var street_name = tracks[i_next].name;} catch (err) {var street_name = '';}
		instruction = this.compose_instruction_simple(
			tracks[i_next].type,
			street_name
		);
		// Turn indications
		this.route['tracks'].push({
			type: tracks[i_next].type,
			coordinates: [coords[tracks[i].way_points[1]][1], coords[tracks[i].way_points[1]][0]], // End of each track (lng,lat)
			instruction: instruction,
			distance: Math.round(tracks[i].distance),
			duration: Math.round(tracks[i].duration),
			speaked: false
		});
		/** TESTING BEGIN **/
		console.log("http://map.unav.me/?"+coords[tracks[i].way_points[1]][0]+","+coords[tracks[i].way_points[1]][1]);
		/** TESTING END **/
	}
	
	// Check Inside + near point
	for (i=0; i < (tracks.length); i++) {
		var turf_line = [];
		for (i_coord = tracks[i].way_points[0]; i_coord <= tracks[i].way_points[1]; i_coord++) {
			turf_line.push([coords[i_coord][1], coords[i_coord][0]]); // lng,lat
		}
		this.route['turf'].push(turf.linestring(turf_line));
	}
	/** TESTING BEGIN **/
	console.log(JSON.stringify(this.route['tracks']));
	/** TESTING END **/
}

Navigator.prototype.update = function() {
	if (this.route['status'] != 'yes' && this.route['status'] != 'out' && this.route['status'] != 'calc_from_out' && this.route['status'] != 'calculating_from_out')
		return
	
	var dist2line = 0;
	var pt_now = null;
	var pt_near = null;
	this.nearest['distance'] = 0;
	this.nearest['dist_track_done'] = 0;
	this.nearest['distance_total'] = 0;
	this.nearest['time'] = 0;
	this.nearest['voice'] = false;
	this.nearest['speaked'] = false;
	this.nearest['radar'] = false;
	this.nearest['radar_sound'] = false;
	
	// DISTANCES pos to route lines
	var all_distances = [];
	for (i=0; i < this.route['turf'].length-1; i++) { // -1 because the last is special with 0 meters & same positions and returns NaN
		pt_now = turf.point([this.pos_now['lng'], this.pos_now['lat']]);
		pt_near = turf.pointOnLine(this.route['turf'][i], pt_now);
		dist2line = geolib.getDistance(
			{latitude: this.pos_now['lat'], longitude: this.pos_now['lng']},
			{latitude: pt_near.geometry.coordinates[1], longitude: pt_near.geometry.coordinates[0]}
		);
		all_distances.push(dist2line);
	}
	var ind_nearest = all_distances.indexOf(Math.min.apply(Math, all_distances));
	
	// STORE the nearest
	this.nearest['indication'] = this.route['tracks'][ind_nearest]['type'];
	this.nearest['msg'] = this.route['tracks'][ind_nearest]['instruction'];
	this.nearest['dist2turn'] = geolib.getDistance(
		{latitude: this.pos_now['lat'], longitude: this.pos_now['lng']},
		{latitude: this.route['tracks'][ind_nearest]['coordinates'][1], longitude: this.route['tracks'][ind_nearest]['coordinates'][0]}
	);
	this.nearest['dist_track_done'] = this.route['tracks'][ind_nearest]['distance'] - this.nearest['dist2turn'];
	
	// Speak now?
	if (!this.route['tracks'][ind_nearest]['speaked']) {
		var dist2speed = this.DIST4INDICATION;
		if (this.speed > this.SPEED_CITY)
			dist2speed = this.DIST4INDICATION * 3;
		if (this.speed > this.SPEED_INTERCITY)
			dist2speed = this.DIST4INDICATION * 6;
		
		if (this.nearest['dist2turn'] < dist2speed) {
			this.route['tracks'][ind_nearest]['speaked'] = true;
			this.nearest['voice'] = true;
			this.nearest['speaked'] = true;
		}
	}
	else {
		this.nearest['speaked'] = true;
	}
	
	// Total distance + time
	for (i=ind_nearest; i < this.route['tracks'].length; i++) {
		if (i == ind_nearest) { // Percent left
			var percent_completed = ((this.route['tracks'][i]['distance'] - this.nearest['dist2turn']) / this.route['tracks'][i]['distance']) * 100;
			this.nearest['time'] = this.route['tracks'][i]['duration'] - Math.abs(this.route['tracks'][i]['duration'] * percent_completed / 100);
			this.nearest['distance'] = this.route['tracks'][i]['distance'] - Math.abs(this.route['tracks'][i]['distance'] * percent_completed / 100);
			this.nearest['distance_total'] = this.nearest['distance'];
		}
		else {
			this.nearest['time'] += this.route['tracks'][i]['duration'];
			this.nearest['distance'] += this.route['tracks'][i]['distance'];
			this.nearest['distance_total'] += this.route['tracks'][i]['distance'];
		}
	}

	// RADARS
	var dist_radar_nearest = 9999;
	var ind_radar_nearest = -1;
	var dist2radar = this.DIST4INDICATION;
	if (this.speed > this.SPEED_CITY)
		dist2radar = this.DIST4INDICATION * 3;
	// Get nearest
	for (i=0; i<this.route['radars'].length; i++) {
		// Is it near?
		var dist_radar = geolib.getDistance(
			{latitude: this.pos_now['lat'], longitude: this.pos_now['lng']},
			{latitude: this.route['radars'][i]['lat'], longitude: this.route['radars'][i]['lng']}
		);
		if (dist_radar <= dist2radar && dist_radar < dist_radar_nearest) {
			ind_radar_nearest = i;
			dist_radar_nearest = dist_radar;
		}
	}
	// Alert nearest?
	if (ind_radar_nearest !== -1) {
		this.nearest['radar'] = true;
		this.nearest['radar_speed'] = this.route['radars'][ind_radar_nearest]['speed'];
		if (!this.route['radars'][ind_radar_nearest]['alerted']) {
			this.route['radars'][ind_radar_nearest]['alerted'] = true;
			this.nearest['radar_sound'] = true;
		}
	}



	// UPDATE STATUS
	// On route?
	if (all_distances[ind_nearest] <= this.IS_IN_ROUTE) {
		this.route['start_check_out'] = true;
		this.set_route_status('yes');
	}
	else if ((this.route['start_check_out'] || all_distances[ind_nearest] > this.MAX_START_CHECK_OUT) && (nav.get_route_status() != 'calc_from_out' && nav.get_route_status() != 'calculating_from_out')) {
		this.set_route_status('out');
		return;
	}
	
	// Ended? //TODO speaker you have arrive at your destination
	if (this.route['tracks'][ind_nearest]['type'] == 10 && this.nearest['dist2turn'] < (this.DIST4INDICATION/2)) {
		this.set_route_status('ended');
		return;
	}
}

Navigator.prototype.set_route_status = function(status) {
	this.route['status'] = status;
}

Navigator.prototype.get_route_status = function() {
	return this.route['status'];
}

Navigator.prototype.calc2coord = function(lat, lng) {
	this.set_route_status('waiting4signal');
	
	this.pos_start['lat'] = this.pos_now['lat'];
	this.pos_start['lng'] = this.pos_now['lng'];
	this.pos_end['lat'] = lat;
	this.pos_end['lng'] = lng;

	this.nearest['dist2turn'] = 0;
}

Navigator.prototype.cancel_route = function() {
	this.set_route_status('no');
	
	this.pos_start['lat'] = null;
	this.pos_start['lng'] = null;
	this.pos_end['lat'] = null;
	this.pos_end['lng'] = null;
}
