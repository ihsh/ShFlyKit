//
//  HealthTestVC.swift
//  SHKit
//
//  Created by hsh on 2019/2/12.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

class HealthTestVC: UITableViewController {

    let actionArr:NSArray = ["步行跑步距离","步数","心率","骑行距离","睡眠","身高","体重","性别","生日","卡路里","静息能量","写入步数","写入步行距离","写入骑行","写入睡眠时间"]
    let health = HealthKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let str = actionArr[indexPath.row];
        cell.textLabel?.text = str as? String;
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            health.distance(for: HealthKit.predicateForToday(), completionHandler: { (distance, error) in
                print("步行及跑步距离\(distance)");
            });
        case 1:
            health.step(for: HealthKit.predicateForToday(), completionHandler: { (step, error) in
                print("步数\(step)");
            })
        case 2:
            health.healthRate(for: HealthKit.predicate(forPreday: 10), completionHandler: { (items, error) in
                for item in items!{
                    print(item);
                }
            })
        case 3:
            health.cycle(for: HealthKit.predicateForToday(), completionHandler: { (dis, error) in
                print("骑行距离\(dis)");
            })
        case 4:
            health.sleepAnalysis({ (sec, error) in
                print("睡眠时间\(sec/60)分钟");
            })
        case 5:
            health.height({ (height, error) in
                print(height);
            })
        case 6:
            health.mass({ (mass, error) in
                print(mass);
            })
        case 7:
            health.sexQuery { (sex, error) in
                print(sex?.description);
            }
        case 8:
            health.birthQuery { (birth, error) in
                print(birth?.description);
            }
        case 9:
            health.calorieActive(for: HealthKit.predicate(forPreday: 3)) { (calorie, error) in
                print(calorie);
            }
        case 10:
            health.calorieBasal(for: HealthKit.predicate(forPreday: 3)) { (calorie, error) in
                print(calorie);
            }
        case 11:
            health.writeStepStartTime(nil, duration: 60, step: 200);
        case 12:
            health.writeStepDistanceStartTime(nil, duration: 600, distance: 860);
        case 13:
            health.writeCycleStartTime(nil, duration: 500, distance: 1000);
        case 14:
            health.writeSleepAnalysis(nil, sec: 200);
        default:
            break
        }
    }
    

}
