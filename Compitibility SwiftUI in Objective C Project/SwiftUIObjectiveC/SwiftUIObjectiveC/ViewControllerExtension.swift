//
//  ViewControllerExtension.swift
//  SwiftUIObjectiveC
//
//  Created by Synesis Sqa on 28/4/25.
//

import Foundation
import SwiftUI

@objc extension ViewController {
    func displaySwiftUIWapper() {
        let hostingViewController = UIHostingController(rootView: SwiftUIView())
        hostingViewController.modalPresentationStyle = .fullScreen
        self.present(hostingViewController, animated: true)
        
    }
}

struct SwiftUIView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Text("Hello, World!")
        Button{
            self.dismiss()
        } label: {
            Text("Dismiss the view!")
        }
    }
}
