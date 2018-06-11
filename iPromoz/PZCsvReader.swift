//
//  PZCsvReader.swift
//  iPromoz
//
//  Created by Denis Engels on 06/08/2017.
//  Copyright © 2017 Denis Engels. All rights reserved.
//

import Cocoa
import CSwiftV

class PZCsvReader {

    class func readCodesFromFileUrl(_ fileUrl: URL) -> [String] {
        do {
            let csvString = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
            let csv = CSwiftV(with: "skip_headers\n\(csvString)")
            let codes = csv.rows.filter { $0.count == 1 && $0.first != nil }.map { $0.first! }
            return codes
        }
        catch {
            // TODO: raise instead of silent failing (and later display an error message to the user)
            Swift.print("Error while reading the CSV file")
            return []
        }
    }

}
