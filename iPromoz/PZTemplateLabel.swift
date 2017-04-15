//
//  PZTemplateLabel.swift
//  iPromoz
//
//  Created by Denis Engels on 16/02/2017.
//  Copyright © 2017 Denis Engels. All rights reserved.
//

import Cocoa

class PZTemplateLabel: NSTextField {

    var clickedDownX: CGFloat = 0
    var clickedDownY: CGFloat = 0

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override func mouseEntered(with event: NSEvent) {
        Swift.print("mouse entered")
        Swift.print(self.frame)
        self.drawsBackground = true
        self.backgroundColor = NSColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 0.2)
    }

    override func mouseExited(with event: NSEvent) {
        Swift.print("mouse exited")
        self.drawsBackground = false
    }

    override func mouseDown(with event: NSEvent) {
        Swift.print("mouse down")
        let position = self.convert(event.locationInWindow, from: nil)
        self.clickedDownX = position.x
        self.clickedDownY = position.y
    }
    
    override func mouseDragged(with event: NSEvent) {
        let position = self.convert(event.locationInWindow, from: nil)
        Swift.print("mouse dragged \(position) while the frame is \(self.frame)")
        self.frame.origin.x += position.x - self.clickedDownX
        self.frame.origin.y -= position.y - self.clickedDownY
        self.clickedDownX = position.x
        self.clickedDownY = position.y
    }
    
    override func mouseUp(with event: NSEvent) {
        Swift.print("mouse up")
    }

    func removeTrackingAreas() {
        Swift.print("removing tracking areas...")
        for trackingArea in trackingAreas {
            removeTrackingArea(trackingArea)
        }
    }

}
