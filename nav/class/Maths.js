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

Maths.prototype.MS2KMH = 3.6;

function Maths() {
}

Maths.prototype.meter2km = function(m) {
	return turf.convertLength(m, 'meters', 'kilometers');
}

Maths.prototype.meter2feet = function(m) {
	return turf.convertLength(m, 'meters', 'feet');
}

Maths.prototype.meter2mile = function(m) {
	return turf.convertLength(m, 'meters', 'miles');
}

Maths.prototype.km2mi = function(km) {
	if (km === null)
		return 0;
	return turf.convertLength(km, 'kilometers', 'miles');
}

Maths.prototype.deg2rad = function(degrees) {
	return turf.degreesToRadians(degrees);
}

Maths.prototype.rad2deg = function(radians) {
	return turf.radiansToDegrees(radians);
}

Maths.prototype.get_angle = function(rotate_map, long1, lat1, long2, lat2) {
	var angle = Math.trunc(turf.bearing(turf.point([long1, lat1]), turf.point([long2, lat2])));
	if (rotate_map)
		angle = (-angle + 360) % 360;
	return angle;
}

Maths.prototype.dist2human = function(m, unit2convert) {
	var distance_aux = ''
	if (unit2convert == settings.KM) {
		if (m > 5000) {
			return Math.trunc(this.meter2km(m)) + 'km';
		}
		if (m > 999) {
			distance_aux = this.meter2km(m).toFixed(1).toString();
			if (distance_aux.endsWith(".0"))
				 distance_aux = distance_aux.slice(0, -2);
			return distance_aux + 'km';
		}
		if (m > 0) {
			return Math.trunc(m) + 'm';
		}
		if (m == 0) {
			return t("Now").substring(0, 7);
		}
	}
	else {
		var miles = this.meter2mile(m).toFixed(1);
		if (miles > 3) {
			return Math.trunc(miles) + 'mi';
		}
		if (miles > 0.2) {
			distance_aux = miles.toString();
			if (distance_aux.endsWith(".0"))
				 distance_aux = distance_aux.slice(0, -2);
			return distance_aux + 'mi';
		}
		var feets = Math.trunc(this.meter2feet(m));
		if (feets > 0) {
			return feets + 'ft';
		}
		if (feets == 0) {
			return t("Now").substring(0, 7);
		}
	}
}

Maths.prototype.time2human = function(seconds, ETA) {
	var show_as_eta = ETA || false;
	if (show_as_eta) { // Show final hour when you arrive
		var timeObject = new Date();
		timeObject = new Date(timeObject.getTime() + 1000*seconds);
		var m = (timeObject.getMinutes() < 10 ? "0" : "") + timeObject.getMinutes();
		return (timeObject.getHours() + ':' + m);
	}
	
	if (seconds > 0) { // Show seconds as Xh:Ymin
		var h = Math.trunc(seconds / 3600);
		var m = Math.trunc((seconds % 3600) / 60);
		if (h == 0)
			if (m > 0)
				return (m.toString() + "min");
			else
				return ("< 1min");
		if (h > 0 && m == 0)
			return (h.toString() + 'h');
		return (h.toString() + 'h ' + m.toString() + 'min');
	}
}

Maths.prototype.speed2human = function(ms) {
	return Math.trunc(ms * this.MS2KMH);
}

Maths.prototype.decode_API_line = function(encoded) {
	var precision = 6;
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
		array.push( [lng * precision, lat * precision] );
	}

	return array;
}