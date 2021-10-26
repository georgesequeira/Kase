//
//  TimestampFormatter.swift
//  Kase
//
//  Created by George Sequeira on 3/9/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import Foundation

class TimestampFormatter: NumberFormatter {
    required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init() {
    super.init()
  }

    override func string(from duration: NSNumber) -> String? {
        let duration = duration.floatValue
        let minutes = floor(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))

        // time string, we don't want the decimals
        let timeString = String(format: "%01d:%02d", Int(minutes), Int(seconds))

        return timeString
    }
}
