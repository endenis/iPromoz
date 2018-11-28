//
// Created by maxime on 28/11/2018.
// Copyright (c) 2018 Denis Engels. All rights reserved.
//

import Cocoa

class PZTemplateGeneratorPresenter: PZTemplateGenerator.Presenter {

    let model: PZTemplateGenerator.Model
    weak var view: PZTemplateGenerator.View?

    init(model: PZTemplateGenerator.Model, view: PZTemplateGenerator.View) {
        self.model = model
        self.view = view
    }

    func onDisplayedTextUpdated(fontSize: CGFloat) {
        model.textSizeSelected = fontSize
    }

    func onImageAdded(templateUrl: URL) {
        guard let inputImage = NSImage(contentsOf: templateUrl),
              let width = inputImage.representations.first?.pixelsWide,
              let height = inputImage.representations.first?.pixelsHigh else { return }
        let size = NSMakeSize(CGFloat(width), CGFloat(height))
        model.originalImageSize = size
        model.templateUrl = templateUrl
    }

    func onAlignmentControlSelected(sender: NSSegmentedControl) {
        model.alignmentCoefficientSelected = CGFloat(sender.selectedSegment)
    }

    func onColorSelected(color: NSColor) {
        model.colorSelected = color
    }

    func onGenerateButtonTapped(hiddenLabel: PZTemplateLabel?, ratioX: CGFloat, ratioY: CGFloat, texts: [String]) {
        guard let hiddenLabel = hiddenLabel,
              let textColor = model.colorSelected,
              let ratio = model.getOriginalImageRatio(),
              let templateUrl = model.templateUrl else { return }
        let generator = PZImageGenerator(codes: texts,
                                         fontSize: model.textSizeSelected,
                                         textColor: textColor,
                                         templateUrl: templateUrl,
                                         ratioX: ratioX,
                                         ratioY: ratioY,
                                         templateRatio: ratio,
                                         hiddenLabel: hiddenLabel,
                                         alignmentCoefficient: model.alignmentCoefficientSelected)
        generator.generate()
    }
}
