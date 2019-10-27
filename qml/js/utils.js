/** used from geolib.js:
* Calculates the distance between two spots.
* This method is more simple but also far more inaccurate
*
* @param    object  Start position {latitude: 123, longitude: 123}
* @param    object  End position {latitude: 123, longitude: 123}
* @param    integer   Accuracy (in meters)
* @return   integer   Distance (in meters)
*/
function calcPoiDistance(cur_lat, cur_lng, poi_lat, poi_lng, accuracy) {
    if (cur_lat === null || cur_lng === null || cur_lat === 'null' || cur_lng === 'null')
        return null;

    accuracy = Math.floor(accuracy) || 1;
    var distance =
        Math.round(
            Math.acos(
                Math.sin(
                    poi_lat * Math.PI / 180
                ) *
                Math.sin(
                    cur_lat * Math.PI / 180
                ) +
                Math.cos(
                    poi_lat * Math.PI / 180
                ) *
                Math.cos(
                    cur_lat * Math.PI / 180
                ) *
                Math.cos(
                    (cur_lng - poi_lng) * Math.PI / 180
                )
            ) * 6378137 // Earth radius
        );
    return Math.floor(Math.round(distance/accuracy)*accuracy);
}

/**
* Function formatDistance(..): formats distance string
* dist: distance in m
* unit: 0...km
*       1...mi
**/
function formatDistance(dist, unit) {
    if (dist === null)
        return '';

    var m2km = 0.001
    var m2mi = 0.000621371192
    var m2yd = 1.0936133

    if ( unit === 1 ) // mi
        var distance = dist * m2yd < 1000 ? parseInt(dist * m2yd) + " yd" : parseInt(dist * m2mi) + "+ mi";
    else
        var distance = dist < 1000 ? parseInt(dist) + " m" : parseInt(dist * m2km) + "+ km" ;

    if (distance === '0 m' || distance === '0 yd')
        return i18n.tr("Current Location");
    else
        return distance;
}

/**
* Function getTranslators(): Return all Ubuntu translators
* translators: string with all translators
**/
function getTranslators(translators_string) {
    var all_translators = [];

    if (translators_string === '' || translators_string === 'translator-credits') {
        all_translators.push({
            name: "Ubuntu Translators Community",
            link: "https://translations.launchpad.net/+groups/ubuntu-translators"
        });
        return all_translators;
    }

    var translators = translators_string.split('\n');
    translators.forEach(function(translator) {
        if (translator.indexOf("https://launchpad.net") > -1 && translator.indexOf("costales https://launchpad.net/~costales") < 0) { // First string will be the header and don't include myself
            var translator_name = translator.split(' https://launchpad.net/~')[0].trim();
            var translator_link = 'https://launchpad.net/~' + translator.split('https://launchpad.net/~')[1];
            all_translators.push({
                name: translator_name,
                link: translator_link
            });
        }
    });

    return all_translators;
}

/**
* Function parse_poi_url(poi_website): Return string
* url: POI's URL
**/
function parse_poi_url(poi_website) {
    if (poi_website.trim() == '') // No website
        return '';

    if (poi_website.substring(0, 8) === "https://" || poi_website.substring(0, 7) === "http://")
        return poi_website;
    else
        return "http://" + poi_website;
}

/**
* Function parse_poi_phone(poi_phone): Return string
* url: POI's phone
**/
function parse_poi_phone(poi_phone) {
    if (poi_phone.trim() == '') // No phone
        return '';

    return poi_phone.replace(/ /g,''); // Removes all spaces
}

/**
* Function is_url_dispatcher(url): Return boolean
* url: URL calling uNav
**/
function is_url_dispatcher(url) {
    if (url.toString().indexOf('http://map.unav.me') > -1 || url.toString().indexOf('https://map.unav.me') > -1)
        return {is_dispatcher: true, url_is: 'unav'};
    if (url.toString().indexOf('geo:') > -1)
        return {is_dispatcher: true, url_is: 'geo'};
    if (url.toString().indexOf('http://unav-go.github.io') > -1)
        return {is_dispatcher: true, url_is: 'unavold'};
    if (url.toString().indexOf('http://www.openstreetmap.org') > -1 || url.toString().indexOf('https://www.openstreetmap.org') > -1)
        return {is_dispatcher: true, url_is: 'osm'};
    if (url.toString().indexOf('http://www.opencyclemap.org') > -1 || url.toString().indexOf('https://www.opencyclemap.org') > -1)
        return {is_dispatcher: true, url_is: 'ocm'};
    if (url.toString().indexOf('https://maps.google.com') > -1 || url.toString().indexOf('https://www.google.com/maps') > -1)
        return {is_dispatcher: true, url_is: 'googlemaps'};

    return {is_dispatcher: false, url_is: 'none'};
}

/**
* Function validate_lat(url): Return coordinate or null
**/
function validate_lat(lat) {
    try {
        if (!isNaN(lat) && lat.toString().indexOf('.') != -1 && lat >= -90 && lat <= 90) // It's a float
            return parseFloat(lat);
    }
    catch(e){
        return null;
    }
}
/**
* Function validate_lng(url): Return coordinate or null
**/
function validate_lng(lng) {
    try {
        if (!isNaN(lng) && lng.toString().indexOf('.') != -1 && lng >= -180 && lng <= 180) // It's a float
            return parseFloat(lng);
    }
    catch(e){
        return null;
    }
}

