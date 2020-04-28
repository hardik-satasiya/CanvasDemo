//
//  ViewController.swift
//  CanvasDemo macOS
//
//  Created by Chen on 2020/4/15.
//  Copyright © 2020 vitiny. All rights reserved.
//

import Cocoa

import Canvas

enum Shape: String, CaseIterable {
    case line
    case polyline
    case circle
    case rect
    case pencil
    case pencil2
    case protractor
    case cirdist
    
    func canvasItemType() -> CanvasItem.Type {
        switch self {
        case .line:         return LineItem.self
        case .polyline:     return PolylineItem.self
        case .circle:       return CircleItem.self
        case .rect:         return RectItem.self
        case .pencil:       return PencilItem.self
        case .pencil2:      return PencilItem2.self
        case .protractor:   return ProtractorItem.self
        case .cirdist:      return CirdistItem.self
        }
    }
}

class ViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var cursorButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var undoButton: NSButton!
    @IBOutlet weak var redoButton: NSButton!
    @IBOutlet weak var colorWell: NSColorWell!
    @IBOutlet weak var rotationSlider: NSSlider!
    @IBOutlet weak var textField: NSTextField!
    
    var selectedRow: Int? { tableView.selectedRow != -1 ? tableView.selectedRow : nil }
    var selectedItemIndex: Int? { canvasView.selectedItemIndexes.count == 1 ? canvasView.selectedItemIndexes.first : nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpObservers()
        updateUI()
        rotationSlider.scaleUnitSquare(to: NSSize(width: -1, height: 1))
        rotationSlider.rotate(byDegrees: -90)
    }
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setUpObservers() {
        let notCenter = NotificationCenter.default
        notCenter.addObserver(forName: .canvasViewSelectionDidChange, object: nil, queue: .main) { _ in
            self.updateUI()
        }
    }
    
    func updateUI() {
        deleteButton.isEnabled = !canvasView.selectedItemIndexes.isEmpty
        undoButton.isEnabled = undoManager?.canUndo ?? false
        redoButton.isEnabled = undoManager?.canRedo ?? false
        if let idx = selectedItemIndex {
            let item = canvasView.items[idx]
            colorWell.color = item.strokeColor
            rotationSlider.isEnabled = true
            rotationSlider.integerValue = Int(radiansToDegrees(item.rotationAngle))
            textField.isEnabled = item is RectItem
            textField.stringValue = (item as? RectItem)?.text ?? ""
        } else {
            colorWell.color = canvasView.strokeColor
            rotationSlider.isEnabled = false
            rotationSlider.integerValue = 0
            textField.isEnabled = false
            textField.stringValue = ""
        }
    }
    
    // MARK: - Actions
    
    @IBAction func endSession(_ sender: Any) {
        canvasView.endDrawingSession()
    }
    
    @IBAction func removeSelection(_ sender: Any) {
        canvasView.removeItems(at: canvasView.selectedItemIndexes)
    }
    
    @IBAction func undo(_ sender: Any) {
        undoManager?.undo()
        updateUI()
    }
    
    @IBAction func redo(_ sender: Any) {
        undoManager?.redo()
        updateUI()
    }
    
    @IBAction func colorChanged(_ sender: NSColorWell) {
        if let idx = selectedItemIndex {
            canvasView.items[idx].strokeColor = sender.color
        } else {
            canvasView.strokeColor = sender.color
        }
    }
    
    @IBAction func rotationAngleChanged(_ sender: NSSlider) {
        if let idx = selectedItemIndex {
            let angle = degreesToRadians(CGFloat(sender.integerValue))
            canvasView.items[idx].rotate(angle)
        }
    }
    
    @IBAction func textChanged(_ sender: NSTextField) {
        if let idx = selectedItemIndex, let item = canvasView.items[idx] as? RectItem {
            item.text = sender.stringValue
        }
    }
    
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int { Shape.allCases.count }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let id = NSUserInterfaceItemIdentifier("Cell")
        let rowView = tableView.makeView(withIdentifier: id, owner: nil) as? CanvasItemCellView
        let shape = Shape.allCases[row]
        rowView?.setUp(shape)
        rowView?.clickHandler = { [weak self] in
            self?.canvasView.beginDrawingSession(shape.canvasItemType())
        }
        return rowView
    }
    
}
