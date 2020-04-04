# CAViewDebugger

 <img src="https://github.com/lhuanyu/CAViewDebugger/blob/master/doc/ScreenShot.png" width = "300">

A lightweight on-device View Debugger based on Core Animation. Inspired by [InAppViewDebugger](https://github.com/indragiek/InAppViewDebugger), but implemented in a traditonal way.

More functions are ongoing.

## Features

- [x] 3D Snapshot View Hierarchy implemented in Core Animation.
- [x] Original Xcode UI style and icons.
- [ ] Object and Size inspectors.
- [ ] Dynamic editing on views.

## Requirements

- iOS 10.0+
- Objective-C, Swift 4.2

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

Cocoapod is not fully compatible with the new build system since Xcode 10 when intergated pods with assets([issue#8122](https://github.com/CocoaPods/CocoaPods/issues/8122#issuecomment-531202439)). If you find icons lost, try to add this line below to your podfile: 

```ruby
install! 'cocoapods', :disable_input_output_paths => true
```

## Author

lhuanyu, lhuany@gmail.com

## License

CAViewDebugger is available under the MIT license. See the LICENSE file for more info.
