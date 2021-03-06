//
//  Sessions.swift
//  uaftraffic
//
//  Modified by Jonathan Metzgar on 10/10/2019
//  Created by Brandon Abbott on 3/3/19.
//  Copyright © 2019 University of Alaska Fairbanks. All rights reserved.
//

import Foundation

public class Session: Codable, Equatable {
    // Corresponds to CodingKeys
    var lat: String = ""
    var lon: String = ""
    var id: String = ""
    var dateCreated: String = ""
    var name: String = ""
    var hasNorthLink: Bool = true
    var hasSouthLink: Bool = true
    var hasWestLink: Bool = true
    var hasEastLink: Bool = true
    var vehicle1Type: String = "atv"
    var vehicle2Type: String = "bike"
    var vehicle3Type: String = "plane"
    var vehicle4Type: String = "pedestrian"
    var vehicle5Type: String = "snowmachine"
    var NSRoadName: String = ""
    var EWRoadName: String = ""
    var technician: String = ""
    var city: String = ""
    var state: String = ""
    var zipCode: String = ""
    var crossings: [Crossing] = []

    // extra items not related to the internal Session file
    var basename: String = ""
    var savePath: String = ""
    var exportPath: String = ""

    // for summaries
    var sortedCountFromSouth: [Int] = []
    var sortedCountFromNorth: [Int] = []
    var sortedCountFromEast: [Int] = []
    var sortedCountFromWest: [Int] = []

    /// This is used to encode the fields in the save file
    enum CodingKeys: String, CodingKey {
        case lat
        case lon
        case id
        case dateCreated
        case name
        case hasNorthLink
        case hasSouthLink
        case hasWestLink
        case hasEastLink
        case vehicle1Type
        case vehicle2Type
        case vehicle3Type
        case vehicle4Type
        case vehicle5Type
        case NSRoadName
        case EWRoadName
        case technician
        case city
        case state
        case zipCode
        case crossings
    }

    init() {
        self.initID()
    }

    init(lat: String,
         long: String,
         id: String,
         name: String,
         hasNorthLink: Bool,
         hasSouthLink: Bool,
         hasWestLink: Bool,
         hasEastLink: Bool,
         vehicle1Type: String,
         vehicle2Type: String,
         vehicle3Type: String,
         vehicle4Type: String,
         vehicle5Type: String,
         nsRoadName: String,
         ewRoadName: String,
         technician: String,
         city: String,
         state: String,
         zipCode: String,
         crossings: [Crossing])
    {
        self.lat = lat
        self.lon = long
        self.id = id
        self.name = name
        self.hasNorthLink = hasNorthLink
        self.hasSouthLink = hasSouthLink
        self.hasWestLink = hasWestLink
        self.hasEastLink = hasEastLink
        self.vehicle1Type = vehicle1Type
        self.vehicle2Type = vehicle2Type
        self.vehicle3Type = vehicle3Type
        self.vehicle4Type = vehicle4Type
        self.vehicle5Type = vehicle5Type
        self.NSRoadName = nsRoadName
        self.EWRoadName = ewRoadName
        self.technician = technician
        self.crossings = crossings
        self.city = city
        self.state = state
        self.zipCode = zipCode

        self.initID()
    }

    public static func == (lhs: Session, rhs: Session) -> Bool {
        return lhs.lat == rhs.lat &&
            lhs.lon == rhs.lon &&
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.crossings == rhs.crossings &&
            lhs.hasNorthLink == rhs.hasNorthLink &&
            lhs.hasSouthLink == rhs.hasSouthLink &&
            lhs.hasEastLink == rhs.hasEastLink &&
            lhs.hasWestLink == rhs.hasWestLink &&
            lhs.vehicle1Type == rhs.vehicle1Type &&
            lhs.vehicle2Type == rhs.vehicle2Type &&
            lhs.vehicle3Type == rhs.vehicle3Type &&
            lhs.vehicle4Type == rhs.vehicle4Type &&
            lhs.vehicle5Type == rhs.vehicle5Type &&
            lhs.NSRoadName == rhs.NSRoadName &&
            lhs.EWRoadName == rhs.EWRoadName &&
            lhs.technician == rhs.technician &&
            lhs.city == rhs.city &&
            lhs.state == rhs.state &&
            lhs.zipCode == rhs.zipCode
    }

