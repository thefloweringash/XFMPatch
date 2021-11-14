//
//  SectionView.swift
//  XFMPatch
//
//  Created by Andrew Childs on 2021/11/14.
//

import SwiftUI

struct SectionView<C: View> : View {
    public let title: String
    @ViewBuilder public let content: () -> C

    public init(_ title: String, @ViewBuilder content: @escaping () -> C) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.largeTitle)
            content()
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerSize: .init(width: 20, height: 20)))
    }
}

struct SectionView_Preview: PreviewProvider {
    static var previews: some View {
        SectionView("Matrix") {
          MatrixView(matrix: Matrix())
        }
    }
}
