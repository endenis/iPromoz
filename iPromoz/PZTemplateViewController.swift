//
//  PZTemplateViewController.swift
//  iPromoz
//

import Cocoa

class PZTemplateViewController: NSViewController {

    @IBOutlet var instructionLabel: NSTextField?
    @IBOutlet var exampleLabel    : PZTemplateLabel?

    var overlayView: NSView?
    let defaultFontSize: CGFloat = 20.0

    override func viewDidLoad() {
        super.viewDidLoad()

        if let templateView = self.view as? PZTemplateView {
            templateView.delegate = self
            templateView.postsFrameChangedNotifications = true
            overlayView = NSView.init()
            overlayView!.isHidden = true
            overlayView!.wantsLayer = true
            overlayView!.layer?.backgroundColor = CGColor.init(red: 0, green: 100, blue: 0, alpha: 0.42)
            templateView.addSubview(overlayView!)
            let nc = NotificationCenter.default
            nc.addObserver(forName:NSNotification.Name.NSViewFrameDidChange, object: templateView, queue: nil, using: catchNotification)
        }
    }

    func catchNotification(_: Notification) -> Void {
        if let templateView = self.view as? PZTemplateView, let templateRectangle: NSRect = templateView.imageRectangle(), let templateRatio: CGFloat = templateView.imageResizeRatio() {
            updateExampleLabel(templateRectangle: templateRectangle, templateRatio: templateRatio)
            overlayView?.frame = templateRectangle
        }
    }

    func updateExampleLabel(templateRectangle: NSRect, templateRatio: CGFloat) -> Void {
        if let theLabel = exampleLabel {
            let font: NSFont = theLabel.font!
            theLabel.font = NSFont.init(descriptor: font.fontDescriptor, size: (defaultFontSize * templateRatio))
            theLabel.frame.origin = templateRectangle.origin
            theLabel.sizeToFit()
        }
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
        if exampleLabel != nil {
            let tackingArea = NSTrackingArea.init(rect: exampleLabel!.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: exampleLabel!, userInfo: nil)
            exampleLabel!.addTrackingArea(tackingArea)
        }
    }
    
}