    func initID() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.dateCreated = formatter.string(from: Date())
        self.id = (self.id == "") ? randomString() : self.id
        self.basename = self.dateCreated + "-" + self.id
        self.savePath = self.basename + ".plist"
        self.exportPath = self.basename + ".csv"
    }

    func randomString() -> String {
        let length = 10
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length - 1).map { _ in letters.randomElement()! })
    }

    func addCrossing(type: String, from: String, to: String) {
        let newCrossing = Crossing(type: type, from: from, to: to, time: Date())
        crossings.append(newCrossing)
    }

    func undo() {
        if crossings.count > 0 {
            crossings.removeLast()
        }
    }

    func dateString() -> String {
        if crossings.count == 0 {
            return "Never"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy, h:mm a"
        return formatter.string(from: crossings.first!.time) + " to " + formatter.string(from: crossings.last!.time)
    }

    func setFilename(name: String) {
        self.savePath = name
    }

    func getFilename() -> String {
        return self.savePath
    }

    func calculateSummary() {
        let crossingCount = Array(repeating: 0, count: 3)
        sortedCountFromEast = crossingCount
        sortedCountFromNorth = crossingCount
        sortedCountFromWest = crossingCount
        sortedCountFromSouth = crossingCount
        for crossing in crossings {
            let fromto = crossing.from + crossing.to
            switch fromto {
            case "ns": sortedCountFromNorth[1] += 1
            case "ne": sortedCountFromNorth[0] += 1
            case "nw": sortedCountFromNorth[2] += 1
            case "sn": sortedCountFromSouth[1] += 1
            case "sw": sortedCountFromSouth[0] += 1
            case "se": sortedCountFromSouth[2] += 1
            case "we": sortedCountFromWest[1] += 1
            case "wn": sortedCountFromWest[0] += 1
            case "ws": sortedCountFromWest[2] += 1
            case "ew": sortedCountFromEast[1] += 1
            case "es": sortedCountFromEast[0] += 1
            case "en": sortedCountFromEast[2] += 1
            default: assert(false, "unrecognized from/to direction")
            }

//            let strFrom = crossing.from
//            let strTo = crossing.to
//            switch strFrom {
//            case "n":
//                switch strTo {
//                case "n":
//                    continue
//                case "s":
//                    sortedCountFromNorth [1] += 1
//                case "e":
//                    sortedCountFromNorth [0] += 1
//                case "w":
//                    sortedCountFromNorth [2] += 1
//                default:
//                    assert(false, "unrecognized 'to' direction")
//                }
//            case "s":
//                switch strTo {
//                case "s":
//                    continue
//                case "n":
//                    sortedCountFromSouth [1] += 1
//                case "w":
//                    sortedCountFromSouth [0] += 1
//                case "e":
//                    sortedCountFromSouth [2] += 1
//                default:
//                    assert(false, "unrecognized 'to' direction")
//                }
//            case "w":
//                switch strTo {
//                case "w":
//                    continue
//                case "e":
//                    sortedCountFromWest [1] += 1
//                case "n":
//                    sortedCountFromWest [0] += 1
//                case "s":
//                    sortedCountFromWest [2] += 1
//                default:
//                    assert(false, "unrecognized 'to' direction")
//                }
//            case "e":
//                switch strTo {
//                case "e":
//                    continue
//                case "w":
//                    sortedCountFromEast [1] += 1
//                case "s":
//                    sortedCountFromEast [0] += 1
//                case "n":
//                    sortedCountFromEast [2] += 1
//                default:
//                    assert(false, "unrecognized 'to' direction")
//                }
//            default:
//                assert(false, "unrecognized 'from' direction")
//            }
        }
    }

    func saveCSV() {
        self.calculateSummary()
        var cleanName = ""
        do {
            let pattern = "[^A-Za-z0-9-_]"
            let regex = try NSRegularExpression(pattern: pattern)
            let cleaned = regex.stringByReplacingMatches(in: self.name,
                                                         options: [],
                                                         range: NSRange(location: 0, length: self.name.count),
                                                         withTemplate: "-")
            cleanName = cleaned as String
        } catch { }

        var filename = dateCreated + "-" + (cleanName as String) + ".csv"
        if filename.trimmingCharacters(in: .whitespaces) == ".csv" {
            filename = self.id + ".csv"
            // the simplest way to correct for the empty name bug
        }

        // = "vehicle, from, left, right, through\n"
        var csvData = ""

        csvData += "UAFTRAFFIC EXPORT\n"
        csvData += "Summary\n"
        csvData += "Session Name,\"\(self.name)\"\n"
        csvData += "Latitude,\(self.lat)\n"
        csvData += "Longitude,\(self.lon)\n"
        csvData += "Node North-South,\(self.NSRoadName)\n"
        csvData += "Node East-West,\(self.EWRoadName)\n"
        csvData += "Technician,\(self.technician)\n"
        csvData += "City,\(self.city)\n"
        csvData += "State,\(self.state)\n"
        csvData += "Zip Code,\(self.zipCode)\n"
        csvData += "Total Northbound Traffic,Turning Left,Going Through,Turning Right\n"
        csvData += ",\(self.sortedCountFromSouth[0]),\(self.sortedCountFromSouth[1]),\(self.sortedCountFromSouth[2])\n"
        csvData += "Total Southbound Traffic,Turning Left,Going Through,Turning Right\n"
        csvData += ",\(self.sortedCountFromNorth[0]),\(self.sortedCountFromNorth[1]),\(self.sortedCountFromNorth[2])\n"
        csvData += "Total Eastbound Traffic,Turning Left,Going Through,Turning Right\n"
        csvData += ",\(self.sortedCountFromWest[0]),\(self.sortedCountFromWest[1]),\(self.sortedCountFromWest[2])\n"
        csvData += "Total Westbound Traffic,Turning Left,Going Through,Turning Right\n"
        csvData += ",\(self.sortedCountFromEast[0]),\(self.sortedCountFromEast[1]),\(self.sortedCountFromEast[2])\n"
        csvData += "\nRecorded Data\n"
        csvData += "Vehicle Type,From,To,Date,Time\n"

        for crossing in crossings {
            csvData += "\"\(crossing.type)\",\(crossing.from),\(crossing.to),\"\(crossing.csvDateString())\",\(crossing.csvTimeString())\n"
        }

        do {
            let docsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let path = docsFolder.appendingPathComponent(filename)
            try csvData.write(to: path, atomically: false, encoding: String.Encoding.utf8)
        } catch { }
    }
}
