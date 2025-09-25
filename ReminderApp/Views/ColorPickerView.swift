//
//  ColorPickerView.swift
//  ReminderApp
//
//  Created by Raiyan Sharif on 25/9/25.
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var selectColor: Color
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple]
    
    var body: some View {
        HStack{
            ForEach(colors, id: \.self){ color in
                ZStack{
                    Circle().fill()
                        .foregroundColor(color)
                        .padding(2)
                    Circle()
                        .strokeBorder(selectColor == color ? .gray : .clear,lineWidth: 4)
                        .scaleEffect(CGSize(width: 1.2, height: 1.2))
                }
                .onTapGesture {
                    selectColor = color
                }
            }
        }.padding()
            .frame(maxWidth: .infinity, maxHeight: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
    }
}

#Preview {
    NavigationStack{
        ColorPickerView(selectColor: .constant(.yellow))
    }
}
