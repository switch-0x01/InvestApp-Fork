//
//  DependencyHolder.swift
//  My Portfolio
//
//  Created by Евгений on 16.02.2022.
//

import Foundation

protocol DependencyHolder {
    //keep weak
    var _repository: DependencyRepository? { get set }
    func dependencyInjected()
    func injectDependency(to holder: AnyObject)
}

extension DependencyHolder {
    
    var repository: DependencyRepository? {
        get {
            return self._repository
        }
        set {
            if let repo = newValue {
                self._repository = repo
                dependencyInjected()
            }
        }
    }
    
    //rewrite in subclass (like override)
    func dependencyInjected() {
        repository?.logger.log("dependency injected in \(self)")
    }
    
    func injectDependency(to holder: AnyObject) {
        guard let myRepo = repository else {
            print("ERROR: repository not found", self)
            return
        }
        
        if var holder = holder as? DependencyHolder {
            holder.repository = myRepo
        } else {
            print("ERROR: missing dependency holder in", holder.description as Any)
        }
    }
}
