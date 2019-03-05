import XCTest
@testable import PythonBridge

final class PythonBridgeTests: XCTestCase {

	let computeModule = Python.import("Compute.compute")
	let swiftArray: [Int] = [2, 4, 6, 8, 10]
	var computedInstance: PyVal?


	override func setUp() {
		super.setUp()

		let numeric_list: PyVal = PyVal(arrayContentsOf: self.swiftArray)
		self.computedInstance = computeModule.get(member: "compute").call(args: "Python Bridge", numeric_list)
	}

    func testComputeMembers() {

    	// The first test below is designed to call into computedInstance
    	// and test the equality of a member using an explicit lookup.
    	// 
    	// The second test is designed to also test equality but using the 
    	// dot syntax with the @dynamicMemberLookup functionality instead.
    	
    	// ## Test: 1
    	// Test that we can get static data from the computedInstance.
    	// Accessing this member does not use dot syntax.
    	let pyValStaticText = computedInstance?.get(member: "static_text")
    	XCTAssertEqual(pyValStaticText?.asString(), "Hello from Python")

    	// ## Test: 2
    	// Test that we can call a dynamic member in the compute class
    	// and use @dynamicMemberLookup to access this member with the dot syntax.
    	// This specific example is grabbing a string.
    	let pyValDynamicMemberText = computedInstance?.static_text
    	XCTAssertEqual(pyValDynamicMemberText, "Hello from Python")

    	// ## Test: 3 - Also using @dynamicMemberLookup.
    	// This test also uses the dot syntax but instead grabs a numeric list/array.
    	// A subscript is used to then compare two values.
    	guard let swiftArray = computedInstance?.numeric_list else {
    		XCTFail("Numeric List was not unwrapped properly")
    		return
    	}
        
    	XCTAssertEqual(swiftArray[2], 6)
		
    }

    func testComputeMethods() {

    	// The tests below are to provide examples of calling methods of the
    	// computedInstance and checking the return values.
    	// The return values are cast to numeric values in the PythonBridge instead 
    	// of the currency PyVal object.
    	//
    	// The proposal for @dynamicCallable will make the below example possible.
    	// Until then .call() method will need to be used to explicitly call members
    	// of the PyVal object.
    	// let v = computedInstance.get_mean()
    	// 
    	
    	// ## Test: 1
    	// Test that we can get the mean back from NumPy and test it in Swift
    	// Provids a PyVal object that contains the mean
    	let pyValMean = computedInstance?.get(member: "get_mean").call()
    	XCTAssertEqual(pyValMean?.asDouble(), 6.0)

    	// ## Test: 2
    	// Test the min value received back from NumPy
    	// Provids a PyVal object that contains the min
        let pyValMin = computedInstance?.get(member: "get_min").call()
    	XCTAssertEqual(pyValMin?.asInteger(), 2)

    	// ## Test: 3
    	// Test adding values to the numeric list and then recomputing the mean.
        let swiftPrimes = [3,5,29]
        let pyValPrimeList: PyVal = PyVal(arrayContentsOf: swiftPrimes)
        computedInstance?.get(member: "add_to_list").call(args: pyValPrimeList)

        // The new recomputed means as a double or integer
        let pyValNewMean = computedInstance?.get(member: "get_mean").call()
        XCTAssertEqual(pyValNewMean?.asInteger(), 12)
        XCTAssertEqual(pyValNewMean?.asDouble(), 12.625)

        let pyValMaxValue = computedInstance?.get(member: "get_max").call()
        XCTAssertEqual(pyValMaxValue, 12)

        let maxValue = computedInstance?.get_max()
        XCTAssertEqual(maxValue, 12)
        
        
        // TODO: For our homework, create a test with func have argument, using dynamic callable atribute in PythonBridge.swift file
        
//        let swiftPrimes = [1]
//        let pyValPrimeList: PyVal = PyVal(arrayContentsOf: swiftPrimes)
//        computedInstance?.pyValPrimeList)
//        let pyValMin2 = computedInstance?.get(member: "get_min").call()
//        XCTAssertEqual(pyValMin2?.asInteger(), 1)
//        computedInstance?.add_to_list("added_value": [1])
//        let pyValMin2 = computedInstance?.get(member: "get_min").call()
//        XCTAssertEqual(pyValMin2?.asInteger(), 2)
    }

    override func tearDown() {
    	super.tearDown()

    }

    static var allTests = [
        ("testComputeMembers", testComputeMembers),
        ("testComputeMethods", testComputeMethods)
    ]
}
