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

function Utils() {
}

Utils.prototype.parse_poi_url = function(poi_website) {
    if (poi_website.trim() == '') // No website
		return '';
	var web = poi_website.replace(/ /g,'');
    if (web.substring(0, 8) === "https://" || web.substring(0, 7) === "http://")
        return web;
    else
        return "https://" + web;
}

Utils.prototype.parse_poi_phone = function(poi_phone) {
    if (poi_phone.trim() == '') // No phone
        return '';
    return poi_phone.replace(/ /g,''); // Removes all spaces
}

Utils.prototype.fix_lng = function(lng) { // Fix bug openLayers #4522
    var lng_aux = lng;
    while(lng_aux > 180)
        lng_aux-=360; 
    while(lng_aux < -180)
        lng_aux+=360;
    return lng_aux;
}
