import MapboxMaps
import Turf

@objc(LineLayerWithTerrainExample)

class LineLayerWithTerrainExample: UIViewController, ExampleProtocol {
    var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize a `MapView` with a camera centered over Santa Catalina Island, California and a bearing of 215º.
        let center = CLLocationCoordinate2D(latitude: 33.33470, longitude: -118.33283)
        let cameraOptions = CameraOptions(center: center, zoom: 14, bearing: 215)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .satelliteStreets)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addTerrain()
        }
    }

    func addTerrain() {
        // Add terrain to the map using the Mapbox Terrain-DEM source. https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/#raster-dem
        var demSource = RasterDemSource()
        demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
        // Setting the `tileSize` to 514 provides better performance and adds padding around the outside
        // of the tiles.
        demSource.tileSize = 514
        demSource.maxzoom = 14.0

        var terrain = Terrain(sourceId: "mapbox-dem")
        terrain.exaggeration = .constant(1.7)

        let style = mapView.mapboxMap.style
        do {
            // Add 3D terrain to the `MapView`.
            try style.addSource(demSource, id: "mapbox-dem")
            try style.setTerrain(terrain)

            addGeoJSONLine()
        } catch {
            print("Failed to display terrain on the map. Error: \(error.localizedDescription)")
        }
    }

    func addGeoJSONLine() {
        let sourceId = "marathon-route-source"

        // Create a `GeoJSONSource` from a file. The line geometry represents
        // the route for the Catalina Eco Marathon.
        let url = Bundle.main.url(forResource: "marathon_route", withExtension: "geojson")!
        var source = GeoJSONSource()
        source.data = .url(url)

        var lineLayer = LineLayer(id: "marathon-route-layer")
        lineLayer.source = sourceId
        let lineColor = UIColor(red: 1.00, green: 0.31, blue: 0.24, alpha: 1.00)
        lineLayer.lineColor = .constant(ColorRepresentable(color: lineColor))
        lineLayer.lineWidth = .constant(5)

        let style = mapView.mapboxMap.style
        do {
            try style.addSource(source, id: sourceId)
            try style.addLayer(lineLayer)

            animateCamera()
        } catch {
            print("Failed to add a `LineLayer`. Error: \(error.localizedDescription)")
        }
    }

    func animateCamera() {
        _ = mapView.mapboxMap.queryRenderedFeatures(in: view.bounds, options: RenderedQueryOptions(layerIds: ["marathon-route-layer"], filter: nil)) { [weak self] result in
            switch result {
            case .success(let queriedFeatures):
                let line = queriedFeatures.first as Turf.Feature
            case .failure(let error):
                print("Error querying rendered features: \(error.localizedDescription)")
            }
        }
    }
}
