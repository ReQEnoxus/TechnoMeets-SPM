//
//  MainView.swift
//  MainView
//
//  Created by Enoxus on 19.09.2021.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Text(L10n.Common.hello)
                .font(.system(size: 72, weight: .bold))
        }
    }
}
