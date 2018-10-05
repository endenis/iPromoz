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
    var directoryURL: URL?

    init(codes: [String], templateUrl: URL, ratioX: CGFloat, ratioY: CGFloat, templateRatio: CGFloat, label: PZTemplateLabel, hiddenLabel: PZTemplateLabel, alignmentCoefficient: CGFloat) {
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
        if let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first {
            self.directoryURL = desktopURL.appendingPathComponent("promoz \(currentBatchName())")
            if let batchURL = directoryURL {
                do {
                    try FileManager.default.createDirectory(at: batchURL, withIntermediateDirectories: false, attributes: nil)
                    generateAllCodes()
                }
                catch {
                    print(error) // TODO: handle error better
                }
            }
        }
    }
    
    func currentBatchName() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        return dateFormatter.string(from: Date())
    }

    func generateAllCodes() {
        for code in self.codes {
            generateSingleCode(code: code)
        }
    }

    func generateSingleCode(code: String) {
        if let image = self.templateImage, let imageRepresentation = image.representations.first, let label = self.label, let hiddenLabel = self.hiddenLabel, let font = label.font {
            let imageRect = CGRect(x: 0, y: 0, width: imageRepresentation.pixelsWide, height: imageRepresentation.pixelsHigh)
            prepareHiddenLabel(hiddenLabel: hiddenLabel, code: code, font: font, scaling: self.templateRatio)
            let x = self.ratioX * CGFloat(imageRepresentation.pixelsWide) - hiddenLabel.frame.width * alignmentCoefficient / 2
            let y = self.ratioY * CGFloat(imageRepresentation.pixelsHigh) - hiddenLabel.frame.height / 2
            let textRect = CGRect(x: x, y: y, width: hiddenLabel.frame.width, height: hiddenLabel.frame.height)
            let textStyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = .center
            let textFontAttributes = [
                NSFontAttributeName: hiddenLabel.font!,
                NSForegroundColorAttributeName: label.textColor!,
                NSParagraphStyleAttributeName: textStyle
            ]
            let bitmapImageRepresentation: NSBitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(imageRepresentation.pixelsWide), pixelsHigh: Int(imageRepresentation.pixelsHigh), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSCalibratedRGBColorSpace, bytesPerRow: 0, bitsPerPixel: 0)!
            NSAffineTransform.init().set()
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: bitmapImageRepresentation))
            image.draw(in: imageRect)
            code.draw(in: textRect, withAttributes: textFontAttributes)
            NSGraphicsContext.restoreGraphicsState()
            saveTemplateImage(bitmapImageRepresentation: bitmapImageRepresentation, code: code)
        }
    }

    func prepareHiddenLabel(hiddenLabel: PZTemplateLabel, code: String, font: NSFont, scaling: CGFloat) {
        hiddenLabel.stringValue = code
        hiddenLabel.font = NSFont.init(descriptor: font.fontDescriptor, size: (font.pointSize / scaling))
        hiddenLabel.sizeToFit()
    }

    func saveTemplateImage(bitmapImageRepresentation: NSBitmapImageRep, code: String) {
        if let batchURL = self.directoryURL {
            let templateURL = batchURL.appendingPathComponent(filename(code: code)) // TODO: use better filename and location
            writeJpegFile(bitmapImageRepresentation: bitmapImageRepresentation, to: templateURL)
        }
    }

    func filename(code: String) -> String {
        let sanitizedCode = code.components(separatedBy: CharacterSet.init(charactersIn: "/\\:?%*|\"<>")).joined()
        return "\(sanitizedCode).jpg"
    }

    func writeJpegFile(bitmapImageRepresentation: NSBitmapImageRep, to: URL) {
        do {
            try bitmapImageRepresentation.representation(using: .JPEG, properties: [:])!.write(to: to)
        }
        catch {
            print(error) // TODO: handle errors better
        }
    }

}
