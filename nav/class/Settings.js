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

Settings.prototype.KM = 'km';
Settings.prototype.MI = 'mi';

function Settings() {
	this.online = true
	this.unit = this.KM;
	this.rotate_map = true;
	this.route_tolls = true;
	this.route_highways = true;
	this.speak = true;
	this.speak_voice = "Nathan Haines";
	this.route_mode = "car";
}

Settings.prototype.get_online = function() {
	return this.online;
}
Settings.prototype.set_online = function(value, first_running) {
	var first_run = first_running || false;
	this.online = value;

	if (first_run && !value) // With map offline, call 2 times here and breaks switch layers
		return;
	
	// Remove all layers except someones, then append the right
	try {
		map.getLayers().forEach(function(layer) {
			switch(layer.get('name')) {
				case 'poi':
				case 'route':
				case 'gpx':
				case 'pos':
					break;
				default:
					map.removeLayer(layer);
			}
		});
	} catch (error) {}
	
	if (this.online) {
		map.addLayer(map_layer_online);
		$('#mapCredits').text("© OpenStreetMap contributors © CARTO");
	}
	else {
		if (this.route_mode == "car")
			olms.apply(map, 'http://localhost:8553/v1/mbgl/style?style=osmbright-car'); // Shows gas stations for car
		else
			olms.apply(map, 'http://localhost:8553/v1/mbgl/style?style=osmbright');
		$('#mapCredits').text("© OpenStreetMap contributors © OSM Scout Server");
	}
}

Settings.prototype.get_unit = function() {
	return this.unit;
}
Settings.prototype.set_unit = function(value) {
	switch(value) {
		case 0:
			this.unit = this.KM;
			scale_line.setUnits('metric');
			break;
		case 1:
			this.unit = this.MI;
			scale_line.setUnits('us');
			break;
	}
}

Settings.prototype.get_rotate_map = function() {
	return this.rotate_map;
}
Settings.prototype.set_rotate_map = function(value) {
	this.rotate_map = value;
	mapUI.set_marker_rotate(0);
	mapUI.set_map_rotate(0);
}

Settings.prototype.get_speak = function() {
	return this.speak;
}
Settings.prototype.set_speak = function(value) {
	this.speak = value;
}

Settings.prototype.get_speak_voice = function() {
	return this.speak_voice;
}
Settings.prototype.set_speak_voice = function(value) {
	this.speak_voice = value;
}

Settings.prototype.get_route_mode = function() {
	return this.route_mode;
}
Settings.prototype.set_route_mode = function(value) {
	var previous_route_mode = this.route_mode;

	switch(value) {
		case 0:
			this.route_mode = 'car';
			break;
		case 1:
			this.route_mode = 'bike';
			break;
		case 2:
			this.route_mode = 'walk';
			break;
	}

	if (!this.online && (previous_route_mode == 'car' || value == 0))
		this.set_online(this.online); // Force refresh map set map type when change from/to car

	var nav_data = nav.get_data();
    switch(nav_data.mode) {
	    case 'calculating_call_API':
	    case 'calculating_waiting_result':
	    case 'drawing':
	    case 'route_confirm':
	    case 'route_driving':
	    case 'route_out':
	    case 'route_out_returned':
	    case 'route_out_waiting_result':
	    case 'route_out_calculating_error':
	    case 'route_out_drawing':
			BtnGo(nav_data.lng_end, nav_data.lat_end);
	}
}

