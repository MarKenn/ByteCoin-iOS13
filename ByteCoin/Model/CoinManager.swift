//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateExchangeRate(manager: CoinManager, coinData: CoinData)
    func didFailWithError(manager: CoinManager, error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "51B12CE4-3106-413F-9194-ACEA55001DEC"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?

    func getCoinPrice(for row: Int) {
        performRequest(with: "\(baseURL)/\(currencyArray[row])?apiKey=\(apiKey)")
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if let err = error {
                    delegate?.didFailWithError(manager: self, error: err)
                } else if let safeData = data, let coinData = parseJSON(safeData) {
                    delegate?.didUpdateExchangeRate(manager: self, coinData: coinData)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> CoinData? {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(CoinData.self, from: data)
        } catch {
            delegate?.didFailWithError(manager: self, error: error)
            return nil
        }
    }
}
