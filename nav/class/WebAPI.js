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

function WebAPI() {
}

WebAPI.prototype.georeverse_online = function(lng, lat, touch_id) {
    $.ajax({
		url: 'https://photon.komoot.de/reverse',
		data: {
			lon: lng,
			lat: lat
		},
		dataType: 'json',
		timeout: 6000,
		success: function(data){ webapi.OK_georeverseOnline(data, touch_id) },
		error: this.KO_georeverseOnline.bind(this)
	});
}
WebAPI.prototype.OK_georeverseOnline = function(data, click_id) {
	if (longtouch_id != click_id)
		return;
	var nav_data = nav.get_data();
	if (nav_data.mode.startsWith("calculating"))
		return;
	if (data.features.length > 0) {
		title_aux = this.parse_georeverse(data.features[0].properties.name, data.features[0].properties.street, data.features[0].properties.housenumber);
		ui.POIPanel({msgShow: 'yes', msgAutohide: true, msgText: title_aux, iconsShow: 'auto'});
	}
}
WebAPI.prototype.KO_georeverseOnline = function(data) {
    // Nothing
}
WebAPI.prototype.parse_georeverse = function(name, street, housenumber) {
	var name_aux = name || '';
	var street_aux = street || '';
	var housenumber_aux = housenumber || '';

	if (name_aux)
		return name_aux;
	if (street_aux)
		if (housenumber_aux)
			return street_aux + ', ' + housenumber_aux;
		else
			return street_aux;
}

WebAPI.prototype.georeverse_offline = function(lng, lat, touch_id) {
    $.ajax({
		url: 'http://127.0.0.1:8553/v1/guide',
		data: {
			limit: 1,
			lng: lng,
			lat: lat,
			poitype: 'any'
		},
		dataType: 'json',
		timeout: 6000,
		success: function(data){ webapi.OK_georeverseOffline(data, touch_id) },
		error: this.KO_georeverseOffline.bind(this)
	});
}
WebAPI.prototype.OK_georeverseOffline = function(data, click_id) {
	if (longtouch_id != click_id)
		return;
	var nav_data = nav.get_data();
	if (nav_data.mode.startsWith("calculating"))
		return;
	if (data.results.length > 0) {
		var title_aux = data.results[0].title;
		if (title_aux.startsWith(" , ")) // Fix names as " , Xixon"
			title_aux = title_aux.slice(3, title_aux.length);
		if (title_aux)
			ui.POIPanel({msgShow: 'yes', msgAutohide: true, msgText: title_aux, iconsShow: 'auto'});
	}
}
WebAPI.prototype.KO_georeverseOffline = function(data) {
    // Nothing
}

