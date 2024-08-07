// RUN: %empty-directory(%t)

/// First, test the default mode; -package-name is only printed in package interface.
// RUN: %target-build-swift -emit-module %s -I %t \
// RUN:   -module-name Bar -package-name barpkg \
// RUN:   -enable-library-evolution -swift-version 6 \
// RUN:   -emit-module-interface-path %t/Bar.swiftinterface \
// RUN:   -emit-private-module-interface-path %t/Bar.private.swiftinterface \
// RUN:   -emit-package-module-interface-path %t/Bar.package.swiftinterface

// RUN: %FileCheck %s --check-prefix=CHECK < %t/Bar.swiftinterface
// RUN: %FileCheck %s --check-prefix=CHECK < %t/Bar.private.swiftinterface
// RUN: %FileCheck %s --check-prefix=CHECK-PACKAGE < %t/Bar.package.swiftinterface

// CHECK-NOT: -package-name barpkg
// CHECK-PACKAGE-DAG: -package-name barpkg
// CHECK-PACKAGE-DAG: -module-name Bar
// CHECK-PACKAGE-DAG: -enable-library-evolution
// CHECK-PACKAGE-DAG: -swift-version 6

/// Building modules from non-package interfaces without package-name should succeed.
// RUN: %target-swift-frontend -compile-module-from-interface %t/Bar.swiftinterface -o %t/Bar.swiftmodule -module-name Bar
// RUN: rm -rf %t/Bar.swiftmodule
// RUN: %target-swift-frontend -compile-module-from-interface %t/Bar.private.swiftinterface -o %t/Bar.swiftmodule -module-name Bar
// RUN: rm -rf %t/Bar.swiftmodule
// RUN: %target-swift-frontend -compile-module-from-interface %t/Bar.package.swiftinterface -o %t/Bar.swiftmodule -module-name Bar

// RUN: rm -rf %t/Bar.swiftmodule
// RUN: rm -rf %t/Bar.swiftinterface
// RUN: rm -rf %t/Bar.private.swiftinterface
// RUN: rm -rf %t/Bar.package.swiftinterface

/// Second, test pringing package-name in public and private interfaces.
// RUN: %target-build-swift -emit-module %s -I %t \
// RUN:   -module-name Bar \
// RUN:   -enable-library-evolution -swift-version 6 \
// RUN:   -package-name foopkg -package-name barpkg \
// RUN:   -Xfrontend -print-package-name-in-non-package-interface \
// RUN:   -emit-module-interface-path %t/Bar.swiftinterface \
// RUN:   -emit-private-module-interface-path %t/Bar.private.swiftinterface \
// RUN:   -emit-package-module-interface-path %t/Bar.package.swiftinterface

// RUN: %FileCheck %s --check-prefix=CHECK-OPTIN < %t/Bar.swiftinterface
// RUN: %FileCheck %s --check-prefix=CHECK-OPTIN < %t/Bar.private.swiftinterface
// RUN: %FileCheck %s --check-prefix=CHECK-PACKAGE < %t/Bar.package.swiftinterface

// CHECK-OPTIN-NOT: -package-name foopkg
// CHECK-OPTIN-DAG: -package-name barpkg
// CHECK-OPTIN-DAG: -module-name Bar
// CHECK-OPTIN-DAG: -enable-library-evolution
// CHECK-OPTIN-DAG: -swift-version 6

/// Verify building modules from non-package interfaces succeeds with the package-name flag.
// RUN: %target-swift-frontend -compile-module-from-interface %t/Bar.swiftinterface -o %t/Bar.swiftmodule -module-name Bar
// RUN: rm -rf %t/Bar.swiftmodule
// RUN: %target-swift-frontend -compile-module-from-interface %t/Bar.private.swiftinterface -o %t/Bar.swiftmodule -module-name Bar
// RUN: rm -rf %t/Bar.swiftmodule
// RUN: %target-swift-frontend -compile-module-from-interface %t/Bar.package.swiftinterface -o %t/Bar.swiftmodule -module-name Bar

public struct PubStruct {
  internal var intVar: UfiPkgStruct.UfiNestedPkgStruct?
}

@usableFromInline
package struct UfiPkgStruct {
  @usableFromInline
  package struct UfiNestedPkgStruct {}
}

@_spi(bar) public struct SPIStruct {}

package struct PkgStruct {}
