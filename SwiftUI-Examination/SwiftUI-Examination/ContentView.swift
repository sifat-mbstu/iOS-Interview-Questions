//
//  ContentView.swift
//  SwiftUI-Examination
//
//  Created by Sifatul on 27/6/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

func returnView() -> any View {
    return Text("w3e")
    return Rectangle()
}

#Preview {
    ContentView()
}
