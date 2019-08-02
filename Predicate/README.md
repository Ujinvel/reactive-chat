# Predicate

[![Version](https://img.shields.io/cocoapods/v/Predicate.svg?style=flat)](https://cocoapods.org/pods/Predicate)
[![License](https://img.shields.io/cocoapods/l/Predicate.svg?style=flat)](https://cocoapods.org/pods/Predicate)
[![Platform](https://img.shields.io/cocoapods/p/Predicate.svg?style=flat)](https://cocoapods.org/pods/Predicate)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Predicate is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Predicate'
```

## Features

- [x] Basic comparisons
   - [x] ==, !=
   - [x] >, >=, <, <=
   - [x] ! (NOT)
   - [x] IN
   - [x] BETWEEN
- [x] String comparison operators
   - [x] BEGINSWITH
   - [x] CONTAINS
   - [x] ENDSWITH
   - [x] LIKE
   - [x] MATCHES
- [ ] Basic compound predicates
   - [x] ANY
   - [x] ALL
   - [ ] NONE (== NOT ANY)
- [x] Basic compound predicates
   - [x] AND, &&
   - [x] OR, ||
   - [x] ! (NOT)
- [x] Subqueries
- [ ] Array operations
   - [ ] array[index]
   - [ ] array[FIRST]
   - [ ] array[LAST]
   - [ ] array[SIZE]
- [ ] Keypath collection queries
   - [ ] avg
   - [x] count
   - [ ] min
   - [ ] max
   - [ ] sum
- [ ] Object, array, and set operators
   - [ ] distinctUnionOfObjects
   - [ ] unionOfObjects
   - [ ] distinctUnionOfArrays
   - [ ] unionOfArrays
   - [ ] distinctUnionOfSets

## Author

hawkdp, igor.teltov@gmail.com

## License

Predicate is available under the MIT license. See the LICENSE file for more info.
