# CAViewDebugger

 <img src="https://github.com/lhuanyu/CAViewDebugger/blob/master/doc/Snapshot.jpg">

A lightweight on-device View Debugger based on Core Animation. Inspired by [InAppViewDebugger](https://github.com/indragiek/InAppViewDebugger), but implemented in a traditonal way.

More functions are ongoing.

## Features

- [x] 3D Snapshot View Hierarchy implemented in Core Animation.
- [x] Original Xcode UI style and icons.
- [x] Full gestures support.
- [x] Object and Size inspectors.
- [ ] Dynamic editing on views.

## Requirements

- iOS 10.0+
- Objective-C, Swift 5.0

## Usage

### Swift

```swift

import CAViewDegbugger

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    ViewDebuggerViewController.present(in: self.view.window!)
}

```

### Objective-C

```swift

@import CAViewDegbugger

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [ViewDebuggerViewController presentIn:self.view.window];
}

```
### Full Gestures Support

- [x] Tap to select a view. Tap on scene to deselect.
- [x] Double tap to focus a view and its children. Double tap on scene to lose focus.
- [x] Zoom.
- [x] Pan to rotate.
- [x] Double pan to move scene around.

## Installation

CAViewDebugger is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CAViewDebugger'
```
For latest version:

```ruby
pod 'CAViewDebugger', :git => 'https://github.com/lhuanyu/CAViewDebugger.git'
```

Or you can simpy add files in [**CAViewDebugger/ViewDebugger**](https://github.com/lhuanyu/CAViewDebugger/tree/master/CAViewDebugger/ViewDebugger) to your project.

## Author

Huanyu Luo, lhuany@gmail.com

## License

CAViewDebugger is available under the MIT license. See the LICENSE file for more info.
