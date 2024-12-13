//
//  CustomSlider.swift
//  YTAudio
//
//  Created by Ion Socol on 12/10/24.
//

import UIKit

final class CustomSlider: UISlider {
    
    private let baseLayer = CALayer() // Fundalul slider-ului (darkGray)
    private let progressLayer = CALayer() // Progresul slider-ului
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup
    private func setup() {
        clearDefaults()
        createBaseLayer()
        createProgressLayer()
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        updateProgressLayer() // Setăm progresul la început
    }

    private func clearDefaults() {
        tintColor = .clear
        maximumTrackTintColor = .clear
        minimumTrackTintColor = .clear
        thumbTintColor = .clear
    }
    
    // MARK: - Base Layer (Fundal DarkGray)
    private func createBaseLayer() {
        baseLayer.backgroundColor = UIColor.darkGray.cgColor
        baseLayer.cornerRadius = 4
        baseLayer.masksToBounds = true
        layer.insertSublayer(baseLayer, at: 0)
    }
    
    // MARK: - Progress Layer
    private func createProgressLayer() {
        progressLayer.cornerRadius = 4
        progressLayer.masksToBounds = true
        layer.insertSublayer(progressLayer, above: baseLayer)
    }
    
    // MARK: - Actualizare Progres
    @objc private func valueChanged() {
        updateProgressLayer()
    }
    
    public func updateProgressLayer() {
        let progress = CGFloat((value - minimumValue) / (maximumValue - minimumValue))
        let progressWidth = progress * bounds.width
        
        CATransaction.begin()
        CATransaction.setDisableActions(true) // Eliminăm animațiile implicite
        progressLayer.frame = CGRect(
            x: 0,
            y: (bounds.height - 8) / 2,
            width: progressWidth,
            height: 8
        )
        progressLayer.backgroundColor = getDynamicColor(for: progress).cgColor
        CATransaction.commit()
    }

    // Se apelează automat când se redimensionează slider-ul sau se creează
    override func layoutSubviews() {
        super.layoutSubviews()

        // Reglează dimensiunea la redimensionare
        baseLayer.frame = CGRect(
            x: 0,
            y: (bounds.height - 8) / 2,
            width: bounds.width,
            height: 8
        )
        
        let progress = CGFloat((value - minimumValue) / (maximumValue - minimumValue))
        progressLayer.frame = CGRect(
            x: 0,
            y: (bounds.height - 8) / 2,
            width: progress * bounds.width,
            height: 8
        )
    }

    // MARK: - Generare Culoare Dinamică
    private func getDynamicColor(for progress: CGFloat) -> UIColor {
        let startColor = UIColor.white
        let endColor = UIColor(red: 236 / 255, green: 99 / 255, blue: 91 / 255, alpha: 1.0)
        return startColor.interpolate(to: endColor, fraction: progress)
    }
}
