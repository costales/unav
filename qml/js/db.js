/*
 * uNav http://launchpad.net/unav
 * Copyright (C) 2015 JkB https://launchpad.net/~joergberroth
 * Copyright (C) 2015 Marcos Alvarez Costales https://launchpad.net/~costales
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
	db = LocalStorage.openDatabaseSync("unav_db", "0.1", "Favorites and history", 1000);
	db.transaction(function(tx){
			tx.executeSql('CREATE TABLE IF NOT EXISTS favorites( key TEXT UNIQUE, lat TEXT, lng TEXT)');
			tx.executeSql('CREATE TABLE IF NOT EXISTS nearByHistory( id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, type TEXT UNIQUE, clause TEXT )');
			tx.executeSql('CREATE TABLE IF NOT EXISTS favHistory( id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, key TEXT UNIQUE, lat TEXT, lng TEXT )');
			tx.executeSql('CREATE TABLE IF NOT EXISTS searchHistory( id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, key TEXT UNIQUE, lat TEXT, lng TEXT )');
			tx.executeSql('CREATE TABLE IF NOT EXISTS  Car_poiQuickAccess( type TEXT UNIQUE, clause TEXT, distance TEXT )');
			tx.executeSql('CREATE TABLE IF NOT EXISTS Bike_poiQuickAccess( type TEXT UNIQUE, clause TEXT, distance TEXT )');
			tx.executeSql('CREATE TABLE IF NOT EXISTS Walk_poiQuickAccess( type TEXT UNIQUE, clause TEXT, distance TEXT )');
		});
	}
}

// Favorites
function saveFavorite(key, lat, lng) {
	openDB();
	db.transaction( function(tx){
		tx.executeSql('INSERT OR REPLACE INTO favorites VALUES(?, ?, ?)', [key, parseFloat(lat).toFixed(7).toString(), parseFloat(lng).toFixed(7).toString()]);
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

// favHistory
function saveTofavHistory(key, lat, lng) {
	openDB();
	db.transaction( function(tx){
		tx.executeSql('INSERT OR REPLACE INTO favHistory(key, lat, lng) VALUES(?,?,?)', [key, parseFloat(lat).toFixed(7).toString(), parseFloat(lng).toFixed(7).toString()]);
		tx.executeSql('DELETE FROM favHistory WHERE id IN (SELECT id FROM favHistory ORDER BY id DESC LIMIT -1 OFFSET 3)'); // Keep last 3
	});
}

function getfavHistory() {
	var res;
	openDB();
	db.transaction(function(tx) {
		res = tx.executeSql('SELECT * FROM favHistory ORDER BY id DESC', []);
	});
	return res;
}

function removeHistoryFavorite(key) {

	openDB();
	db.transaction( function(tx){
		tx.executeSql('DELETE FROM favHistory WHERE key=?;', [key]);
	});
}


// searchHistory
function saveToSearchHistory(key, lat, lng) {
	openDB();
	db.transaction( function(tx){
		tx.executeSql('INSERT OR REPLACE INTO searchHistory(key, lat, lng) VALUES(?,?,?)', [key, parseFloat(lat).toFixed(7).toString(), parseFloat(lng).toFixed(7).toString()]);
		tx.executeSql('DELETE FROM searchHistory WHERE id IN (SELECT id FROM searchHistory ORDER BY id DESC LIMIT -1 OFFSET 5)'); // Keep last 5
	});
}

function getSearchHistory() {
	var res;
	openDB();
	db.transaction(function(tx) {
		res = tx.executeSql('SELECT * FROM searchHistory ORDER BY id DESC', []);
	});
	return res;
}

function removeHistorySearch(key) {
	openDB();
	db.transaction( function(tx){
		tx.executeSql('DELETE FROM searchHistory WHERE key=?;', [key]);
	});
}

// nearByHistory
function saveToNearByHistory(type, clause) {
	openDB();
	db.transaction( function(tx){
		tx.executeSql('INSERT OR REPLACE INTO nearByHistory(type, clause) VALUES(?,?)', [type, clause]);
		tx.executeSql('DELETE FROM nearByHistory WHERE id IN (SELECT id FROM nearByHistory ORDER BY id DESC LIMIT -1 OFFSET 3)'); // Keep only 3 last
	});
}

function getNearByHistory() {
	var res;
	openDB();
	db.transaction(function(tx) {
		res = tx.executeSql('SELECT * FROM nearByHistory ORDER BY id DESC', []);
	});
	return res;
}

function removeHistoryNearby(key) {
	openDB();
	db.transaction( function(tx){
		tx.executeSql('DELETE FROM nearByHistory WHERE type=?;', [key]);
	});
}

// QuickAccess Storage
function saveToQuickAccessItem(mode, type, clause, distance) {
	openDB();
	db.transaction( function(tx){
		tx.executeSql('INSERT OR REPLACE INTO ' + mode +'_poiQuickAccess(type, clause, distance) VALUES(?,?,?)', [type, clause, distance]);
	});
}

function getQuickAccessItems(mode) {
	var res;
	openDB();
	db.transaction( function(tx) {
		res = tx.executeSql('SELECT * FROM ' + mode +'_poiQuickAccess', []);
	});
	return res;
}

function countQuickAccessItems(mode) {
	var res;
	openDB();
	db.transaction( function(tx) {
		res = tx.executeSql('SELECT COUNT(*) AS count FROM ' + mode +'_poiQuickAccess', []);
	});
	return res;
}

function removeQuickAccessItem(mode, key) {
	openDB();
	db.transaction( function(tx){
		tx.executeSql('DELETE FROM ' + mode +'_poiQuickAccess WHERE type=?;', [key]);
	});
}

// delete historytables
function dropHistoryTables() {
	openDB();
	db.transaction(function(tx){
		tx.executeSql('DELETE FROM favHistory;');
		tx.executeSql('DELETE FROM searchHistory;');
		tx.executeSql('DELETE FROM nearByHistory;');
	});
}
