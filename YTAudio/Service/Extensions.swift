//
//  Extensions.swift
//  YTAudio
//
//  Created by Ion Socol on 12/10/24.
//

import UIKit
// MARK: - UIColor Extension
extension UIColor {
    func interpolate(to color: UIColor, fraction: CGFloat) -> UIColor {
        let f = min(max(fraction, 0), 1) // Clamping pentru intervalul 0 - 1
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        let red = r1 + (r2 - r1) * f
        let green = g1 + (g2 - g1) * f
        let blue = b1 + (b2 - b1) * f
        let alpha = a1 + (a2 - a1) * f

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
