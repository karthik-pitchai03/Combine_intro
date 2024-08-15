//
//  ViewController.swift
//  Combine-Framework
//
//  Created by Karthik Pitchai on 16/08/24.
//

import Combine
import UIKit

class MyCustomTableviewCell: UITableViewCell{
    
    let button : UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    
    let action = PassthroughSubject<String, Never>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(button)
        //add action to the button
        button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: 10, y: 3, width: contentView.frame.size.width - 20, height: contentView.frame.size.height-6)
    }
    
    @objc private func tapButton(){
        action.send(button.titleLabel?.text ?? "")
    }
}

class ViewController: UIViewController, UITableViewDataSource {

    //MARK: - Outlet
    @IBOutlet weak var tableview: UITableView!{
        didSet{
            tableview.register(MyCustomTableviewCell.self, forCellReuseIdentifier: "MyCustomTableviewCell")
        }
    }
    
    var nameList = [String]()
    
    //Array of AnyCancellable to store the observers
    var observers: [AnyCancellable] = [] // this is created in array to support uitableview, they might have many cells it is impossible to create observer each cell so array is used
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableview.dataSource = self
        
        //Calling the getListOfNames to get the data
        APICaller.shared.getListOfNames()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {completion in
                switch completion {
                case .finished: // this is called once the process is completed
                    print("Finished")
                case .failure(let failure): // error handling can be done here
                    print(failure.localizedDescription)
                }
                
            }, receiveValue: { [weak self] value in //on Success values are handled here.
                self?.nameList = value
                self?.tableview.reloadData()
            }).store(in: &observers) // observers need to be stored so we are adding it to the array
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCustomTableviewCell", for: indexPath) as? MyCustomTableviewCell else{
            fatalError()
        }
        
        cell.button.setTitle(nameList[indexPath.row], for: .normal)
        // This functionality same as the delegate and closure fuctionalities
        cell.action.sink(receiveValue: { result in
            print(result)
        }).store(in: &observers)
        
        return cell
    }

}


//MARK: - Api Caller class
//MARK : Just a shared class with one function

class APICaller{
    static let shared = APICaller()
    
    //Future carries the output and error as well
    func getListOfNames() -> Future<[String], Error>{
        return Future{ promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                promise(.success(["Dhoni","Raina","Virat","Rohit","Gill"]))
            }
        }
    }
}


