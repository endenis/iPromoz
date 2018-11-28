//
// Created by maxime on 28/11/2018.
// Copyright (c) 2018 Denis Engels. All rights reserved.
//

import Cocoa

class PZTemplateGeneratorModel: PZTemplateGenerator.Model {

    var originalImageSize: NSSize?
    var colorSelected: NSColor = NSColor.black
    var templateUrl: URL?
    var alignmentCoefficientSelected: CGFloat = 1
    var textSizeSelected: CGFloat = 20
    let screenBounds: CGRect
    let fontName: String = "Helvetica Neue"

    init(screenBounds: CGRect) {
        self.screenBounds = screenBounds
    }

    func getOriginalImageRatio() -> CGFloat? {
        guard let imageSize = originalImageSize else { return nil }
        if screenBounds.width > imageSize.width && screenBounds.height > imageSize.height {
            return 1.0
        } else {
            let xRatio = screenBounds.width / imageSize.width
            let yRatio = screenBounds.height / imageSize.height
            return [xRatio, yRatio].min()
        }
    }
}

