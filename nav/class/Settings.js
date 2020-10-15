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

Settings.prototype.KM = 'km';
Settings.prototype.MI = 'mi';

function Settings() {
    this.online_map = true
    this.online_search = true
    this.online_route = true
    this.unit = this.KM;
    this.rotate_map = true;
    this.tolls = true;
    this.radars = false;
    this.speak = true;
    this.speak_voice = "Nathan Haines";
    this.route_mode = "car";
}

Settings.prototype.get_online_map = function() {
    return this.online_map;
}
Settings.prototype.set_online_map = function(value) {
    this.online_map = value;

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
    
    if (this.online_map) {
        map.addLayer(map_layer_online);
        $('#mapCredits').text("© OpenStreetMap contributors © CARTO");
    }
    else {
        olms.apply(map, 'http://localhost:8553/v1/mbgl/style?style=osmbright');
        $('#mapCredits').text("© OpenStreetMap contributors © OSM Scout Server");
    }
}

Settings.prototype.get_online_search = function() {
    return this.online_search;
}
Settings.prototype.set_online_search = function(value) {
    this.online_search = value;
}

Settings.prototype.get_online_route = function() {
    return this.online_route;
}
Settings.prototype.set_online_route = function(value) {
    this.online_route = value;
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

Settings.prototype.get_tolls = function() {
    return this.tolls;
}
Settings.prototype.set_tolls = function(value) {
    this.tolls = value;
}

Settings.prototype.get_radars = function() {
    return this.radars;
}
Settings.prototype.set_radars = function(value) {
    this.radars = value;
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
    this.route_mode = value;
}

