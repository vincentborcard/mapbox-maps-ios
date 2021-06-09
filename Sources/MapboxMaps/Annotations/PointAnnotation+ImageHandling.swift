import UIKit
@_implementationOnly import MapboxCommon_Private

extension PointAnnotation {
    public enum Image: Hashable {
        case `default`
        case custom(image: UIImage, name: String)

        var name: String {
            switch self {
            case .default:
                return "com.mapbox.maps.annotations.point.image.default"
            case .custom(image: _, name: let name):
                return name
            }
        }
    }
}

extension PointAnnotationManager {

    func addImageToStyleIfNeeded(style: Style?) {
        guard let style = style else { return }
        let pointAnnotationImages = Set(annotations.compactMap(\.image))
        for pointAnnotationImage in pointAnnotationImages {
            do {
                let image = style.image(withId: pointAnnotationImage.name)

                if image == nil { // If image not found, then add the image to  the style
                    switch pointAnnotationImage {

                    case .default: // Add the default image if not added already
                        let image = UIImage(named: "default_marker", in: Bundle.mapboxMaps, compatibleWith:  nil)!
                        try style.addImage(
                            image,
                            id: pointAnnotationImage.name)

                    case .custom(image: let image, name: let name): // Add this custom image
                        try style.addImage(image, id: name)
                    }
                }
            } catch {
                Log.warning(
                    forMessage: "Could not add image to style in PointAnnotationManager due to error: \(error)",
                    category: "Annnotations")
            }
        }
    }

    internal static var defaultSize: CGSize {
        CGSize(width: 20, height: 32)
    }
}
