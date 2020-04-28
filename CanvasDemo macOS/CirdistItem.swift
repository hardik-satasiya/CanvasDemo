//
//  CircleDistItem.swift
//  CanvasDemo macOS
//
//  Created by Chen on 2020/4/23.
//  Copyright © 2020 vitiny. All rights reserved.
//

import Foundation
import CoreGraphics

import Canvas

class CirdistItem: FixedElementItem, Fallbackable {
    
    private(set) var circles: [Circle] = []
    
    private var lines: [Line] = []
    
    required init() {
        super.init(elements: 4, minSegments: 2)
    }
    
    override func push(_ point: CGPoint) {
        if isEmpty { super.push(point) }
        super.push(point)
    }
    
    override func push(toNextSegment point: CGPoint) {
        if grid.last?.count == elements {
            super.push(toNextSegment: point)
            super.push(point)
        }
        else {
            super.push(toNextSegment: point)
        }
        super.push(toNextSegment: point)
        if grid.last?.count == elements {
            super.push(point)
        }
    }
    
    func updateCircles() {
        circles = grid
            .filter{ $0.count == elements }
            .compactMap { Circle($0[1], $0[2], $0[3]) }
        circles.enumerated()
            .map { (StackIndex(element: 0, segment: $0), $1.center) }
            .forEach { super.update(point: $1, at: $0) }
        
        if circles.count >= 2 {
            lines = circles.dropLast().enumerated().map { i, circle in
                Line(from: circle.center, to: circles[i + 1].center)
            }
        }
    }
    
    override func update(point: CGPoint, at index: StackIndex) {
        if index.element == 0 && isCompleted {
            let old = grid[index.segment][index.element]
            let dx = point.x - old.x, dy = point.y - old.y
            beginBatchUpdate()
            for (i, point) in grid[index.segment][1...].enumerated() {
                let newPoint = CGPoint(x: point.x + dx, y: point.y + dy)
                let index = StackIndex(element: i + 1, segment: index.segment)
                super.update(point: newPoint, at: index)
            }
            commitBatchUpdate()
        } else {
            super.update(point: point, at: index)
        }
    }
    
    override func linePathWrappers() -> [PathWrapper] {
        grid.filter { $0.count > 1 }
            .map { points in
                PathWrapper(method: .dash(lineWidth, 2, [2, 2]), color: strokeColor) {
                    $0.addLines(between: Array(points.dropFirst()))
                }
            }
    }
    
    override func mainPathWrappers() -> [PathWrapper] {
        updateCircles()
        
        let circlePaths = circles.reduce([PathWrapper]()) { (paths, circle)  in
            paths + [
                PathWrapper(method: .stroke(lineWidth), color: strokeColor) { $0.addCircle(circle) },
                PathWrapper(method: .fill, color: strokeColor) { $0.addCircle(Circle(center: circle.center, radius: 3)) }
            ]
        }
        let linePath = PathWrapper(method: .stroke(lineWidth), color: strokeColor) { path in lines.forEach(path.addLine) }
        
        return circlePaths + [linePath]
    }
    
    override func canSelect(by rect: CGRect) -> Bool {
        circles.contains { $0.canSelect(by: rect) } || lines.contains { $0.canSelect(by: rect) }
    }
    
}
