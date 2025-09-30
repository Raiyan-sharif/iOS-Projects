//
//  MyListsScreen.swift
//  ReminderApp
//
//  Created by Raiyan Sharif on 25/9/25.
//

import SwiftUI
import SwiftData

struct MyListsScreen: View {
    
    let myLists = ["Reminders", "To-Do", "Shopping List" ]
    
    @State private var isPresented: Bool = false
    
    var body: some View {
        List{
            Text("My Lists")
                .font(.largeTitle)
                .bold()
            ForEach(myLists, id: \.self) { myList in
                HStack{
                    Image(systemName: "line.3.horizontal.circle.fill")
                        .font(.system(size: 32))
                    Text(myList)
                }
            }
            
            Button(action: {
                isPresented = true
            }, label: {
                Text("Add list")
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            })
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .sheet(isPresented: $isPresented, content: {
            NavigationStack{
                AddMyListsScreen()
            }
        })
        
    }
}

#Preview {
    NavigationStack{
        MyListsScreen()
    }
}
