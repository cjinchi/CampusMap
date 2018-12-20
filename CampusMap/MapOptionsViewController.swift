//
//  MapOptionsViewController.swift
//  CampusMap
//
//  Created by Chun on 2018/11/27.
//  Copyright © 2018 Nemoworks. All rights reserved.
//

import UIKit


enum MapOptionsType: Int {
    case mapBoundary = 0
    case mapPOIsCanteen
    case mapPOIsShopping
    case mapPOIsDormitory
    case mapPOIsOfficial
    case mapPOIsStudy
    case mapPOIsNature
    case mapPOIsExercise
    case mapPOIsHospital
    
    func displayName() -> String {
        switch (self) {
        case .mapBoundary:
            return "校园边界"
        case .mapPOIsOfficial:
            return "行政办公"
        case .mapPOIsStudy:
            return "教学场所"
        case .mapPOIsNature:
            return "自然景物"
        case .mapPOIsExercise:
            return "健身运动"
        case .mapPOIsCanteen:
            return "食堂"
        case .mapPOIsShopping:
            return "超市"
        case .mapPOIsDormitory:
            return "学生宿舍"
        case .mapPOIsHospital:
            return "医院"
        }
    }
    func image() -> UIImage {
        switch (self) {
        case .mapBoundary:
            return #imageLiteral(resourceName: "star")
        case .mapPOIsOfficial:
            return #imageLiteral(resourceName: "office")
        case .mapPOIsStudy:
            return #imageLiteral(resourceName: "book")
        case .mapPOIsNature:
            return #imageLiteral(resourceName: "moutain")
        case .mapPOIsExercise:
            return #imageLiteral(resourceName: "gym")
        case .mapPOIsCanteen:
            return #imageLiteral(resourceName: "food-1")
        case .mapPOIsShopping:
            return #imageLiteral(resourceName: "shop")
        case .mapPOIsDormitory:
            return #imageLiteral(resourceName: "home")
        case .mapPOIsHospital:
            return #imageLiteral(resourceName: "hospital")
    }
}
}

class MapOptionsViewController: UIViewController {

    var selectedOptions = [MapOptionsType]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - UITableViewDataSource
extension MapOptionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell")!
        
        if let mapOptionsType = MapOptionsType(rawValue: indexPath.row) {
            cell.textLabel!.text = mapOptionsType.displayName()
            cell.accessoryType = selectedOptions.contains(mapOptionsType) ? .checkmark : .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MapOptionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let mapOptionsType = MapOptionsType(rawValue: indexPath.row) else { return }
        
        if (cell.accessoryType == .checkmark) {
            // Remove option
            selectedOptions = selectedOptions.filter { $0 != mapOptionsType}
            cell.accessoryType = .none
        } else {
            // Add option
            selectedOptions += [mapOptionsType]
            cell.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
