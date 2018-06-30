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
    var ratioX: CGFloat = 0
    var ratioY: CGFloat = 0
    var templateRatio: CGFloat = 0.0
    var label: PZTemplateLabel? = nil
    var hiddenLabel: PZTemplateLabel? = nil
    var alignmentCoefficient: CGFloat = 1

    init(codes: [String], templateImage: NSImage, ratioX: CGFloat, ratioY: CGFloat, templateRatio: CGFloat, label: PZTemplateLabel, hiddenLabel: PZTemplateLabel, alignmentCoefficient: CGFloat) {
        self.codes = codes
        self.templateImage = templateImage
        self.ratioX = ratioX
        self.ratioY = ratioY
        self.label = label
        self.hiddenLabel = hiddenLabel
        self.templateRatio = templateRatio
        self.alignmentCoefficient = alignmentCoefficient
    }

    func generate() {
        let code = self.codes.first!
        if let image = self.templateImage, let label = self.label, let hiddenLabel = self.hiddenLabel, let font = label.font {
            let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            hiddenLabel.stringValue = code
            hiddenLabel.font = NSFont.init(descriptor: font.fontDescriptor, size: (font.pointSize / self.templateRatio))
            hiddenLabel.sizeToFit()
            let proportionalWidth = hiddenLabel.frame.width
            let proportionalHeight = hiddenLabel.frame.height
            let x = self.ratioX * image.size.width
            let y = self.ratioY * image.size.height - proportionalHeight * 0.5
            let alignedX = x - proportionalWidth * alignmentCoefficient / 2
            let textRect = CGRect(x: alignedX, y: y, width: proportionalWidth, height: proportionalHeight)
            let textStyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = .center
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
