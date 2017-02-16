//
//  PZTemplateLabel.swift
//  iPromoz
//
//  Created by Denis Engels on 16/02/2017.
//  Copyright © 2017 Denis Engels. All rights reserved.
//

import Cocoa

class PZTemplateLabel: NSTextField {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override func mouseEntered(with event: NSEvent) {
        Swift.print("mouse entered")
        isBordered = true
    }

    override func mouseExited(with event: NSEvent) {
        Swift.print("mouse exited")
        isBordered = false
    }

    func removeTrackingAreas() {
        Swift.print("removing tracking areas...")
        for trackingArea in trackingAreas {
            removeTrackingArea(trackingArea)
        }
    }
}
