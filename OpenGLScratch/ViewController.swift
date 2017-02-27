//
//  ViewController.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 2017. 2. 27..
//  Copyright © 2017년 Jagyum Koo. All rights reserved.
//

import Cocoa

// Move this into the proper module
enum SceneType: String {
    case Triangle, Cube, Camera
}

class ViewController: NSViewController {

    @IBOutlet weak var popUpButton: NSPopUpButtonCell!
    @IBOutlet weak var infoLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        popUpButton.removeAllItems()
        let availableScenes = [SceneType.Triangle, SceneType.Cube, SceneType.Camera]
        for i in availableScenes {
            popUpButton.addItem(withTitle: i.rawValue)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func runButton(_ sender: Any) {
        infoLabel.stringValue = popUpButton.titleOfSelectedItem!
    }

}

