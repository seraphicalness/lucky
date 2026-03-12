//
//  HarugiwunWidgetBundle.swift
//  HarugiwunWidget
//
//  Created by 김나희 on 3/12/26.
//

import WidgetKit
import SwiftUI

@main
struct HarugiwunWidgetBundle: WidgetBundle {
    var body: some Widget {
        HarugiwunWidget()
        HarugiwunWidgetControl()
        HarugiwunWidgetLiveActivity()
    }
}
