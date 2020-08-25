function validate_lat(lat) {
    try {
        if (!isNaN(lat) && lat.toString().indexOf('.') != -1 && lat >= -90 && lat <= 90) // It's a float
            return parseFloat(lat);
    }
    catch(e){
        return null;
    }
}
function validate_lng(lng) {
    try {
        if (!isNaN(lng) && lng.toString().indexOf('.') != -1 && lng >= -180 && lng <= 180) // It's a float
            return parseFloat(lng);
    }
    catch(e){
        return null;
    }
}
function split_unav_url(url) {
    var aux_url = url.replace('https://map.unav.me/?', '').replace('https://map.unav.me?', '').replace('%2C', ',');
    var params = aux_url.split(',');
    return {lng: validate_lng(params[1]), lat: validate_lat(params[0])};
}
function split_geo_url(url) {
    var aux_url = url.replace('geo:', '').replace('?', ' ').replace(';', ' ').replace(',', ' ');
    var params = aux_url.split(' ');
    return {lng: validate_lng(params[1]), lat: validate_lat(params[0])};
}
function get_url_coord(url_shared) {
    var url = url_shared.toLowerCase();
    if (url.startsWith("https://map.unav.me")) {
        return split_unav_url(url);
    }
    if (url.startsWith("geo:")) {
        return split_geo_url(url);
    }
    return {lng: null, lat: null};
}

