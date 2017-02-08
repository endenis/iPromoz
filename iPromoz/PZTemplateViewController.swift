//
//  PZTemplateViewController.swift
//  iPromoz
//

import Cocoa

class PZTemplateViewController: NSViewController {

    @IBOutlet var instructionLabel: NSTextField?

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
    }
    
    func workingWithATemplateState(_ templateUrl: URL) {
        instructionLabel?.isHidden = true
        Swift.print(templateUrl)
    }
    
}
