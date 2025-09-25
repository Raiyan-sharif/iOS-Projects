//
//  AddMyListScreen.swift
//  ReminderApp
//
//  Created by Raiyan Sharif on 25/9/25.
//

import SwiftUI

struct AddMyListsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var color: Color = .blue
    @State private var listName: String = ""
    
    var body: some View {
        VStack{
            Image(systemName: "line.3.horizontal.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(color)

            TextField("Last Name", text: $listName)
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .trailing],44)
            ColorPickerView(selectColor: $color)
        }
        .navigationTitle("New List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem( placement: .topBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
            
            ToolbarItem( placement: .topBarTrailing) {
                Button("Done") {
                    
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        AddMyListsScreen()
    }
}


