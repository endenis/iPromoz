//
//  PZTemplateViewController.swift
//  iPromoz
//

import Cocoa

class PZTemplateViewController: NSViewController {

    @IBOutlet var instructionLabel: NSTextField?
    @IBOutlet var exampleLabel    : NSTextField?

    @IBAction func logStuff(sender: NSButton) {
        if let templateView = self.view as? PZTemplateView {
            exampleLabel?.stringValue = "aaaaaaaaa"
            if let templateRectangle: NSRect = templateView.imageRectangle() {
                Swift.print(templateRectangle)
                exampleLabel?.frame.origin.x = templateRectangle.origin.x
                exampleLabel?.frame.origin.y = templateRectangle.origin.y
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let templateView = self.view as? PZTemplateView {
            templateView.delegate = self
        }
    }
}

extension PZTemplateViewController: PZTemplateViewDelegate {

    func nothingToDoState() {
        instructionLabel?.isHidden = false
        exampleLabel?.isHidden = true
        if let templateView = self.view as? PZTemplateView {
            templateView.image = nil
        }
    }
    
    func workingWithATemplateState(_ templateUrl: URL) {
        instructionLabel?.isHidden = true
        exampleLabel?.isHidden = false
        Swift.print(templateUrl)
        if let templateView = self.view as? PZTemplateView {
            templateView.image = NSImage.init(contentsOf: templateUrl)
        }
    }
    
}
