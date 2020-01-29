//
//  ViewController.swift
//  APIProject
//
//  Created by ALICE SAITO on 2019/11/16.
//  Copyright © 2019 ALICE SAITO. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
        private var users : [User] = []
        
    override func viewDidLoad() {
    super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetch()
    }
    private func fetch(){
        let url = URL(string: "https://api.github.com/search/repositories?q=Hatena&page=1")!
        
        let request = MutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                print(error)
            }
            
            if let data = data {
                if let dic = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    print(dic)
                    DispatchQueue.main.async {
                        self.parse(dictionary: dic)
                        self.tableview.reloadData()
                    }
                }
            }
        }
        
        task.resume()
    }
    private func parse(dictionary: [String : Any]){
        guard let items = dictionary["items"]as? Array<Dictionary<String,Any>> else {
            return
        }
        
        /*
         let login : String
         let id : Int
         let avatarURL : URL
         let gravatarID : String
         let url : URL
         let receivedEventsURL : URL
         let type : String
         */
        
        for item in items {
            
            if let owner = item["owner"]as? Dictionary<String, Any>,
                let login = owner["login"]as? String,
                let id = owner["id"]as? Int,
                let avatarURL = owner["avatar_url"]as? String,
                let gravatarID = owner["gravatar_id"]as? String,
                let url = owner["url"]as? String,
                let receivedEventsURL = owner["received_events_url"]as? String,
                let type = owner["type"]as? String {
                
                var user = User.init()
                user.login = login
                user.id = id
                user.avatarURL = URL.init(string: avatarURL)
                user.gravatarID = gravatarID
                user.url = URL.init(string: receivedEventsURL)
                user.type = type
                
                self.users.append(user)
            }
        }
    }
}


extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
        let user = self.users[indexPath.row]
        if let url = user.avatarURL {
            if let data = try? Data.init(contentsOf : url) {
                cell.imageView?.image = UIImage.init(data: data)
            }
        }
        cell.textLabel?.text = user.login
        return cell
    }
    
}