WebAPI.prototype.POIsOffline = function(tag_poi, icon) {
	// Get radius from center to SW
    var extent = ol.proj.transformExtent(map.getView().calculateExtent(map.getSize()), map.getView().getProjection(), 'EPSG:4326');
    var center = ol.proj.transform(map.getView().getCenter(), map.getView().getProjection(), 'EPSG:4326'); 
	var dist_center2SW = Math.trunc(turf.distance(turf.point(center), turf.point([extent[0], extent[1]])) * 1000);
    $.ajax({
		url: 'http://localhost:8553/v1/guide',
		data: {
			radius: dist_center2SW,
			limit: 250,
			lng: ol.proj.transform(map.getView().getCenter(), 'EPSG:3857', 'EPSG:4326')[0],
			lat: ol.proj.transform(map.getView().getCenter(), 'EPSG:3857', 'EPSG:4326')[1],
			poitype: tag_poi
		},
		dataType: 'json',
		timeout: 10000,
		success: function(data){ webapi.OK_POIsOffline(data, icon) },
		error: this.KO_POIsOffline.bind(this)
	});
}
WebAPI.prototype.OK_POIsOffline = function(data, icon) {
	if (data.results.length > 0) {
		for (i = 0; i < data.results.length; i++) {
			var name = data.results[i].title || '';
			name = name.replace("'", "’");

			var phone = data.results[i].phone || '';
			phone = utils.parse_poi_phone(phone);
			var phone2 = data.results[i]['contact:phone'] || '';
			if (!phone && phone2) {
				phone = utils.parse_poi_phone(phone2);
			}

			var website = data.results[i].website || '';
			var website3 = data.results[i]['contact:facebook'] || '';
			var website2 = data.results[i]['contact:website'] || '';
			website = utils.parse_poi_url(website);
			if (!website && website2) {
				website = utils.parse_poi_url(website2);
			}
			if (!website && website3) {
				website = utils.parse_poi_url(website3);
			}

			var email = data.results[i].email || '';
			var email2 = data.results[i]['contact:email'] || '';
			if (!email && email2) {
				email = email2;
			}

			mapUI.add_marker([{
				name: 'poi-'+i, 
				title: data.results[i].title,
				phone: phone, 
				website: website, 
				email: email, 				
				lng: data.results[i].lng, 
				lat: data.results[i].lat,
				icon: 'poi-emblem/'+icon+'.svg',
				margin_height: 46, 
				margin_width: 15
			}], 'poi');
		}
		ui.POIPanel({msgShow: 'yes', msgAutohide: true, msgText: t("POIs loaded"), iconsShow: 'no'});
		ui.set_center_pos(false);
	}
	else {
		ui.POIPanel({msgShow: 'yes', msgAutohide: true, msgText: t("Not POIs found"), iconsShow: 'no'});
	}
}
WebAPI.prototype.KO_POIsOffline = function(data) {
	ui.POIPanel({msgShow: 'yes', msgAutohide: true, msgText: t("There was an error"), msgBGColor: 'error', iconsShow: 'no'});
}

WebAPI.prototype.POIsOnline = function(tag_poi, icon) {
	// https://wiki.openstreetmap.org/wiki/Overpass_API
	// https://towardsdatascience.com/loading-data-from-openstreetmap-with-python-and-the-overpass-api-513882a27fd0
	var coords = map.getView().calculateExtent(map.getSize());
	var coord1 = ol.proj.transform([coords[0], coords[1]], 'EPSG:3857', 'EPSG:4326');
	var coord2 = ol.proj.transform([coords[2], coords[3]], 'EPSG:3857', 'EPSG:4326');
	var url = 'https://lz4.overpass-api.de/api/interpreter?data=[out:json];node['+tag_poi+']('+coord1[1]+','+coord1[0]+','+coord2[1]+','+coord2[0]+');out 250;';
    $.ajax({
		url: url,
		dataType: 'json',
		timeout: 12000,
		success: function(data){ webapi.OK_POIsOnline(data, icon) },
		error: this.KO_POIsOnline.bind(this)
	});
}
WebAPI.prototype.OK_POIsOnline = function(data, icon) {
	if (data.elements.length > 0) {
		for (i = 0; i < data.elements.length; i++) {
			var name = data.elements[i].tags.name || '';
			name = name.replace("'", "’");

			var phone = data.elements[i].tags.phone || '';
			phone = utils.parse_poi_phone(phone);
			var phone2 = data.elements[i]['tags']['contact:phone'] || '';
			if (!phone && phone2) {
				phone = utils.parse_poi_phone(phone2);
			}

			var website = data.elements[i].tags.website || '';
			website = utils.parse_poi_url(website);
			var website2 = data.elements[i]['tags']['contact:website'] || '';
			if (!website && website2) {
				website = utils.parse_poi_url(website2);
			}
			var website3 = data.elements[i]['tags']['contact:facebook'] || '';
			if (!website && website3) {
				website = utils.parse_poi_url(website3);
			}

			var email = data.elements[i].tags.email || '';
			var email2 = data.elements[i]['tags']['contact:email'] || '';
			if (!email && email2) {
				email = email2;
			}

			mapUI.add_marker([{
				name: 'poi-'+data.elements[i].id, 
				title: name, 
				phone: phone, 
				website: website, 
				email: email, 
				lng: data.elements[i].lon, 
				lat: data.elements[i].lat, 
				icon: 'poi-emblem/'+icon+'.svg',
				margin_height: 46, 
				margin_width: 15
			}], 'poi');
		}
		ui.POIPanel({msgShow: 'yes', msgAutohide: true, msgText: t("POIs loaded"), iconsShow: 'no'});
		ui.set_center_pos(false);
	}
	else {
		ui.POIPanel({msgShow: 'yes', msgAutohide: true, msgText: t("Not POIs found"), iconsShow: 'no'});
	}
}
WebAPI.prototype.KO_POIsOnline = function(data) {
	ui.POIPanel({msgShow: 'yes', msgAutohide: true, msgText: t("There was an error"), msgBGColor: 'error', iconsShow: 'no'});
}

