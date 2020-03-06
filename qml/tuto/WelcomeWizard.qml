/*
 * uNav http://launchpad.net/unav
 * Copyright (C) 2015-2020 Marcos Alvarez Costales https://costales.github.io
 * This code is based on Podbird app code
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

import QtQuick 2.4
import Ubuntu.Components 1.3
import "components"

// Initial Walkthrough tutorial
Walkthrough {
    id: walkthrough
    onFinished: {
        navApp.settings.showTuto = false;
        console.log("[LOG]: Welcome tour complete")
        mainPageStack.removePages(walkthrough)
    }
    model: [
        Slide1{},
        Slide2{},
        Slide3{},
        Slide4{},
        Slide5{},
        Slide6{}
    ]
}
