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
    var templateUrl: URL? = nil
    var ratioX: CGFloat = 0
    var ratioY: CGFloat = 0
    var templateRatio: CGFloat = 0.0
    var label: PZTemplateLabel? = nil
    var hiddenLabel: PZTemplateLabel? = nil
    var alignmentCoefficient: CGFloat = 1

    init(codes: [String], _templateImage: NSImage, templateUrl: URL, ratioX: CGFloat, ratioY: CGFloat, templateRatio: CGFloat, label: PZTemplateLabel, hiddenLabel: PZTemplateLabel, alignmentCoefficient: CGFloat) {
        self.codes = codes
        self.templateImage = NSImage.init(contentsOf: templateUrl)
        self.ratioX = ratioX
        self.ratioY = ratioY
        self.label = label
        self.hiddenLabel = hiddenLabel
        self.templateRatio = templateRatio
        self.alignmentCoefficient = alignmentCoefficient
    }

    func generate() {
        let code = self.codes.first!
        if let image = self.templateImage, let imageRepresentation = image.representations.first, let label = self.label, let hiddenLabel = self.hiddenLabel, let font = label.font {
            let imageRect = CGRect(x: 0, y: 0, width: imageRepresentation.pixelsWide, height: imageRepresentation.pixelsHigh)
            hiddenLabel.stringValue = code
            hiddenLabel.font = NSFont.init(descriptor: font.fontDescriptor, size: (font.pointSize / self.templateRatio))
            hiddenLabel.sizeToFit()
            let proportionalWidth = hiddenLabel.frame.width / self.templateRatio
            let proportionalHeight = hiddenLabel.frame.height / self.templateRatio
            let x = self.ratioX * CGFloat(imageRepresentation.pixelsWide)
            let y = self.ratioY * CGFloat(imageRepresentation.pixelsHigh) - proportionalHeight * 0.5
            let alignedX = x - proportionalWidth * alignmentCoefficient / 2
            let textRect = CGRect(x: alignedX, y: y, width: proportionalWidth, height: proportionalHeight)
            let textStyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = .center
            let textFontAttributes = [
                NSFontAttributeName: label.font!,
                NSForegroundColorAttributeName: label.textColor!,
                NSParagraphStyleAttributeName: textStyle
            ]
            let im: NSImage = NSImage(size: NSSize(width: imageRepresentation.pixelsWide, height: imageRepresentation.pixelsHigh))
            let rep: NSBitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(imageRepresentation.pixelsWide), pixelsHigh: Int(imageRepresentation.pixelsHigh), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSCalibratedRGBColorSpace, bytesPerRow: 0, bitsPerPixel: 0)!
            NSAffineTransform.init().set()
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: rep))
            image.draw(in: imageRect)
            code.draw(in: textRect, withAttributes: textFontAttributes)
            NSGraphicsContext.restoreGraphicsState()
            let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
            let destinationURL = desktopURL.appendingPathComponent("my-image.png")
            do {
                try rep.representation(using: .JPEG, properties: [:])!.write(to: destinationURL)
            }
            catch {
                print(error)
            }
        }
    }

}
