/*
 * uNav https://github.com/costales/unav
 * Copyright (C) 2015 JkB https://launchpad.net/~joergberroth
 * Copyright (C) 2015 Marcos Alvarez Costales https://costales.github.io
 *
 * uNav is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * uNav is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */
// Thanks http://askubuntu.com/questions/352157/how-to-use-a-sqlite-database-from-qml


var db = null;

function openDB() {
	if (db === null) {
		db = LocalStorage.openDatabaseSync("unav_db", "0.1", "Favorites", 1000);
		db.transaction(function(tx){
			tx.executeSql('CREATE TABLE IF NOT EXISTS favorites( key TEXT UNIQUE, lat TEXT, lng TEXT)');
			tx.executeSql('CREATE TABLE IF NOT EXISTS poi_historial36( id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, label TEXT UNIQUE, tag_online TEXT, tag_offline TEXT, enabled_offline TEXT )');
		});
	}
}

function saveFavorite(name, lat, lng) {
	openDB();
	db.transaction( function(tx){
		tx.executeSql('INSERT OR REPLACE INTO favorites VALUES(?, ?, ?);', [name, lat, lng]);
	});
}

function removeFavorite(key) {
	openDB();
	db.transaction( function(tx){
		tx.executeSql('DELETE FROM favorites WHERE key=?;', [key]);
	});
}

function getFavorite(key) {
	var fav_lat = "";
	var fav_lng = "";
	openDB();
	db.transaction(function(tx) {
		var rs = tx.executeSql('SELECT lat,lng FROM favorites WHERE key=? ORDER BY key COLLATE NOCASE;', [key]);
		if (rs.rows.length > 0) {
			fav_lat = rs.rows.item(0).lat;
			fav_lng = rs.rows.item(0).lng;
		}
		else {
			fav_lat = null;
			fav_lng = null;
		}
	});
	return [fav_lat, fav_lng];
}

function getFavorites() {
	var res;
	openDB();
	db.transaction(function(tx) {
		res = tx.executeSql('SELECT * FROM favorites ORDER BY key COLLATE NOCASE;', []);
	});
	return res;
}

// nearByHistory
function saveToNearByHistory(label, tag_online, tag_offline, enabled_offline) {
	openDB();
	db.transaction( function(tx){
		tx.executeSql('INSERT OR REPLACE INTO poi_historial36(label, tag_online, tag_offline, enabled_offline) VALUES(?,?,?,?)', [label, tag_online, tag_offline, enabled_offline]);
		tx.executeSql('DELETE FROM poi_historial36 WHERE id IN (SELECT id FROM poi_historial36 ORDER BY id DESC LIMIT -1 OFFSET 5)'); // Keep only 5 last
	});
}

function getNearByHistory() {
	var res;
	openDB();
	db.transaction(function(tx) {
		res = tx.executeSql('SELECT * FROM poi_historial36 ORDER BY id DESC', []);
	});
	return res;
}
