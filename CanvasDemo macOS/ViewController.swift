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
    @IBOutlet weak var rotationSwitch: NSButton!
    @IBOutlet weak var rotationResetButton: NSButton!
    
    var selectedRow: Int? { tableView.selectedRow != -1 ? tableView.selectedRow : nil }
    var selectedItemIndex: Int? { canvasView.selectedItemIndexes.count == 1 ? canvasView.selectedItemIndexes.first : nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpObservers()
        updateUI()
    }
    
    func setUpUI() {
        tableView.delegate = self
        tableView.dataSource = self
        canvasView.layer?.backgroundColor = .white
        canvasView.delegate = self
    }
    
    func setUpObservers() {
        let notiNames: [Notification.Name] = [
            .canvasViewSessionDidFinish, .canvasViewSessionDidCancel, .canvasViewItemDidEndEditing, .canvasViewSelectionDidChange,
            .NSUndoManagerDidUndoChange, .NSUndoManagerDidRedoChange, .NSUndoManagerDidOpenUndoGroup
        ]
        notiNames.forEach { name in
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { _ in
                self.updateUI()
            }
        }
    }
    
    func updateUI() {
        deleteButton.isEnabled = !canvasView.selectedItemIndexes.isEmpty
        undoButton.isEnabled = undoManager?.canUndo ?? false
        redoButton.isEnabled = undoManager?.canRedo ?? false
        rotationSwitch.state = canvasView.canRotateItem ? .on : .off
        if let idx = selectedItemIndex {
            let item = canvasView.items[idx]
            colorWell.color = item.strokeColor
            rotationResetButton.isEnabled = true
        } else {
            colorWell.color = canvasView.strokeColor
            rotationResetButton.isEnabled = false
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
    
    @IBAction func rotationSwitchValueChanged(_ sender: NSButton) {
        canvasView.canRotateItem = sender.state == .on
    }
    
    @IBAction func resetRotation(_ sender: Any) {
        if let idx = selectedItemIndex {
            canvasView.rotateItem(angle: 0, at: idx)
        }
    }
    
    @objc func clearItems(_ sender: NSMenuItem) {
        canvasView.removeAllItems()
    }
    
    @objc func clearEverything(_ sender: NSMenuItem) {
        canvasView.removeAllItems()
        undoManager?.removeAllActions()
    }
    
    @objc func deleteSelection(_ sender: NSMenuItem) {
        canvasView.removeItems(at: canvasView.selectedItemIndexes)
    }
    
}

extension ViewController: CanvasViewDelegate {
    
    func menu(for canvasView: CanvasView) -> NSMenu? {
        let menu = NSMenu()
        let hasItems = !canvasView.items.isEmpty, canUndo = undoManager?.canUndo ?? false, canRedo = undoManager?.canRedo ?? false
        let canClearAll = hasItems || canUndo || canRedo
        menu.addItem(withTitle: "Clear", action: hasItems ? #selector(clearItems) : nil, keyEquivalent: "")
        menu.addItem(withTitle: "Clear(All)", action: canClearAll ? #selector(clearEverything(_:)) : nil, keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Undo", action: canUndo ? #selector(undo(_:)) : nil, keyEquivalent: "")
        menu.addItem(withTitle: "Redo", action: canRedo ? #selector(redo(_:)) : nil, keyEquivalent: "")
        return menu
    }
    
    func menuForItems(in canvasView: CanvasView, at indexes: IndexSet) -> NSMenu? {
        let menu = NSMenu()
        menu.addItem(withTitle: "Delete \(indexes.count) Item\(indexes.count > 1 ? "s" : "")", action: #selector(deleteSelection), keyEquivalent: "")
        menu.items.first?.representedObject = index
        return menu
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
