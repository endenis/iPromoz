//
//  PZImageGenerator.swift
//  iPromoz
//
//  Created by Denis Engels on 11/06/2018.
//  Copyright © 2018 Denis Engels. All rights reserved.
//

import Cocoa

class PZImageGenerator: NSObject {

    var codes: [String] = []
    var templateImage: NSImage? = nil
    var x: CGFloat = 0
    var y: CGFloat = 0
    var ratioX: CGFloat = 0.5
    var ratioY: CGFloat = 0.5
    var label: PZTemplateLabel? = nil
    var alignmentCoefficient: CGFloat = 1

    init(codes: [String], templateImage: NSImage, x: CGFloat, y: CGFloat, ratioX: CGFloat, ratioY: CGFloat, label: PZTemplateLabel, alignmentCoefficient: CGFloat) {
        self.codes = codes
        self.templateImage = templateImage
        self.x = x
        self.y = y
        self.label = label
        self.ratioX = ratioX
        self.ratioY = ratioY
        self.alignmentCoefficient = alignmentCoefficient
    }

    func generate() {
        let code = self.codes.first!
        if let image = self.templateImage, let label = self.label {
            let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            label.stringValue = code
            label.sizeToFit()
            let proportionalWidth = label.frame.width / self.ratioX
            let proportionalHeight = label.frame.height / self.ratioY
            let alignedX = self.x + proportionalWidth * alignmentCoefficient
            let textRect = CGRect(x: alignedX, y: self.y, width: proportionalWidth, height: proportionalHeight)
            let textStyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
            let textFontAttributes = [
                NSFontAttributeName: label.font!,
                NSForegroundColorAttributeName: label.textColor!,
                NSParagraphStyleAttributeName: textStyle
            ]
            let im: NSImage = NSImage(size: image.size)
            let rep: NSBitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(image.size.width), pixelsHigh: Int(image.size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSCalibratedRGBColorSpace, bytesPerRow: 0, bitsPerPixel: 0)!
            im.addRepresentation(rep)
            im.lockFocus()
            image.draw(in: imageRect)
            code.draw(in: textRect, withAttributes: textFontAttributes)
            im.unlockFocus()
            if let tiffRepresentation = im.tiffRepresentation {
                let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
                let destinationURL = desktopURL.appendingPathComponent("my-image.png")
                let bitmapImage = NSBitmapImageRep(data: tiffRepresentation)
                do {
                  try bitmapImage?.representation(using: .PNG, properties: [:])?.write(to: destinationURL)
                }
                catch {
                    print(error)
                }
            }
        }
    }

}
