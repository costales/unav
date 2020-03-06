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

function Settings() {
	this.sound = true;
	this.unit = this.KM;
	this.routing_mode = 0; // 0 car, 1 walk, 2 bike
	this.alert_radars = true;
	this.ui_speed = true;
}

Settings.prototype.KM = 'km';
Settings.prototype.MI = 'mi';


Settings.prototype.set_sound = function(value) {
	this.sound = value;
}

Settings.prototype.set_alert_radars = function(value) {
	this.alert_radars = value;
}

Settings.prototype.set_unit = function(value) {
	if (value == this.KM)
		this.unit = this.KM;
	else
		this.unit = this.MI;
}

Settings.prototype.set_routing_mode = function(value) {
	this.routing_mode = value;
}

Settings.prototype.get_sound = function() {
	return this.sound;
}

Settings.prototype.get_alert_radars = function() {
	return this.alert_radars;
}

Settings.prototype.get_unit = function() {
	return this.unit;
}

Settings.prototype.get_routing_mode = function() {
	return this.routing_mode;
}

Settings.prototype.set_ui_speed = function(value) {
	this.ui_speed = value;
}

Settings.prototype.get_ui_speed = function() {
	return this.ui_speed;
}
