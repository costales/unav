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

function Maths() {
}

Maths.prototype.M2KM = 0.001;
Maths.prototype.M2MI = 0.000621371192;
Maths.prototype.M2YD = 1.0936133;
Maths.prototype.MS2KMH = 3.6;
Maths.prototype.KMH2MIH = 0.62137119223733;
Maths.prototype.KM = 'km';


Maths.prototype._toRad = function(deg) {
	 return deg * Math.PI / 180;
}

Maths.prototype._toDeg = function(rad) {
	return rad * 180 / Math.PI;
}

// Angle for rotating map
Maths.prototype.get_angle = function(lat_from, lng_from, lat_to, lng_to) {
	var dLon = this._toRad(lng_to-lng_from);
	var y = Math.sin(dLon) * Math.cos(this._toRad(lat_to));
	var x = Math.cos(this._toRad(lat_from))*Math.sin(this._toRad(lat_to)) - Math.sin(this._toRad(lat_from))*Math.cos(this._toRad(lat_to))*Math.cos(dLon);
	var brng = this._toDeg(Math.atan2(y, x));
	var brng_final = (-brng + 360) % 360;
	return this._toRad(brng_final);
}

Maths.prototype.speed2human = function(ms) {
	if (ms !== null)
		return parseInt(ms * this.MS2KMH);
	else
		return 0;
}

Maths.prototype.get_speed = function(kmh, unit) {
	if (unit == this.KM)
		return kmh.toFixed(0) + 'km/h';
	else
		return (kmh * this.KMH2MIH).toFixed(0) + 'mi/h';
}

Maths.prototype.time2human = function(seconds, time_arrive) {
	if (time_arrive) { // Show final hour when you arrive
		var timeObject = new Date();
		timeObject = new Date(timeObject.getTime() + 1000*seconds);
		var m = (timeObject.getMinutes() < 10 ? "0" : "") + timeObject.getMinutes();
		return (timeObject.getHours() + ':' + m);
	}
	
	if (seconds > 0) { // Show hours:minutes to arrive
		var h = parseInt(seconds / 3600);
		var m = parseInt((seconds % 3600) / 60);
		if (h == 0)
			if (m > 0)
				return (m.toString() + "min");
			else
				return (" < 1min");
		else
			return (h.toString() + 'h' + m.toString() + 'min');
	}
}

Maths.prototype.dist2human = function(m, unit2convert) {
	var value = 0;
	var unit = '';
	
	if (unit2convert == this.KM) {
		if (m > 999) {
			value = parseInt(m * this.M2KM); // km
			unit = 'km';
		}
		else if (m > 949) { // Avoid round of 1000 m
			value = 1;
			unit = 'km';
		}
		else if (m > 600) {
			value = Math.round(m / 100) * 100;
			unit = 'm';
		}
		else if (m > 400) {
			value = Math.round(m / 50) * 50;
			unit = 'm';
		}
		else if (m > 200) {
			value = Math.round(m / 20) * 20;
			unit = 'm';
		}
		else if (m > 100) {
			value = Math.round(m / 10) * 10;
			unit = 'm';
		}
		else if (m > 50) {
			value = Math.round(m / 5) * 5;
			unit = 'm';
		}
		else {
			value = parseInt(m);
			unit = 'm';
		}
	}
	else {
		var yards = m * this.M2YD;
		
		if (yards > 1759) { // Avoid 0 mi
			value = parseInt(m * this.M2MI); // milles
			unit = 'mi';
		}
		else if (yards > 949) { // Avoid round 1000 yd
			value = 1;
			unit = 'mi';
		}
		else if (yards > 600) {
			value = Math.round(yards / 100) * 100;
			unit = 'yd';
		}
		else if (yards > 400) {
			value = Math.round(yards / 50) * 50;
			unit = 'yd';
		}
		else if (yards > 200) {
			value = Math.round(yards / 20) * 20;
			unit = 'yd';
		}
		else if (yards > 100) {
			value = Math.round(yards / 10) * 10;
			unit = 'yd';
		}
		else if (yards > 50) {
			value = Math.round(yards / 5) * 5;
			unit = 'yd';
		}
		else {
			value = parseInt(yards);
			unit = 'yd';
		}
	}
	
	return (String(value) + ' ' + unit);
}

Maths.prototype.decode = function(encoded, lat1st) {
	var precision = 5;
	var len = encoded.length,
		index=0,
		lat=0,
		lng = 0,
		array = [];

	precision = Math.pow(10, -precision);

	while (index < len) {
		var b,
			shift = 0,
			result = 0;
		do {
			b = encoded.charCodeAt(index++) - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		var dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = encoded.charCodeAt(index++) - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		var dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		if (lat1st)
			array.push( [parseFloat((lat * precision).toFixed(6)), parseFloat((lng * precision).toFixed(6))] );
		else
			array.push( [parseFloat((lng * precision).toFixed(6)), parseFloat((lat * precision).toFixed(6))] );
	}
	return array;
}
