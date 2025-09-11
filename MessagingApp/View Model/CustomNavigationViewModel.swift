//
//  CustomNavigationViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/24/25.
//

import Foundation
import SwiftUI

class CustomNavigationViewModel: ObservableObject  {
    @Published var currentXOffset: CGFloat
    @Published var endingXOffset: CGFloat
    @Published var gestureDisabled: Bool
    @Published var viewToShow: (() -> AnyView)?
    @Published var exitSwipeAction: (() -> Void)?
    @Published var duringSwipeAction: (() -> Void)?
    
    init() {
        self.currentXOffset = .zero
        self.endingXOffset = .zero
        self.gestureDisabled = false
    }
    
    static let threshold: CGFloat = UIScreen.main.bounds.width * 0.5
    static let velocityThreshold: CGFloat = 700
    static let maxOffset: CGFloat = UIScreen.main.bounds.width
    
    func onDragChanged(value: DragGesture.Value) {
        let translation = value.translation.width
        if self.endingXOffset == -CustomNavigationViewModel.maxOffset && translation < 0 { return }
        self.currentXOffset = translation
        if let duringSwipeAction {
            duringSwipeAction()
        }
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
                self.endingXOffset = -CustomNavigationViewModel.maxOffset
            } else if self.currentXOffset >= CustomNavigationViewModel.threshold {
                self.endingXOffset = 0
                if let exitSwipeAction {
                    exitSwipeAction()
                }
            }
            self.currentXOffset = 0
        }
    }
    
    func totalXOffset() -> CGFloat {
        return CustomNavigationViewModel.maxOffset + currentXOffset + endingXOffset
    }
    
    func showView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.snappy()) {
                self.endingXOffset = -CustomNavigationViewModel.maxOffset
                self.currentXOffset = .zero
            }
        }
    }
    
    func hideView(completion: @escaping () -> Void = {}) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.snappy()) {
                self.endingXOffset = .zero
                self.currentXOffset = .zero
            }
        }
        
        let animationDuration: Double = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            completion()
        }
    }
}
