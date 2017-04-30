//
//  ClusterAnnotationView.swift
//  SwiftyMaugry
//
//  Created by Вероника Гайнетдинова on 30.03.17.
//  Copyright © 2017 msl. All rights reserved.
//

import MapKit
import SnapKit

class ClusterAnnotationView: MKAnnotationView {

    /*
     Radius of annotation view is calculated based on the annotation weight.
     Formula: baseSize + growth / 100 * weight
     */

    private let infoLabel = UILabel()
    private let backCircleView = UIView()
    private var heightConstraint: Constraint?

    var annotationWeight: Int = 0 {
        didSet { updateHeightConstraint() }
    }
    var baseSize: Int = 16 {
        didSet { updateHeightConstraint() }
    }
    var multiplier: Double = 0.1 {
        didSet { updateHeightConstraint() }
    }

    private var actualSize: Int {
        return min(baseSize + lround(multiplier * Double(annotationWeight)), 40)
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        onInitActions()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        onInitActions()
    }

    private func onInitActions() {
        backCircleView.layer.cornerRadius = 0.5 * CGFloat(actualSize)
        backCircleView.clipsToBounds = true
        backCircleView.backgroundColor = UIColor.untScarlet

        infoLabel.textColor = .white
        infoLabel.font = UIFont.untTextRegular11PtFont()

        addSubview(backCircleView)
        backCircleView.addSubview(infoLabel)

        backCircleView.snp.makeConstraints { (make) in
            self.heightConstraint = make.height.equalTo(self.baseSize).constraint
            make.width.equalTo(self.backCircleView.snp.height)
            make.center.equalToSuperview()
        }

        infoLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

    private func updateHeightConstraint() {
        backCircleView.layer.cornerRadius = 0.5 * CGFloat(actualSize)
        backCircleView.snp.updateConstraints { (update) in
            update.height.equalTo(self.actualSize)
        }
    }

    func bind(weight: Int, baseSize: Int = 16, multiplier: Double = 0.5) {
        annotationWeight = weight
        self.baseSize = baseSize
        self.multiplier = multiplier

        infoLabel.text = "\(weight)"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
