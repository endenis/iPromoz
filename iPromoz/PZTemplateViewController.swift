//
//  PZTemplateViewController.swift
//  iPromoz
//

import Cocoa

class PZTemplateViewController: NSViewController {

    @IBOutlet var instructionLabel: NSTextField?
    @IBOutlet var exampleLabel    : PZTemplateLabel?
    @IBOutlet var fontSizeField   : NSTextField?
    @IBOutlet var textTableView   : NSTableView?

    var fontSize: CGFloat = 20.0
    var ratioX: CGFloat = 0.5
    var ratioY: CGFloat = 0.5
    var alignmentCoefficient: CGFloat = 1
    var texts: [String] = []
    let defaultLabelText = "EXAMPLE"

    override func viewDidLoad() {
        super.viewDidLoad()

        let colorPanel = NSColorPanel.shared()
        colorPanel.setTarget(self)
        colorPanel.setAction(#selector(colorDidChange(sender:)))
        colorPanel.isContinuous = true

        if let templateView = self.view as? PZTemplateView {
            templateView.delegate = self
            templateView.postsFrameChangedNotifications = true
            let nc = NotificationCenter.default
            nc.addObserver(forName:NSNotification.Name.NSViewFrameDidChange, object: templateView, queue: nil, using: catchNotification)
        }
        let fontManager = NSFontManager.shared()
        fontManager.target = self
        textTableView?.reloadData()
    }

    func catchNotification(_: Notification) -> Void {
        updateSizes()
    }

    func updateSizes() -> Void {
        if let templateView = self.view as? PZTemplateView, let templateRectangle: NSRect = templateView.imageRectangle(), let templateRatio: CGFloat = templateView.imageResizeRatio() {
            updateExampleLabel(templateRectangle: templateRectangle, templateRatio: templateRatio)
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
        let updatedAlignmentCoefficient = CGFloat(sender.selectedSegment)
        if let theLabel = exampleLabel {
            let x = theLabel.frame.origin.x + theLabel.frame.width * (updatedAlignmentCoefficient - alignmentCoefficient) * 0.5
            updateLabelPositionRatio(CGPoint(x: x, y: theLabel.frame.origin.y))
        }
        self.alignmentCoefficient = updatedAlignmentCoefficient
        updateSizes()
    }

    func colorDidChange(sender: Any?) {
        if let colorPanel = sender as? NSColorPanel {
            exampleLabel?.textColor = colorPanel.color
        }
    }
    
    @IBAction func updateLabelFontSize(sender: NSTextField) {
        self.fontSize = CGFloat(sender.integerValue)
        updateSizes()
    }
    
    @IBAction func updateTextInTable(sender: NSTextField) {
        if let tableView = textTableView {
            let selectedRow = tableView.selectedRow
            if selectedRow != -1 {
                if selectedRow >= texts.count {
                    texts.append(sender.stringValue)
                }
                else {
                    texts[selectedRow] = sender.stringValue
                }
                tableView.reloadData()
            }
        }
    }
    
    func updateExampleLabelText(_ text: String) {
        exampleLabel?.stringValue = text
        updateSizes()
    }

}

extension PZTemplateViewController: PZTemplateViewDelegate {

    func nothingToDoState() {
        instructionLabel?.isHidden = false
        exampleLabel?.isHidden = true
        exampleLabel?.stringValue = defaultLabelText
        fontSizeField?.isEnabled = false
        if let templateView = self.view as? PZTemplateView {
            templateView.image = nil
        }
        exampleLabel?.removeTrackingAreas()
    }
    
    func workingWithATemplateState(_ templateUrl: URL) {
        instructionLabel?.isHidden = true
        exampleLabel?.isHidden = false
        fontSizeField?.isEnabled = true
        fontSizeField?.integerValue = Int(fontSize.rounded())
        Swift.print(templateUrl)
        if let templateView = self.view as? PZTemplateView {
            templateView.image = NSImage.init(contentsOf: templateUrl)
            if let templateRectangle: NSRect = templateView.imageRectangle(), let templateRatio: CGFloat = templateView.imageResizeRatio() {
                updateExampleLabel(templateRectangle: templateRectangle, templateRatio: templateRatio)
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

extension PZTemplateViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return texts.count + 1
    }
}

extension PZTemplateViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row <= texts.count {
            let text: String = (row < texts.count) ? texts[row] : ""
            if let cell = tableView.make(withIdentifier: "TextCellID", owner: nil) as? NSTableCellView {
                cell.textField!.stringValue = text
                return cell
            }
        }
        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = textTableView!.selectedRow
        if textTableView!.numberOfSelectedRows != 0 && selectedRow < texts.count && !texts[selectedRow].isEmpty {
            updateExampleLabelText(texts[selectedRow])
        }
        else {
            updateExampleLabelText(defaultLabelText)
        }
    }
    
}

extension PZTemplateViewController : PZCodeScrollViewDelegate {

    func importCodesFromCsvUrl(_ csvUrl: URL) {
        let codesFromCsv = PZCsvReader.readCodesFromFileUrl(csvUrl)
        texts = codesFromCsv
        Swift.print(texts)
        textTableView?.reloadData()
    }

}
