# CAViewDebugger

A lightweight on-device View Debugger based on Core Animation. Inspired by [InAppViewDebugger](https://github.com/indragiek/InAppViewDebugger), but implemented in a traditonal way.

More functions are ongoing.

## Features

- [x] 3D Snapshot View Hierarchy implemented in Core Animation.
- [x] Original Xcode UI style and icons.
- [ ] Object and Size inspectors.
- [ ] Dynamic editing on views.

## Requirements

- iOS 10.0+
- Swift 4.2

## Usage

### Swift

```swift

import CAViewDegbugger

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    ViewDebuggerViewController.present(in: self.view.window!)
}

```

## Installation

CAViewDebugger is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CAViewDebugger'
```

## Author

lhuanyu, lhuany@gmail.com

## License

CAViewDebugger is available under the MIT license. See the LICENSE file for more info.
