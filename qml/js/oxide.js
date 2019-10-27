/*
 * uNav http://launchpad.net/unav
 * Copyright (C) 2015 JkB https://launchpad.net/~joergberroth
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

oxide.addMessageHandler("EXECUTE", function (msg) {
	var event = new CustomEvent("ExecuteJavascript", {detail: msg.args.code});
	document.dispatchEvent(event);
	msg.reply({str: "Event received: " + msg.args.code});
});
