//
//  LoginViewModelTests.swift
//  SWPatternsTests
//
//  Created by Kevin Heredia on 8/11/24.
//

@testable import SWPatterns
import XCTest


private final class SuccessUseCaseMock: LoginUseCaseContract {

    func execute(credentials: SWPatterns.Credentials, completion: @escaping (Result<Void, Error>) -> Void) {
        XCTAssertEqual(credentials.username, "kevin_heredia10@hotmail.com")
        XCTAssertEqual(credentials.password, "1234")
        completion(.success(()))
    }
}

    
    private final class FailUseCaseMock: LoginUseCaseContract {
        func execute(credentials: SWPatterns.Credentials, completion: @escaping (Result<Void, Error>) -> Void) {
            XCTAssertEqual(credentials.username, "kevin_heredia10@hotmail.com")
            XCTAssertEqual(credentials.password, "1234")
            completion(.failure(LoginUseCaseError(reason: "Error")))
        }
    }

private final class NoReachedUseCaseMock: LoginUseCaseContract {
    func execute(credentials: SWPatterns.Credentials, completion: @escaping (Result<Void,Error>) -> Void) {
        XCTFail("NoRealUseCaseMock should not be called")
    }
    

}

    
final class LoginViewModelTests: XCTestCase {
    
    func test_failure_User_And_Password_Missing() {
        let expectation = self.expectation(description: "Success scenario expects fail")
        let useCaseMock = NoReachedUseCaseMock()
        let sut = LoginViewModel(useCase: useCaseMock)
        
        sut.onStateChanged.bind { newState in
            if case .error = newState{
                expectation.fulfill()
            }
        }
        sut.signIn(nil, nil)
        waitForExpectations(timeout: 5)
    }
    
    func test_failure_password_missing() {
        let expectations = self.expectation(description: "Success scenario expects fail")
        let useCaseMock = NoReachedUseCaseMock()
        let sut = LoginViewModel(useCase: useCaseMock)
        
        sut.onStateChanged.bind { newState in
            if case .error = newState {
                expectations.fulfill()
            }
        }
        sut.signIn("kevin_heredia10@hotmail.com", nil)
        waitForExpectations(timeout: 5)
        
    }
    
    
    
    
}
