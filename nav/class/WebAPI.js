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
				margin_height: 41, 
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
				margin_height: 41, 
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

WebAPI.prototype.route = function(online, lng_from, lat_from, lng_to, lat_to) {
	if (online)
		var url = 'https://route.stadiamaps.com/route';
	else
		var url = 'http://localhost:8553/v2/route';

	switch (settings.get_route_mode()) {
		case 'car':
			if (settings.get_tolls())
				var routing_mode = ',"costing":"auto"';
			else
				var routing_mode = ',"costing":"auto","costing_options":{"auto":{"use_tolls":0}}';
			break;
		case 'bike':
			var routing_mode = ',"costing":"bicycle"';
			break;
		case 'walk':
			var routing_mode = ',"costing":"pedestrian"';
			break;
	}
	var language = ',"directions_options":{"language":"'+navigator.language.split('-')[0].toLowerCase()+'"}';
	
	$.ajax({
		url: url,
		data: {
			api_key: 'ad841e2f-f657-4ffa-b5f8-9ae24b668ee8',
			json: '{"locations":[{"lat":'+lat_from+',"lon":'+lng_from+'},{"lat":'+lat_to+',"lon":'+lng_to+'}]'+routing_mode+language+'}'
		},
		dataType: 'json',
		timeout: 40000,
		success: this.OK_route.bind(this),
		error: this.KO_route.bind(this)
	});
}

WebAPI.prototype.OK_route = function(data) {
	if (data.trip.status != 0) {
		if (nav.get_data().mode.startsWith('calculating')) {
			if (nav.get_data().mode == 'calculating_simulating_call_API')
				nav.set_data({mode: 'calculating_simulating_error'});
			else
				nav.set_data({mode: 'calculating_error'});
			set_new_pos();
		}
		else {
			nav.set_data({mode: 'route_out_calculating_error'});
		}
	}
	else {
		nav.parse_data(data);
	}
}

WebAPI.prototype.KO_route = function(data) {
	if (nav.get_data().mode.startsWith('calculating')) {
		if (nav.get_data().mode == 'calculating_simulating_call_API')
			nav.set_data({mode: 'calculating_simulating_error'});
		else
			nav.set_data({mode: 'calculating_error'});
		set_new_pos();
	}
	else {
		nav.set_data({mode: 'route_out_calculating_error'});
	}
}

// Radars
WebAPI.prototype.set_radars = function() {
	// Clear current radars
	mapUI.clear_layer('radar');
	
	// Search radars?
	if (!settings.get_online_route() || settings.get_route_mode() != 'car' )
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

	//complete_line
	var coords = nav.get_data_line().points;
	var line = [];
	for (k=0; k<coords.length; k++)
		for (l=0; l<coords[k].length; l++)
			line.push(coords[k][l]);
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

	// Jump NaN values
	var routeBoundaryPolygon_1_aux = "";
	var routeBoundaryPolygon_2_aux = "";
	routeBoundaryPolygon_1.split(" ").forEach(function (item) {
		if (!isNaN(item))
			routeBoundaryPolygon_1_aux = routeBoundaryPolygon_1_aux + item + " ";
	});
	routeBoundaryPolygon_2.split(" ").forEach(function (item) {
		if (!isNaN(item))
			routeBoundaryPolygon_2_aux = routeBoundaryPolygon_2_aux + item + " ";
	});
	routeBoundaryPolygon_2_aux = routeBoundaryPolygon_2_aux.trim();

	// Search radars POI http://wiki.openstreetmap.org/wiki/Overpass_API
	var poly_box = '(poly:\"' + routeBoundaryPolygon_1_aux + routeBoundaryPolygon_2_aux + '\");out;'
	$.ajax({
		url: 'https://lz4.overpass-api.de/api/interpreter?data=node[highway=speed_camera]' + poly_box,
		timeout: 90000,
		dataType: 'xml',
		success: this.OK_callback_set_radars.bind(this),
		error: this.KO_callback_set_radars.bind(this)
	});
}

WebAPI.prototype.OK_callback_set_radars = function(xml) {
	if (nav.get_data().mode != 'drawing' && nav.get_data().mode != 'route_confirm' && nav.get_data().mode != 'route_driving')
		return;
	
	// For each radar...
	var radars_aux = [];
	const DIST_RADAR = 17;
	$(xml).find('node').each(function() {
		var xml_lng = parseFloat($(this).attr("lon"));
		var xml_lat = parseFloat($(this).attr("lat"));
		var xml_maxspeed = '!';
		$(this).find('tag').each(function(){
			if ($(this).attr("k") == 'maxspeed')
				xml_maxspeed = $(this).attr("v");
		});

		// Distance radar to route
		var line = nav.get_data_line();
		var pt_radar = turf.point([xml_lng, xml_lat]);
		var out_meters = 9999999;
		for (i=0; i < line.turf.length; i++) {
			var pt_near = turf.nearestPointOnLine(line.turf[i], pt_radar);
			if ((pt_near.properties.dist * 1000) < out_meters)
				out_meters = Math.trunc(pt_near.properties.dist * 1000);
			// Append radar and continue with next one
			if (out_meters < DIST_RADAR) {
				radars_aux.push({lng: xml_lng, lat: xml_lat, speed: xml_maxspeed});
				break;
			}
		}
	});

	if (radars_aux.length > 0)
		nav.set_radars(radars_aux);
	else
		ui.POIPanel({msgShow: 'yes', msgAutohide: true, msgText: t("No speed cameras"), iconsShow: 'no'});
}

WebAPI.prototype.KO_callback_set_radars = function() {
	if (nav.get_data().mode == 'drawing' || nav.get_data().mode == 'route_confirm' || nav.get_data().mode == 'route_driving')
		ui.POIPanel({msgShow: 'yes', msgAutohide: true, msgText: t("Error getting speed cameras"), iconsShow: 'no'});
}