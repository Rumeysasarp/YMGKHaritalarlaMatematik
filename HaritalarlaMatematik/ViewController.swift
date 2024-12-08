//
//  ViewController.swift
//  HaritalarlaMatematik
//
//  Created by Zehra Öner on 8.12.2024.
//
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var regions: [SCNNode] = [] // Haritadaki bölgeleri temsil eden düğümler
    
    // Verilen X ve Y koordinatları
    let coordinates: [(x: Float, y: Float)] = [
        (656, 937), (263, 945), (1110, 820), (464, 825), (767, 896),
        (1609, 781), (1225, 763), (927, 753), (1044, 682), (242, 755),
        (475, 672), (947, 568), (1355, 660), (719, 661), (1589, 607),
        (538, 501), (1219, 484), (846, 414), (349, 463), (517, 323),
        (738, 385), (974, 392), (1112, 300), (657, 296), (1172, 225),
        (1459, 346), (1280, 217), (1477, 183), (1333, 113)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ARSceneView ayarları
        sceneView.delegate = self
        sceneView.scene = SCNScene()

        // Haritayı ekle
        addMapImage()
        
        // Koordinatlara göre düğümler ekle
        addRegionNodes()

        // Dokunma algılayıcıyı ekle
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // AR oturumunu başlat
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // AR oturumunu duraklat
        sceneView.session.pause()
    }
    
    // Haritayı bir SCNPlane üzerine yerleştirme
    func addMapImage() {
        let mapPlane = SCNPlane(width: 0.5, height: 0.5) // Haritanın boyutlarını küçülttük
        let mapMaterial = SCNMaterial()
        mapMaterial.diffuse.contents = UIImage(named: "harita") // Harita görseli
        mapPlane.materials = [mapMaterial]

        let mapNode = SCNNode(geometry: mapPlane)
        mapNode.position = SCNVector3(0, 0, -1) // Kameranın önünde konumlandır
        mapNode.eulerAngles = SCNVector3(0, 0, 0) // Haritayı düz yerleştir

        sceneView.scene.rootNode.addChildNode(mapNode)
    }
    
    // Koordinatlara göre düğümler ekleme
    func addRegionNodes() {
        for (index, coordinate) in coordinates.enumerated() {
            let region = createRegion(at: SCNVector3(coordinate.x / 1000, 0.0, -Float(index + 1)), name: "Region\(index + 1)")
            regions.append(region)
            sceneView.scene.rootNode.addChildNode(region)
        }
    }

    // Bölge düğümü oluşturma
    func createRegion(at position: SCNVector3, name: String) -> SCNNode {
        let regionPlane = SCNPlane(width: 0.2, height: 0.2) // Bölgenin boyutları
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.5) // Başlangıç rengi yarı saydam beyaz
        regionPlane.materials = [material]
        
        let node = SCNNode(geometry: regionPlane)
        node.name = name
        node.position = position
        node.eulerAngles.x = -.pi / 2
        return node
    }
    
    // Dokunma algılandığında çalışacak
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touchLocation, options: nil)

        if let hitResult = hitTestResults.first {
            print("Seçilen bölge: \(hitResult.node.name ?? "İsimsiz Node")")
            changeColor(of: hitResult.node) // Sadece tıklanan bölgeyi renklendir
        } else {
            print("Hiçbir bölge seçilmedi.")
        }
    }
    
    // Dokunulan bölgenin rengini değiştirme
    func changeColor(of node: SCNNode) {
        guard let material = node.geometry?.firstMaterial else { return }
        
        // Renkler dizisini tanımla
        let availableColors: [UIColor] = [.red, .blue, .green, .yellow]
        
        // Mevcut rengi al
        let currentColor = material.diffuse.contents as? UIColor

        // Mevcut renk ile aynı olanı filtrele
        let newColor = availableColors.filter { $0 != currentColor }.randomElement() ?? .white
        
        // Yeni rengi uygula
        material.diffuse.contents = newColor
    }
}
