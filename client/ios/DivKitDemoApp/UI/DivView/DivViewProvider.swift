import SwiftUI

import DivKit

final class DivViewProvider {
  public let jsonProvider = ObservableJsonProvider()
  
  private var blockProvider: DivBlockProvider!
  private var divKitComponents: DivKitComponents!
  
  init() {
    divKitComponents = DemoAppComponents.makeDivKitComponents(
      updateCardAction: { [weak self] _, patch in
        self?.blockProvider.update(patch: patch)
      }
    )

    blockProvider = DivBlockProvider(
      json: jsonProvider.signal,
      divKitComponents: divKitComponents
    )
  }

  func makeDivView(_ url: URL) -> some View {
    DivView(
      blockProvider: blockProvider,
      divKitComponents: divKitComponents
    )
    .onAppear { [weak self] in
      self?.jsonProvider.load(url: url)
    }
  }
}
