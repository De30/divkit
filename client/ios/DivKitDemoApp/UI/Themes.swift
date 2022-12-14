import SwiftUI

enum ThemeColor {
  static let divKit = Color(red: 1, green: 0x90 / 255, blue: 0)
  static let regression = Color(red: 0xCC / 255, green: 0x2F / 255, blue: 0xD5 / 255)
  static let samples = Color(red: 0x5A / 255, green: 0x43 / 255, blue: 0xE3 / 255)
  static let settings = Color.black
}

enum ThemeSize {
  static let cornerRadius: CGFloat = 36
  static let header: CGFloat = 56
}

enum ThemeFont {
  static let button: Font = makeRegular(size: 24)
  static let text: Font = makeRegular(size: 18)

  static func makeRegular(size: CGFloat) -> Font {
    .custom(YSFontProvider.regularFontName, size: size)
  }

  static func makeMedium(size: CGFloat) -> Font {
    .custom(YSFontProvider.mediumFontName, size: size)
  }
}

extension Image {
  func applyHeaderButtonStyle() -> some View {
    self
      .resizable()
      .scaledToFit()
      .padding(16)
      .frame(height: ThemeSize.header)
      .foregroundColor(.white)
  }
}
