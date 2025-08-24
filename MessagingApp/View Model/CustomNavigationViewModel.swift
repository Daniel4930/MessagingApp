//
//  CustomNavigationViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/24/25.
//

import Foundation
import SwiftUI

class CustomNavigationViewModel: ObservableObject  {
    @Published var startingXOffset: CGFloat
    @Published var currentXOffset: CGFloat
    @Published var endingXOffset: CGFloat
    @Published var gestureDisabled: Bool
    
    init() {
        self.startingXOffset = CustomNavigationViewModel.maxOffset
        self.currentXOffset = .zero
        self.endingXOffset = .zero
        self.gestureDisabled = false
    }
    
    static let threshold: CGFloat = UIScreen.main.bounds.width * 0.5
    static let velocityThreshold: CGFloat = 700
    static let maxOffset: CGFloat = UIScreen.main.bounds.width
    
    func onDragChanged(_ value: DragGesture.Value) {
        let translation = value.translation.width
        if self.endingXOffset == -CustomNavigationViewModel.maxOffset && translation < 0 { return }
        self.currentXOffset = translation
    }
    
    func onDragEnded(_ value: DragGesture.Value) {
        let velocity = value.velocity.width
        
        withAnimation(.snappy()) {
            if velocity >= CustomNavigationViewModel.velocityThreshold {
                self.currentXOffset = CustomNavigationViewModel.maxOffset
            } else if velocity <= -CustomNavigationViewModel.velocityThreshold {
                self.currentXOffset = -CustomNavigationViewModel.maxOffset
            }
            
            if self.currentXOffset <= -CustomNavigationViewModel.threshold {
                self.endingXOffset = -self.startingXOffset
            } else if self.currentXOffset >= CustomNavigationViewModel.threshold {
                self.endingXOffset = 0
            }
            self.currentXOffset = 0
        }
    }
    
    func totalXOffset() -> CGFloat {
        return startingXOffset + currentXOffset + endingXOffset
    }
}