WebAPI.prototype.route_online = function(lng_from, lat_from, lng_to, lat_to) {
	switch (settings.get_route_mode()) {
		case 'car':
			var routing_mode = 'driving-car';
			break;
		case 'bike':
			var routing_mode = 'cycling-regular';
			break;
		case 'walk':
			var routing_mode = 'foot-walking';
			break;
	}
	$.ajax({
		url: 'https://api.openrouteservice.org/v2/directions/' + routing_mode,
		data: {
			api_key: '58d904a497c67e00015b45fca1a64e1896454ed08c81a552841363bc',
			start: lng_from + ',' + lat_from,
			end: lng_to + ',' + lat_to
		},
		dataType: 'json',
		timeout: 40000,
		success: this.OK_route_online.bind(this),
		error: this.KO_route_online.bind(this)
	});
}

WebAPI.prototype.OK_route_online = function(data) {
	if (data.hasOwnProperty('status') && data.status != 0) {
		if (nav.get_data().mode.startsWith('calculating'))
			nav.set_data({mode: 'calculating_error'});
		else
			nav.set_data({mode: 'route_out_calculating_error'});
	}
	else {
		nav.parse_data_online(data);
	}
}

WebAPI.prototype.KO_route_online = function(data) {
	if (nav.get_data().mode.startsWith('calculating'))
		nav.set_data({mode: 'calculating_error'});
	else
		nav.set_data({mode: 'route_out_calculating_error'});
}

WebAPI.prototype.route_offline = function(lng_from, lat_from, lng_to, lat_to) {
	switch (settings.get_route_mode()) {
		case 'car':
			var routing_mode = ',"costing":"auto"';
			break;
		case 'bike':
			var routing_mode = ',"costing":"bicycle"';
			break;
		case 'walk':
			var routing_mode = ',"costing":"pedestrian"';
			break;
	}
	$.ajax({
		url: 'http://localhost:8553/v2/route',
		data: {
			json: '{"locations":[{"lat":'+lat_from+',"lon":'+lng_from+'},{"lat":'+lat_to+',"lon":'+lng_to+'}]'+routing_mode+'}'
		},
		dataType: 'json',
		timeout: 40000,
		success: this.OK_route_offline.bind(this),
		error: this.KO_route_offline.bind(this)
	});
}

WebAPI.prototype.OK_route_offline = function(data) {
	if (data.trip.status != 0) {
		if (nav.get_data().mode.startsWith('calculating'))
			nav.set_data({mode: 'calculating_error'});
		else
			nav.set_data({mode: 'route_out_calculating_error'});
	}
	else {
		nav.parse_data_offline(data);
	}
}

WebAPI.prototype.KO_route_offline = function(data) {
	if (nav.get_data().mode.startsWith('calculating'))
		nav.set_data({mode: 'calculating_error'});
	else
		nav.set_data({mode: 'route_out_calculating_error'});
}
