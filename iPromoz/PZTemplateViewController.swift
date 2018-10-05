//
//  PZTemplateViewController.swift
//  iPromoz
//

import Cocoa

class PZTemplateViewController: NSViewController {

    @IBOutlet var instructionLabel: NSTextField?
    @IBOutlet var exampleLabel: PZTemplateLabel?
    @IBOutlet var hiddenLabel: PZTemplateLabel?
    @IBOutlet var fontSizeField: NSTextField?
    @IBOutlet var textTableView: NSTableView?
    @IBOutlet var generationButton: NSButton?

    var fontSize: CGFloat = 20.0
    var ratioX: CGFloat = 0.5
    var ratioY: CGFloat = 0.5
    var alignmentCoefficient: CGFloat = 1
    var templateUrl: URL? = nil
    var texts: [String] = []
    let defaultLabelText = "EXAMPLE"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupColorPanel()
        setupTemplateView()
        setupFontManager()
        setupTextTableView()
    }

    func setupColorPanel() {
        let colorPanel = NSColorPanel.shared()
        colorPanel.setTarget(self)
        colorPanel.setAction(#selector(colorDidChange(sender:)))
        colorPanel.isContinuous = true
    }

    func setupTemplateView() {
        if let templateView = self.view as? PZTemplateView {
            templateView.delegate = self
            templateView.postsFrameChangedNotifications = true
            let nc = NotificationCenter.default
            nc.addObserver(forName: NSNotification.Name.NSViewFrameDidChange, object: templateView, queue: nil, using: catchNotification)
        }
    }

    func setupFontManager() {
        let fontManager = NSFontManager.shared()
        fontManager.target = self
    }

    func setupTextTableView() {
        textTableView?.reloadData()
    }

    func catchNotification(_: Notification) -> Void {
        updateSizes()
    }

    func updateSizes() -> Void {
        if let templateView = self.view as? PZTemplateView, let templateRectangle: NSRect = templateView.imageRectangle(), let templateRatio: CGFloat = templateView.imageResizeRatio() {
            updateExampleLabelSize(templateRectangle: templateRectangle, templateRatio: templateRatio)
        }
    }

    func updateExampleLabelSize(templateRectangle: NSRect, templateRatio: CGFloat) -> Void {
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

    @IBAction func generate(sender: NSButton) {
        if let templateView = self.view as? PZTemplateView, let templateRatio = templateView.imageResizeRatio(), let label = exampleLabel, let hiddenLabel = self.hiddenLabel, let templateUrl = self.templateUrl {
            let generator = PZImageGenerator(codes: self.texts, templateUrl: templateUrl, ratioX: ratioX, ratioY: ratioY, templateRatio: templateRatio, label: label, hiddenLabel: hiddenLabel, alignmentCoefficient: self.alignmentCoefficient)
            generator.generate()
        }
    }

    func checkGenerationButtonState() {
        generationButton?.isEnabled = shouldGenerationButtonBeEnabled()
    }

    func shouldGenerationButtonBeEnabled() -> Bool {
        if let templateView = self.view as? PZTemplateView {
            if templateView.image != nil && !texts.isEmpty {
               return true
            }
        }
        return false
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
        self.templateUrl = templateUrl
        Swift.print(templateUrl)
        if let templateView = self.view as? PZTemplateView, let inputImage = NSImage(contentsOf: templateUrl) {
            importTemplateImage(templateView: templateView, inputImage: inputImage)
        }
        addTrackingArea(label: exampleLabel)
        checkGenerationButtonState()
    }

    func importTemplateImage(templateView: PZTemplateView, inputImage: NSImage) {
        let width = inputImage.representations.first!.pixelsWide
        let height = inputImage.representations.first!.pixelsHigh
        let destSize = NSMakeSize(CGFloat(width), CGFloat(height))
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        inputImage.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, inputImage.size.width, inputImage.size.height), operation: .sourceAtop, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        templateView.image = NSImage(data: newImage.tiffRepresentation!)!
        if let templateRectangle: NSRect = templateView.imageRectangle(), let templateRatio: CGFloat = templateView.imageResizeRatio() {
            updateExampleLabelSize(templateRectangle: templateRectangle, templateRatio: templateRatio)
        }
    }

    func addTrackingArea(label: PZTemplateLabel?) {
        if let labelToTrack = label {
            let tackingArea = NSTrackingArea.init(rect: labelToTrack.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: labelToTrack, userInfo: nil)
            labelToTrack.addTrackingArea(tackingArea)
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

    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if let code = object as? String {
            setCodeAt(code: code, row: row)
        }
    }

    func setCodeAt(code: String, row: Int) {
        let count = texts.count
        if row < count {
            Swift.print("set \(code) at row \(row)")
            texts[row] = code
        }
        else {
            texts.append(code)
            Swift.print("appended \(code)")
            checkGenerationButtonState()
        }
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

    func tableView(_ tableView: NSTableView, didAdd: NSTableRowView, forRow: Int) {
        Swift.print("added row for row \(forRow)")
    }
}

extension PZTemplateViewController : PZCodeScrollViewDelegate {

    func importCodesFromCsvUrl(_ csvUrl: URL) {
        let codesFromCsv = PZCsvReader.readCodesFromFileUrl(csvUrl)
        texts = codesFromCsv
        textTableView?.reloadData()
        checkGenerationButtonState()
    }

}
