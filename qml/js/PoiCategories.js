// http://wiki.openstreetmap.org/wiki/Nominatim/Special_Phrases/EN
// https://rinigus.github.io/osmscout-server/tags/tag2alias_en.html
var groups = [
	{
		label: i18n.tr("Transport"),
		elements: [
			{label: "Airport", translators: i18n.tr("Airport"), tag_online: "aeroway=aerodrome", tag_offline: "aeroway_aerodrome"},
			{label: "Bicycle Shop", translators: i18n.tr("Bicycle Shop"), tag_online: "shop=bicycle", tag_offline: "shop_bicycle"},
			{label: "Bus Station", translators: i18n.tr("Bus Station"), tag_online: "amenity=bus_station", tag_offline: "amenity_bus_station"},
			{label: "Car Rental", translators: i18n.tr("Car Rental"), tag_online: "amenity=car_rental", tag_offline: "amenity_car_rental"},
			{label: "Car Repair", translators: i18n.tr("Car Repair"), tag_online: "shop=car_repair", tag_offline: "shop_car_repair"},
			{label: "Car Wash", translators: i18n.tr("Car Wash"), tag_online: "amenity=car_wash", tag_offline: "amenity_car_wash"},
			{label: "Charging Station", translators: i18n.tr("Charging Station"), tag_online: "amenity=charging_station", tag_offline: "amenity_charging_station"},
			{label: "Gas Station", translators: i18n.tr("Gas Station"), tag_online: "amenity=fuel", tag_offline: "amenity_fuel"},
			{label: "Parking", translators: i18n.tr("Parking"), tag_online: "amenity=parking", tag_offline: "amenity_parking"},
			{label: "Subway Entrance", translators: i18n.tr("Subway Entrance"), tag_online: "railway=subway_entrance", tag_offline: "railway_subway_entrance"},
			{label: "Taxi", translators: i18n.tr("Taxi"), tag_online: "amenity=taxi", tag_offline: "amenity_taxi"},
			{label: "Train Station", translators: i18n.tr("Train Station"), tag_online: "building=train_station", tag_offline: "building_train_station"}
		]
	},
	{
		label: i18n.tr("Accommodation"),
		elements: [
			{label: "Campsite", translators: i18n.tr("Campsite"), tag_online: "tourism=camp_site", tag_offline: "tourism_camp_site"},
			{label: "Caravan Site", translators: i18n.tr("Caravan Site"), tag_online: "tourism=caravan_site", tag_offline: "tourism_caravan_site"},
			{label: "Guest House", translators: i18n.tr("Guest House"), tag_online: "tourism=guest_house", tag_offline: "tourism_guest_house"},
			{label: "Hostel", translators: i18n.tr("Hostel"), tag_online: "tourism=hostel", tag_offline: "tourism_hostel"},
			{label: "Hotel", translators: i18n.tr("Hotel"), tag_online: "tourism=hotel", tag_offline: "tourism_hotel"},
			{label: "Motel", translators: i18n.tr("Motel"), tag_online: "tourism=motel", tag_offline: "tourism_motel"}
		]
	},
	{
		label: i18n.tr("Food & Drink"),
		elements: [
			{label: "Bar", translators: i18n.tr("Bar"), tag_online: "amenity=bar", tag_offline: "amenity_bar"},
			{label: "Cafe", translators: i18n.tr("Cafe"), tag_online: "amenity=cafe", tag_offline: "amenity_cafe"},
			{label: "Drinking Water", translators: i18n.tr("Drinking Water"), tag_online: "amenity=drinking_water", tag_offline: "amenity_drinking_water"},
			{label: "Fast Food", translators: i18n.tr("Fast Food"), tag_online: "amenity=fast_food", tag_offline: "amenity_fast_food"},
			{label: "Ice Cream", translators: i18n.tr("Ice Cream"), tag_online: "amenity=ice_cream", tag_offline: "amenity_ice_cream"},
			{label: "Pub", translators: i18n.tr("Pub"), tag_online: "amenity=pub", tag_offline: "amenity_pub"},
			{label: "Restaurant", translators: i18n.tr("Restaurant"), tag_online: "amenity=restaurant", tag_offline: "amenity_restaurant"}
		]
	},
	{
		label: i18n.tr("Tourism"),
		elements: [
			{label: "Museum", translators: i18n.tr("Museum"), tag_online: "tourism=museum", tag_offline: "tourism_museum"},
			{label: "Tourism Information", translators: i18n.tr("Tourism Information"), tag_online: "tourism=information	", tag_offline: "tourism_information"},
			{label: "Town Hall", translators: i18n.tr("Town Hall"), tag_online: "amenity=townhall", tag_offline: "amenity_townhall"}
		]
	},
	{
		label: i18n.tr("Services"),
		elements: [
			{label: "ATM", translators: i18n.tr("ATM"), tag_online: "amenity=atm", tag_offline: "amenity_atm"},
			{label: "Bank", translators: i18n.tr("Bank"), tag_online: "amenity=bank", tag_offline: "amenity_bank"},
			{label: "Bureau de Change", translators: i18n.tr("Bureau de Change"), tag_online: "amenity=bureau_de_change", tag_offline: "amenity_bureau_de_change"},
			{label: "Post Box", translators: i18n.tr("Post Box"), tag_online: "amenity=post_box", tag_offline: "amenity_post_box"},
			{label: "Post Office", translators: i18n.tr("Post Office"), tag_online: "amenity=post_office", tag_offline: "amenity_post_office"},
			{label: "Toilet", translators: i18n.tr("Toilet"), tag_online: "amenity=toilets", tag_offline: "amenity_toilets"}
		]
	},
	{
		label: i18n.tr("Shopping"),
		elements: [
			{label: "Books", translators: i18n.tr("Books"), tag_online: "shop=books", tag_offline: "shop_books"},
			{label: "Computer Shop", translators: i18n.tr("Computer Shop"), tag_online: "shop=computer", tag_offline: "shop_computer"},
			{label: "Copy Shop", translators: i18n.tr("Copy Shop"), tag_online: "shop=copyshop", tag_offline: "shop_copyshop"},
			{label: "Florist", translators: i18n.tr("Florist"), tag_online: "shop=florist", tag_offline: "shop_florist"},
			{label: "Gifts", translators: i18n.tr("Gifts"), tag_online: "shop=gift", tag_offline: "shop_gift"},
			{label: "Kiosk", translators: i18n.tr("Kiosk"), tag_online: "shop=kiosk", tag_offline: "shop_kiosk"},
			{label: "Laundry", translators: i18n.tr("Laundry"), tag_online: "shop=laundry", tag_offline: "shop_laundry"},
			{label: "Mall", translators: i18n.tr("Mall"), tag_online: "shop=mall", tag_offline: "shop_mall"},
			{label: "Mobile Phone", translators: i18n.tr("Mobile Phone"), tag_online: "shop=mobile_phone", tag_offline: "shop_mobile_phone"},
			{label: "Optician", translators: i18n.tr("Optician"), tag_online: "shop=optician", tag_offline: "shop_optician"},
			{label: "Supermarket", translators: i18n.tr("Supermarket"), tag_online: "shop=supermarket", tag_offline: "shop_supermarket"},
			{label: "Travel Agency", translators: i18n.tr("Travel Agency"), tag_online: "shop=travel_agency", tag_offline: "shop_travel_agency"}
		]
	},
	{
		label: i18n.tr("Culture"),
		elements: [
			{label: "Arts Centre", translators: i18n.tr("Arts Centre"), tag_online: "amenity=arts_centre", tag_offline: "amenity_arts_centre"},
			{label: "Library", translators: i18n.tr("Library"), tag_online: "amenity=library", tag_offline: "amenity_library"},
			{label: "Museum", translators: i18n.tr("Museum"), tag_online: "tourism=museum", tag_offline: "tourism_museum"},
			{label: "Theatre", translators: i18n.tr("Theatre"), tag_online: "amenity=theatre", tag_offline: "amenity_theatre"}
		]
	},
	{
		label: i18n.tr("Entertainment"),
		elements: [
			{label: "Casino", translators: i18n.tr("Casino"), tag_online: "amenity=casino", tag_offline: "amenity_casino"},
			{label: "Cinema", translators: i18n.tr("Cinema"), tag_online: "amenity=cinema", tag_offline: "amenity_cinema"}
		]
	},
	{
		label: i18n.tr("Education"),
		elements: [
			{label: "School", translators: i18n.tr("School"), tag_online: "amenity=school", tag_offline: "amenity_school"},
			{label: "University", translators: i18n.tr("University"), tag_online: "amenity=university", tag_offline: "amenity_university"}
		]
	},
	{
		label: i18n.tr("Health"),
		elements: [
			{label: "Dentist", translators: i18n.tr("Dentist"), tag_online: "amenity=dentist", tag_offline: "amenity_dentist"},
			{label: "Doctor", translators: i18n.tr("Doctor"), tag_online: "amenity=doctors", tag_offline: "amenity_doctors"},
			{label: "Hospital", translators: i18n.tr("Hospital"), tag_online: "amenity=hospital", tag_offline: "amenity_hospital"},
			{label: "Pharmacy", translators: i18n.tr("Pharmacy"), tag_online: "amenity=pharmacy", tag_offline: "amenity_pharmacy"},
			{label: "Veterinary", translators: i18n.tr("Veterinary"), tag_online: "amenity=veterinary", tag_offline: "amenity_veterinary"}
		]
	},
	{
		label: i18n.tr("Religious"),
		elements: [
			{label: "Cemetery", translators: i18n.tr("Cemetery"), tag_online: "landuse=cemetery", tag_offline: "landuse_cemetery"},
			{label: "Church", translators: i18n.tr("Church"), tag_online: "building=church", tag_offline: "amenity_place_of_worship"}
		]
	},
	{
		label: i18n.tr("Emergency"),
		elements: [
			{label: "Police Station", translators: i18n.tr("Police Station"), tag_online: "amenity=police", tag_offline: "amenity_police"}
		]
	},
	{
		label: i18n.tr("Sport"),
		elements: [
			{label: "Gym", translators: i18n.tr("Gym"), tag_online: "leisure=fitness_centre", tag_offline: "amenity_gym"},
			{label: "Sports Centre", translators: i18n.tr("Sports Centre"), tag_online: "leisure=sports_centre", tag_offline: "leisure_sports_centre"},
			{label: "Stadium", translators: i18n.tr("Stadium"), tag_online: "leisure=stadium", tag_offline: "building_stadium"},
			{label: "Swimming Pool", translators: i18n.tr("Swimming Pool"), tag_online: "leisure=swimming_pool", tag_offline: "leisure_swimming_pool"}
		]
	}
];

var data = function () {
	var d = [], e;
	groups.forEach(function (group) {
		group.elements.forEach(function (e) {
			e.theme = group.label;
			d.push(e);
		});
	});
	return d;
}();
