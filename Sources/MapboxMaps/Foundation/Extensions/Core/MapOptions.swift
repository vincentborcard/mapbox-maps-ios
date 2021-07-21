@_spi(Internal) import MapboxCoreMaps

extension MapOptions {
    public init(constrainMode: ConstrainMode = .heightOnly,
                viewportMode: ViewportMode = .default,
                orientation: NorthOrientation = .upwards,
                crossSourceCollisions: Bool = true,
                optimizeForTerrain: Bool = true,
                size: CGSize? = nil,
                pixelRatio: Float = Float(UIScreen.main.scale),
                glyphsRasterizationOptions: GlyphsRasterizationOptions = GlyphsRasterizationOptions(fontFamilies: [])) {
        self.init(_contextMode: nil,
                  constrainMode: constrainMode,
                  viewportMode: viewportMode,
                  orientation: orientation,
                  crossSourceCollisions: crossSourceCollisions,
                  optimizeForTerrain: optimizeForTerrain,
                  size: size.map(Size.init(_:)),
                  pixelRatio: pixelRatio,
                  glyphsRasterizationOptions: glyphsRasterizationOptions)
    }

    public var size: CGSize? {
        get {
            _size.map(CGSize.init(_:))
        }
        set {
            _size = newValue.map(Size.init(_:))
        }
    }
}
