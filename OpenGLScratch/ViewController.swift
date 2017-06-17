//
//  ViewController.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 2017. 2. 27..
//  Copyright © 2017년 Jagyum Koo. All rights reserved.
//

import Cocoa

// Move these into the proper module
enum SceneType: String {
    case Triangle, Rectangle, TriangleTexture, RectangleTexture, RectangleRotation, RectanglePerspective, Cube, NCubes, NCubesWithCamera, LightingAndLamp, Circle, SpinningLamp, LightingWithMaterial, LightingWithMaps, DirectionalLight, PointLight, SpotLight, MultipleLights, Model, DepthTest, StencilOutline, GrassBlend
}

enum PolygonMode: String {
    case FILL, LINE, POINT
}

class ViewController: NSViewController {

    @IBOutlet weak var rendererSelector: NSPopUpButtonCell!
    @IBOutlet weak var polygonModeSelector: NSPopUpButtonCell!
    @IBOutlet weak var openGLView: MyOpenGLView!

    let renderers: [SceneType : MyOpenGLRendererDelegate?] = [
        SceneType.Triangle: TriangleRenderer(),
        SceneType.Rectangle: RectangleRenderer(),
        SceneType.Circle: CircleRenderer(),
        SceneType.SpinningLamp: SpinningLampRenderer(),
        SceneType.MultipleLights: MultipleLightsRenderer(),
        SceneType.Model: ModelRenderer(),
        SceneType.DepthTest: DepthTestRenderer(),
        SceneType.StencilOutline: StencilOutlineRenderer(),
        SceneType.GrassBlend: GrassBlendRenderer(),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for i in self.renderers.keys {
            rendererSelector.addItem(withTitle: i.rawValue)
        }

        let availableModes = [PolygonMode.FILL, PolygonMode.LINE, PolygonMode.POINT]
        for i in availableModes {
            polygonModeSelector.addItem(withTitle: i.rawValue)
        }

        self.selectRenderer(self.rendererSelector)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func selectRenderer(_ sender: Any) {
        if let name = rendererSelector.titleOfSelectedItem, let sceneType = SceneType(rawValue:name), let renderer = self.renderers[sceneType] {
            openGLView.renderer = renderer
        }
        else {
            openGLView.renderer = nil
        }
        openGLView.needsDisplay = true
    }

    @IBAction func selectPolygonMode(_ sender: Any) {
        if let name = polygonModeSelector.titleOfSelectedItem {
            openGLView.polygonMode = name
            self.selectRenderer(self.rendererSelector)
        }
    }
}

