import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(AppReviewPostmanTests.allTests),
        ]
    }
#endif
