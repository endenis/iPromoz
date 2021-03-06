//
//  PZTemplateLabel.swift
//  iPromoz
//
//  Created by endenis on 16/02/2017.
//  Copyright © 2017 endenis. All rights reserved.
//

import Cocoa

class PZTemplateLabel: NSTextField {

    @IBOutlet var templateViewDelegate: PZTemplateViewController?

    var clickedDownX: CGFloat = 0
    var clickedDownY: CGFloat = 0
    let mouseHoverBackgroundColor = NSColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 0.2)

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override func mouseEntered(with event: NSEvent) {
    }

    override func mouseExited(with event: NSEvent) {
    }

    override func mouseDown(with event: NSEvent) {
        let position = self.convert(event.locationInWindow, from: nil)
        self.clickedDownX = position.x
        self.clickedDownY = position.y
        self.drawsBackground = true
        self.backgroundColor = self.mouseHoverBackgroundColor
    }
    
    override func mouseDragged(with event: NSEvent) {
        let position = self.convert(event.locationInWindow, from: nil)
        self.frame.origin.x += round(position.x - self.clickedDownX)
        self.frame.origin.y -= round(position.y - self.clickedDownY)
        templateViewDelegate?.updateLabelPositionRatio(self.frame.origin)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.drawsBackground = false
    }

    func removeTrackingAreas() {
        for trackingArea in trackingAreas {
            removeTrackingArea(trackingArea)
        }
    }

}
