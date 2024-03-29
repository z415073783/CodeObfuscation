// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodeObfuscation",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    .package(path: "/Library/ScriptCodes/代码存放/Swift脚本/MMScriptFramework")
//         .package(url: "https://github.com/z415073783/MMScriptFramework.git", from: "1.0.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "CodeObfuscation",
            dependencies: ["MMScriptFramework"]),
    ]
)
