// http://wiki.openstreetmap.org/wiki/Nominatim/Special_Phrases/EN
var groups = [
	{
		label: i18n.tr("Transport"),
		elements: [
			{en_label: "Airport", label: i18n.tr("Airport"), clause: "Airports"},
			{en_label: "Bicycle Parking", label: i18n.tr("Bicycle Parking"), clause: "Cycle Parkings"},
			{en_label: "Bicycle Rental", label: i18n.tr("Bicycle Rental"), clause: "Cycle Rentals"},
			{en_label: "Bicycle Shop", label: i18n.tr("Bicycle Shop"), clause: "Bicycle Shops"},
			{en_label: "Bus Station", label: i18n.tr("Bus Station"), clause: "Bus Stations"},
			{en_label: "Bus Stop", label: i18n.tr("Bus Stop"), clause: "Bus Stops"},
			{en_label: "Car Rental", label: i18n.tr("Car Rental"), clause: "Car Rentals"},
			{en_label: "Car Repair", label: i18n.tr("Car Repair"), clause: "Car Repairs"},
			{en_label: "Car Wash", label: i18n.tr("Car Wash"), clause: "Car Washes"},
			{en_label: "Ferry Terminal", label: i18n.tr("Ferry Terminal"), clause: "Ferry Terminals"},
			{en_label: "Gas Station", label: i18n.tr("Gas Station"), clause: "Fuel Stations"},
			{en_label: "Motorcycle Shop", label: i18n.tr("Motorcycle Shop"), clause: "Motorcycle Shops"},
			{en_label: "Parking", label: i18n.tr("Parking"), clause: "Parking"},
			{en_label: "Subway Entrance", label: i18n.tr("Subway Entrance"), clause: "Subway Entrances"},
			{en_label: "Taxi", label: i18n.tr("Taxi"), clause: "Taxis"},
			{en_label: "Train Station", label: i18n.tr("Train Station"), clause: "Train Stations"}
		]
	},
	{
		label: i18n.tr("Accommodation"),
		elements: [
			{en_label: "Bed and Breakfasts", label: i18n.tr("Bed and Breakfasts"), clause: "Bed and Breakfasts"},
			{en_label: "Campsite", label: i18n.tr("Campsite"), clause: "Camp Sites"},
			{en_label: "Caravan Site", label: i18n.tr("Caravan Site"), clause: "Caravan Sites"},
			{en_label: "Guest House", label: i18n.tr("Guest House"), clause: "Guest Houses"},
			{en_label: "Hostel", label: i18n.tr("Hostel"), clause: "Hostels"},
			{en_label: "Hotel", label: i18n.tr("Hotel"), clause: "Hotels"},
			{en_label: "Motel", label: i18n.tr("Motel"), clause: "Motels"}
		]
	},
	{
		label: i18n.tr("Food & Drink"),
		elements: [
			{en_label: "Bakery", label: i18n.tr("Bakery"), clause: "Bakeries"},
			{en_label: "Bar", label: i18n.tr("Bar"), clause: "Bars"},
			{en_label: "Butcher", label: i18n.tr("Butcher"), clause: "Butchers"},
			{en_label: "Cafe", label: i18n.tr("Cafe"), clause: "Cafes"},
			{en_label: "Convenience Store", label: i18n.tr("Convenience Store"), clause: "Convenience Stores"},
			{en_label: "Drinking water", label: i18n.tr("Drinking water"), clause: "Drinking Water"},
			{en_label: "Fast Food", label: i18n.tr("Fast Food"), clause: "Fast Food"},
			{en_label: "Ice Cream", label: i18n.tr("Ice Cream"), clause: "Ice Cream"},
			{en_label: "Picnic Site", label: i18n.tr("Picnic Site"), clause: "Picnic Sites"},
			{en_label: "Pub", label: i18n.tr("Pub"), clause: "Pubs"},
			{en_label: "Restaurant", label: i18n.tr("Restaurant"), clause: "Restaurants"}
		]
	},
	{
		label: i18n.tr("Tourism"),
		elements: [
			{en_label: "Alpine Hut", label: i18n.tr("Alpine Hut"), clause: "Alpine Huts"},
			{en_label: "Archaeological Site", label: i18n.tr("Archaeological Site"), clause: "Archaeological Sites"},
			{en_label: "Artwork", label: i18n.tr("Artwork"), clause: "Artworks"},
			{en_label: "Attraction", label: i18n.tr("Attraction"), clause: "Attractions"},
			{en_label: "Battlefield", label: i18n.tr("Battlefield"), clause: "Battlefields"},
			{en_label: "Castle", label: i18n.tr("Castle"), clause: "Castles"},
			{en_label: "Monument", label: i18n.tr("Monument"), clause: "Monuments"},
			{en_label: "Museum", label: i18n.tr("Museum"), clause: "Museums"},
			{en_label: "Nature Reserve", label: i18n.tr("Nature Reserve"), clause: "Nature Reserves"},
			{en_label: "Picnic Site", label: i18n.tr("Picnic Site"), clause: "Picnic Sites"},
			{en_label: "Ruin", label: i18n.tr("Ruin"), clause: "Ruins"},
			{en_label: "Theme Park", label: i18n.tr("Theme Park"), clause: "Theme Parks"},
			{en_label: "Tourism Information", label: i18n.tr("Tourism Information"), clause: "Informations"},
			{en_label: "Town Hall", label: i18n.tr("Town Hall"), clause: "Town Halls"},
			{en_label: "Viewpoint", label: i18n.tr("Viewpoint"), clause: "Viewpoints"},
			{en_label: "Zoo", label: i18n.tr("Zoo"), clause: "Zoos"}
		]
	},
	{
		label: i18n.tr("Services"),
		elements: [
			{en_label: "ATM", label: i18n.tr("ATM"), clause: "ATMs"},
			{en_label: "Bank", label: i18n.tr("Bank"), clause: "Banks"},
			{en_label: "Bureau de change", label: i18n.tr("Bureau de change"), clause: "Bureaus de Change"},
			{en_label: "Place of Worship", label: i18n.tr("Place of Worship"), clause: "Places of Worship"},
			{en_label: "Post Box", label: i18n.tr("Post Box"), clause: "Post Boxes"},
			{en_label: "Post Office", label: i18n.tr("Post Office"), clause: "Post Offices"},
			{en_label: "Public Telephone", label: i18n.tr("Public Telephone"), clause: "Telephones"},
			{en_label: "Toilet", label: i18n.tr("Toilet"), clause: "Toilets"},
			{en_label: "Wi-Fi Point", label: i18n.tr("Wi-Fi Point"), clause: "WiFi Points"}
		]
	},
	{
		label: i18n.tr("Shopping"),
		elements: [
			{en_label: "Books", label: i18n.tr("Books"), clause: "Book Shops"},
			{en_label: "Charity", label: i18n.tr("Charity"), clause: "Charity Shops"},
			{en_label: "Clothes", label: i18n.tr("Clothes"), clause: "Clothes Shops"},
			{en_label: "Computer Shop", label: i18n.tr("Computer Shop"), clause: "Computer Shops"},
			{en_label: "Copy Shop", label: i18n.tr("Copy Shop"), clause: "Copy Shops"},
			{en_label: "Florist", label: i18n.tr("Florist"), clause: "Florists"},
			{en_label: "Gifts", label: i18n.tr("Gifts"), clause: "Gift Shops"},
			{en_label: "Hairdresser", label: i18n.tr("Hairdresser"), clause: "Hairdressers"},
			{en_label: "Jewelry", label: i18n.tr("Jewelry"), clause: "Jewelry Shops"},
			{en_label: "Kiosk", label: i18n.tr("Kiosk"), clause: "Kiosk Shops"},
			{en_label: "Laundry", label: i18n.tr("Laundry"), clause: "Laundries"},
			{en_label: "Mall", label: i18n.tr("Mall"), clause: "Malls"},
			{en_label: "Mobile Phone", label: i18n.tr("Mobile Phone"), clause: "Mobile Phone Shops"},
			{en_label: "Optician", label: i18n.tr("Optician"), clause: "Opticians"},
			{en_label: "Public Market", label: i18n.tr("Public Market"), clause: "Marketplaces"},
			{en_label: "Shoes", label: i18n.tr("Shoes"), clause: "Shoe Shops"},
			{en_label: "Supermarket", label: i18n.tr("Supermarket"), clause: "Supermarkets"},
			{en_label: "Travel Agency", label: i18n.tr("Travel Agency"), clause: "Travel Agencies"},
			{en_label: "Vending Machine", label: i18n.tr("Vending Machine"), clause: "Vending Machines"}
		]
	},
	{
		label: i18n.tr("Culture"),
		elements: [
			{en_label: "Art Center", label: i18n.tr("Art Center"), clause: "Arts Centres"},
			{en_label: "Artwork", label: i18n.tr("Artwork"), clause: "Artworks"},
			{en_label: "Auditorium", label: i18n.tr("Auditorium"), clause: "Auditoriums"},
			{en_label: "Gallery", label: i18n.tr("Gallery"), clause: "Galleries"},
			{en_label: "Library", label: i18n.tr("Library"), clause: "Libraries"},
			{en_label: "Museum", label: i18n.tr("Museum"), clause: "Museums"},
			{en_label: "Theatre", label: i18n.tr("Theatre"), clause: "Theatres"}
		]
	},
	{
		label: i18n.tr("Entertainment"),
		elements: [
			{en_label: "Casino", label: i18n.tr("Casino"), clause: "Casinos"},
			{en_label: "Children Playground", label: i18n.tr("Children Playground"), clause: "Playgrounds"},
			{en_label: "Cinema", label: i18n.tr("Cinema"), clause: "Cinemas"},
			{en_label: "Gym", label: i18n.tr("Gym"), clause: "Gyms"},
			{en_label: "Night Club", label: i18n.tr("Night Club"), clause: "Night Clubs"},
			{en_label: "Park", label: i18n.tr("Park"), clause: "Parks"}
		]
	},
	{
		label: i18n.tr("Education"),
		elements: [
			{en_label: "College", label: i18n.tr("College"), clause: "Colleges"},
			{en_label: "Nursery School", label: i18n.tr("Nursery School"), clause: "Nurseries"},
			{en_label: "University", label: i18n.tr("University"), clause: "Universities"}
		]
	},
	{
		label: i18n.tr("Health"),
		elements: [
			{en_label: "Dentist", label: i18n.tr("Dentist"), clause: "Dentists"},
			{en_label: "Doctor", label: i18n.tr("Doctor"), clause: "Doctors"},
			{en_label: "Hospital", label: i18n.tr("Hospital"), clause: "Hospitals"},
			{en_label: "Pharmacy", label: i18n.tr("Pharmacy"), clause: "Pharmacies"},
			{en_label: "Veterinary", label: i18n.tr("Veterinary"), clause: "Veterinary Surgeries"}
		]
	},
	{
		label: i18n.tr("Religious"),
		elements: [
			{en_label: "Cemetery", label: i18n.tr("Cemetery"), clause: "Cemeteries"},
			{en_label: "Church", label: i18n.tr("Church"), clause: "Churchs"},
			{en_label: "Crematorium", label: i18n.tr("Crematorium"), clause: "Crematoriums"},
			{en_label: "Place of Worship", label: i18n.tr("Place of Worship"), clause: "Places of Worship"}
		]
	},
	{
		label: i18n.tr("Emergency"),
		elements: [
			{en_label: "Phone", label: i18n.tr("Phone"), clause: "Emergency Phones"},
			{en_label: "Police Station", label: i18n.tr("Police Station"), clause: "Police"}
		]
	},
	{
		label: i18n.tr("Sport"),
		elements: [
			{en_label: "Sports Center", label: i18n.tr("Sports Center"), clause: "Sports Centres"},
			{en_label: "Stadium", label: i18n.tr("Stadium"), clause: "Stadiums"},
			{en_label: "Swimming Pool", label: i18n.tr("Swimming Pool"), clause: "Swimming Pools"},
			{en_label: "Track", label: i18n.tr("Track"), clause: "Tracks"}
		]
	},
	{
		label: i18n.tr("Others"),
		elements: [
			{en_label: "Courthouse", label: i18n.tr("Courthouse"), clause: "Courthouses"},
			{en_label: "Embassy", label: i18n.tr("Embassy"), clause: "Embassies"},
			{en_label: "Prison", label: i18n.tr("Prison"), clause: "Prisons"},
			{en_label: "Recycling", label: i18n.tr("Recycling"), clause: "Recycling Points"},
			{en_label: "Town", label: i18n.tr("Town"), clause: "Towns"}
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
