//
//  ViewController.swift
//  primewatch-ios
//
//  Created by Christopher Freestone on 12/18/16.
//  Copyright © 2016 Christopher Freestone. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import SwiftSocket

class ViewController: UIViewController {
  @IBOutlet weak var ipField: TextField!
  @IBOutlet weak var timeLabel: UILabel!

  let userDefaults = UserDefaults.standard
  let ipKey = "wii.ip"

  let connectionLock = NSRecursiveLock()
  var connection: TCPClient? = nil

  let ipVar = Variable<String?>(nil)
  let dataVar = Variable<PrimeDataPacket?>(nil)
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    prepareUI()
  }

  private func prepareUI() {
    ipField.rx.text
      .asObservable()
      .bindTo(ipVar)
      .addDisposableTo(disposeBag)

    ipVar.asDriver()
      .debounce(1)
      .drive(onNext: { ipOpt in
        print("IP: \(ipOpt)")
        if let ip = ipOpt {
          self.userDefaults.set(ip, forKey: self.ipKey)
        } else {
          self.userDefaults.removeObject(forKey: self.ipKey)
        }
        self.userDefaults.synchronize()
      }).addDisposableTo(disposeBag)

    let secondFormat = NumberFormatter()
    secondFormat.maximumFractionDigits = 3
    secondFormat.minimumFractionDigits = 3
    secondFormat.minimumIntegerDigits = 2

    let minFormat = NumberFormatter()
    minFormat.maximumFractionDigits = 0
    minFormat.minimumFractionDigits = 0
    minFormat.minimumIntegerDigits = 2

    dataVar.asDriver()
      .map({ dataOpt in
        if let data = dataOpt {
          var sec = data.timer.remainder(dividingBy: 60.0)
          if sec < 0 {
            sec += 60
          }
          var min = Int((data.timer / 60.0).remainder(dividingBy: 60.0))
          if min < 0 {
            min += 60
          }
          let hr = Int(data.timer / 60.0 / 60.0)
          return "\(hr):\(minFormat.string(from: NSNumber(value: min))!):\(secondFormat.string(from: NSNumber(value: sec))!)"
        } else {
          return "???"
        }
      })
      .drive(timeLabel.rx.text)
      .addDisposableTo(disposeBag)

    timeLabel.font = timeLabel.font.monospacedDigitFont

    if let ip = userDefaults.string(forKey: ipKey) {
      ipField.text = ip
      ipVar.value = ip
    }
  }
  
  @IBAction func giveUpFirstResponder() {
    view.endEditing(true)
  }

  @IBAction func connect() {
    guard let ip = ipVar.value else {
      print("No IP")
      return
    }

    DispatchQueue.global(qos: .background).async {
        self.connectionLock.lock()
        self.connection?.close()
        self.connection = TCPClient(address: ip, port: 43673)
        switch self.connection!.connect(timeout: 10) {
          case .success:
            print("Connected")
          case .failure(let error):
            print("Failed to connect: \(error)")
        }
        self.connectionLock.unlock()
        self.mainNetworkLoop()
      }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  private func mainNetworkLoop() {
    self.connectionLock.lock()
    let conn = self.connection!
    self.connectionLock.unlock()

    while true {
      self.connectionLock.lock()
      if self.connection !== conn {
        self.connectionLock.unlock()
        return
      }
      self.connectionLock.unlock()
      var bytes = Array<Byte>()
      while bytes.count < PrimeDataPacket.size {
        if let newBytes = conn.read(PrimeDataPacket.size - bytes.count) {
          bytes = bytes + newBytes
        } else {
          print("Disconnected")
          conn.close()
          self.connectionLock.lock()
          if self.connection === conn {
            self.connection = nil
          }
          self.connectionLock.unlock()
        }
      }
      if bytes.count != PrimeDataPacket.size {
        print("BAD!")
      }
      let data = Data(bytes: bytes)
      let primeData = PrimeDataPacket(data: data)
      self.dataVar.value = primeData
    }
  }
}

