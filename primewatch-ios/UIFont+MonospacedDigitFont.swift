import UIKit

extension UIFont {

  var monospacedDigitFont: UIFont {
    let oldFontDescriptor = fontDescriptor
    let newFontDescriptor = oldFontDescriptor.monospacedDigitFontDescriptor
    return UIFont(descriptor: newFontDescriptor, size: 0)
  }

}

private extension UIFontDescriptor {

  var monospacedDigitFontDescriptor: UIFontDescriptor {
    let fontDescriptorFeatureSettings = [[UIFontFeatureTypeIdentifierKey: kNumberSpacingType, UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector]]
    let fontDescriptorAttributes = [UIFontDescriptorFeatureSettingsAttribute: fontDescriptorFeatureSettings]
    let fontDescriptor = self.addingAttributes(fontDescriptorAttributes)
    return fontDescriptor
  }

}