//
//  PZTemplateViewController.swift
//  iPromoz
//

import Cocoa

class PZTemplateViewController: NSViewController {

    @IBOutlet var instructionLabel: NSTextField?
    @IBOutlet var exampleLabel    : PZTemplateLabel?

    var overlayView: NSView?
    var fontSize: CGFloat = 20.0
    var ratioX: CGFloat = 0.5
    var ratioY: CGFloat = 0.5
    var alignmentCoefficient: CGFloat = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        if let templateView = self.view as? PZTemplateView {
            templateView.delegate = self
            templateView.postsFrameChangedNotifications = true
            //overlayView = NSView.init()
            //overlayView!.isHidden = true
            //overlayView!.wantsLayer = true
            //overlayView!.layer?.backgroundColor = CGColor.init(red: 0, green: 100, blue: 0, alpha: 0.42)
            //templateView.addSubview(overlayView!)
            let nc = NotificationCenter.default
            nc.addObserver(forName:NSNotification.Name.NSViewFrameDidChange, object: templateView, queue: nil, using: catchNotification)
        }
        let fontManager = NSFontManager.shared()
        fontManager.target = self
    }
    
    override func changeFont(_ sender: Any?) {
        if let theLabel = exampleLabel {
            let oldFont = theLabel.font!
            let fontManager = sender as! NSFontManager
            let newFont = fontManager.convert(oldFont)
            self.fontSize = newFont.pointSize
            theLabel.font = newFont
            theLabel.sizeToFit()
            updateSizes()
        }
    }

    func catchNotification(_: Notification) -> Void {
        updateSizes()
    }

    func changeAttributes(_ sender: Any?) {
        if let _ = exampleLabel {
            Swift.print("changeAttributes from \(sender)")
        }
    }

    func updateSizes() -> Void {
        if let templateView = self.view as? PZTemplateView, let templateRectangle: NSRect = templateView.imageRectangle(), let templateRatio: CGFloat = templateView.imageResizeRatio() {
            updateExampleLabel(templateRectangle: templateRectangle, templateRatio: templateRatio)
            overlayView?.frame = templateRectangle
        }
    }

    func updateExampleLabel(templateRectangle: NSRect, templateRatio: CGFloat) -> Void {
        if let theLabel = exampleLabel {
            let font: NSFont = theLabel.font!
            theLabel.font = NSFont.init(descriptor: font.fontDescriptor, size: (fontSize * templateRatio))
            theLabel.sizeToFit()
            let x: CGFloat = templateRectangle.origin.x + self.ratioX * templateRectangle.width - (theLabel.frame.width / 2.0) * self.alignmentCoefficient
            let y: CGFloat = templateRectangle.origin.y + self.ratioY * templateRectangle.height - (theLabel.frame.height / 2.0)
            theLabel.frame.origin.x = round(x)
            theLabel.frame.origin.y = round(y)
        }
    }

    @IBAction func alignmentControlSelected(_ sender: NSSegmentedControl) {
        self.alignmentCoefficient = CGFloat(sender.selectedSegment)
        updateSizes()
    }
}

extension PZTemplateViewController: PZTemplateViewDelegate {

    func nothingToDoState() {
        instructionLabel?.isHidden = false
        exampleLabel?.isHidden = true
        overlayView?.isHidden = true
        if let templateView = self.view as? PZTemplateView {
            templateView.image = nil
        }
        exampleLabel?.removeTrackingAreas()
    }
    
    func workingWithATemplateState(_ templateUrl: URL) {
        instructionLabel?.isHidden = true
        exampleLabel?.isHidden = false
        overlayView?.isHidden = false
        Swift.print(templateUrl)
        if let templateView = self.view as? PZTemplateView {
            templateView.image = NSImage.init(contentsOf: templateUrl)
            if let templateRectangle: NSRect = templateView.imageRectangle(), let templateRatio: CGFloat = templateView.imageResizeRatio() {
                updateExampleLabel(templateRectangle: templateRectangle, templateRatio: templateRatio)
                overlayView?.frame = templateRectangle
            }
        }
        if let theLabel = exampleLabel {
            let tackingArea = NSTrackingArea.init(rect: theLabel.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: theLabel, userInfo: nil)
            theLabel.addTrackingArea(tackingArea)
        }
    }

    func updateLabelPositionRatio(_ point: CGPoint) {
        if let templateView = self.view as? PZTemplateView, let templateRectangle: NSRect = templateView.imageRectangle(), let theLabel = exampleLabel {
            let widthDetla  = (theLabel.frame.width  / 2.0) * self.alignmentCoefficient
            let heightDelta = (theLabel.frame.height / 2.0)
            self.ratioX = (point.x - templateRectangle.origin.x + widthDetla)  / templateRectangle.width
            self.ratioY = (point.y - templateRectangle.origin.y + heightDelta) / templateRectangle.height
        }
    }
    
}
