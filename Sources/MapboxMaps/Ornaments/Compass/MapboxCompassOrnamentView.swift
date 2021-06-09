import CoreLocation
import UIKit

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

internal class MapboxCompassOrnamentView: UIButton {
    private enum Constants {
        static let localizableTableName = "OrnamentsLocalizable"
        static let compassSize = CGSize(width: 40, height: 40)
        static let animationDuration: TimeInterval = 0.3
    }

    internal var containerView = UIImageView()
    internal var visibility: OrnamentVisibility = .adaptive {
        didSet {
            animateVisibilityUpdate()
        }
    }

    internal var tapAction: (() -> Void)?

    private var compassBackgroundColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    private var needleColor: UIColor = #colorLiteral(red: 0.9971256852, green: 0.2427211106, blue: 0.196741581, alpha: 1)
    private var lineColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    private let directionFormatter: CompassDirectionFormatter = {
        let formatter = CompassDirectionFormatter()
        formatter.style = .short
        return formatter
    }()
    /// Should be in range [-pi; pi]
    internal var currentBearing: CLLocationDirection = 0 {
        didSet {
            let adjustedBearing = currentBearing.truncatingRemainder(dividingBy: 360)
            animateVisibilityUpdate()
            self.containerView.transform = CGAffineTransform(rotationAngle: -adjustedBearing.toRadians())
        }
    }

    required internal init(visibility: OrnamentVisibility) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.visibility = visibility
        containerView.isHidden = visibility != .visible
        let bundle = Bundle.mapboxMaps
        accessibilityLabel = NSLocalizedString("COMPASS_A11Y_LABEL",
                                               tableName: Constants.localizableTableName,
                                               bundle: bundle,
                                               value: "Compass",
                                               comment: "Accessibility label")
        accessibilityHint = NSLocalizedString("COMPASS_A11Y_HINT",
                                              tableName: Constants.localizableTableName,
                                              bundle: bundle,
                                              value: "Rotates the map to face due north",
                                              comment: "Accessibility hint")

        if let image = createCompassImage() {
            containerView.image = image
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalToConstant: image.size.width),
                heightAnchor.constraint(equalToConstant: image.size.height),
                containerView.widthAnchor.constraint(equalToConstant: image.size.width),
                containerView.heightAnchor.constraint(equalToConstant: image.size.height)
            ])
        }
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc internal func didTap() {
        tapAction?()
    }

    private func animateVisibilityUpdate() {
        switch visibility {
        case .visible:
            animate(toHidden: false)
        case .hidden:
            animate(toHidden: true)
        case .adaptive:
            animate(toHidden: abs(currentBearing) < 0.001)
        }
    }

    private func animate(toHidden isHidden: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.containerView.isHidden = isHidden
        }
    }

    // swiftlint:disable function_body_length
    private func createCompassImage() -> UIImage? {
        
        let assetImage = UIImage(named: "compass", in: .mapboxMaps, compatibleWith: nil)!
        UIGraphicsBeginImageContextWithOptions(Constants.compassSize, false, UIScreen.main.scale)
        
        assetImage.draw(in: CGRect(origin: .zero, size: Constants.compassSize))
        
        let northFont = UIFont.systemFont(ofSize: 11, weight: .light)
        let northLocalized = directionFormatter.string(from: 0)
        let north = NSAttributedString(string: northLocalized, attributes:
            [
                NSAttributedString.Key.font: northFont,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ])
        let stringRect = CGRect(x: (Constants.compassSize.width - north.size().width) / 2,
                                y: Constants.compassSize.height * 0.435,
                                width: north.size().width,
                                height: north.size().height)
        north.draw(in: stringRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }
}

private extension CLLocationDirection {
    func toRadians() -> CGFloat {
        return CGFloat(self * Double.pi / 180.0)
    }
}
