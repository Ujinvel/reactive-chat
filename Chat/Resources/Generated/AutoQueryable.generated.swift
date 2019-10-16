// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import Predicate
import RealmSwift

extension RMMessage: Queryable {
typealias Object = ObjectAttribute<RMMessage>
internal struct ObjectAttribute<RMMessage>: ObjectAttributeType {
let expression: Expression<RMMessage>

var localId: Attribute<String> { return value(for: "localId") }
var createdAt: Attribute<Date> { return value(for: "createdAt") }
var updatedAt: Attribute<Date> { return value(for: "updatedAt") }
var sentAt: Attribute<Date> { return value(for: "sentAt") }
var isIncoming: Attribute<Bool> { return value(for: "isIncoming") }
var body: Attribute<String> { return value(for: "body") }
}
}


