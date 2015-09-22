//
//  NSDate+Utils.swift
//  SYNQueue
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation

class ISOFormatter : NSDateFormatter {
    override init() {
        super.init()
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        self.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        self.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        self.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension NSDate {
    convenience init?(dateString:String) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        if let d = formatter.dateFromString(dateString) {
            self.init(timeInterval:0, sinceDate:d)
        } else {
            self.init(timeInterval:0, sinceDate:NSDate())
            return nil
        }
    }
    
    var isoFormatter: ISOFormatter {
        if let formatter = objc_getAssociatedObject(self, "formatter") as? ISOFormatter {
            return formatter
        } else {
            let formatter = ISOFormatter()
            objc_setAssociatedObject(self, "formatter", formatter, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            return formatter
        }
    }
    
    func toISOString() -> String {
        return self.isoFormatter.stringFromDate(self)
    }
}