/**
* Function split_geo_url(url): Return coordenates
* url: URL calling uNav. ex: geo:37.786971,-122.399677 geo:51.5361,0.0084?z=16 geo:37.786971,-122.399677;u=35 geo:37.786971,-122.399677;crs=Moon-2011;u=35
**/
function split_geo_url(url) {
    var aux_url = url.replace('geo:', '').replace('?', ' ').replace(';', ' ').replace(',', ' ');

    var params = aux_url.split(' ');
    return {lat: validate_lat(params[0]), lng: validate_lng(params[1])};
}

/**
* Function split_unav_url(url): Return coordenates
* url: URL calling uNav. ex: http://unav.me/?map=51.4589,7.0072
**/
function split_unav_url(url) {
    var aux_url = url.replace('http://map.unav.me/?', '').replace('https://map.unav.me/?', '').replace('http://map.unav.me?', '').replace('https://map.unav.me?', '').replace('%2C', ',');

    var params = aux_url.split(',');
    return {lat: validate_lat(params[0]), lng: validate_lng(params[1])};
}

/**
* Function split_unavold_url(url): Return coordenates
* url: URL calling uNav. ex: http://unav-go.github.io/?p=51.4589,7.0072
**/
function split_unavold_url(url) {
    var aux_url = url.replace('http://unav-go.github.io/?p=', '').replace('http://unav-go.github.io?p=', '').replace('%2C', ',');

    var params = aux_url.split(',');
    return {lat: validate_lat(params[0]), lng: validate_lng(params[1])};
}

/**
* Function split_osm_url(url): Return coordenates
* url: URL calling OSM. ex: http://www.openstreetmap.org/#map=19/43.30257/-5.68930
*                           http://www.openstreetmap.org/?mlat=43.54217&mlon=-5.67633&zoom=12
**/
function split_osm_url(url) {
    var aux_url = url.replace('http://www.openstreetmap.org/#map=', '').replace('https://www.openstreetmap.org/#map=', '');

    var params = aux_url.split('/');

    if (params.length == 3)
        return {lat: validate_lat(params[1]), lng: validate_lng(params[2])};

    var aux_url = url.replace('http://www.openstreetmap.org/?', '').replace('https://www.openstreetmap.org/?', '');
    var params = aux_url.split('&');
    if (params.length >= 2 && params[0].indexOf('mlat') != 1 && params[1].indexOf('mlon') != 1)
        return {lat: validate_lat(params[0].replace('mlat=', '')), lng: validate_lng(params[1].replace('mlon=', ''))};

    return {lat: null, lng: null};
}

/**
* Function split_ocm_url(url): Return coordenates
* url: URL calling OpenCycleMap. ex: http://www.opencyclemap.org/?zoom=18&lat=43.5414&lon=-5.67165&layers=B0000
**/
function split_ocm_url(url) {
    var aux_url = url.replace('http://www.opencyclemap.org/?', '').replace('https://www.opencyclemap.org/?', '');

    var params = aux_url.split('&');
    if (params.length >= 3 && params[1].indexOf('lat') != 1 && params[2].indexOf('lon') != 1)
        return {lat: validate_lat(params[1].replace('lat=', '')), lng: validate_lng(params[2].replace('lon=', ''))};

    return {lat: null, lng: null};
}

/**
* Function split_googlemaps_url(url): Return coordenates
* url: URL calling Google Maps. ex: https://maps.google.com/?q=43.53291443249287,-5.664369592670359
* url: New URL format can be https://www.google.com/maps/place/[Terms of search]/@43.53291443249287,-5.664369592670359,17z/data=[more data]
**/
function split_googlemaps_url(url) {
    var aux_url = url.replace('https://maps.google.com/?q=', '').replace('%2C', ',');

    var params = aux_url.split(',');
    if (params.length == 2)
        return {lat: validate_lat(params[0]), lng: validate_lng(params[1])};

    var params = aux_url.slice(aux_url.indexOf("@") +1).split(",");
    if (params.length > 2)
        return {lat: validate_lat(params[0]), lng: validate_lng(params[1])};

    return {lat: null, lng: null};
}

/**
* Function get_url_coord(url): Return lat,lng
* url: URL calling uNav
**/
function get_url_coord(url) {
    var coord = {lat: null, lng: null};
    var dispatcher = is_url_dispatcher(url);

    if (!dispatcher['is_dispatcher']) // Validate
        return coord;

    switch (dispatcher['url_is']) {
        case 'unav':
            coord = split_unav_url(url);
            break;
        case 'geo':
            coord = split_geo_url(url);
            break;
        case 'unavold':
            coord = split_unavold_url(url);
            break;
        case 'osm':
            coord = split_osm_url(url);
            break;
        case 'ocm':
            coord = split_ocm_url(url);
            break;
        case 'googlemaps':
            coord = split_googlemaps_url(url);
            break;
    }
    return coord;
}
