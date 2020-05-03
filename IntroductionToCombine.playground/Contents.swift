import Combine
import Foundation

do {
    let just = Just("First publisher!")
    let sequence = Publishers.Sequence<[String], Never>(sequence: ["Hello", "World"])
    
    just.sink { (value) in
        print(value)
    }
    
    sequence
        .sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished:
                print("Finished")
            case .failure(let error):
                print("Finished with error \(error)")
            }
        }) { (value) in
            print("Received value: \(value)")
    }
    
}

do {
    let welcome = "Welcome".publisher
    welcome.sink { (value) in
        print(value)
    }
    
    let pets = ["🐶", "🐱", "🐭", "🐹"].publisher
    
    pets.sink { (value) in
        print(value)
    }
}

do {
    let subject = CurrentValueSubject<String, Never>("This text should not be sent")
    subject.send("😉")
    
    let subscriber1 = subject.sink { (value) in
        print("First subscriber received value: \(value)")
    }
    
    subject.send("🐶")
    
    let subscriber2 = subject.sink { (value) in
        print("Second subscriber received value: \(value)")
    }
    
    subject.send("🐭")
}

do {
    // mapping
    print("Mapping")
    _ = [1,2,3,5,8,12]
        .publisher
        .map { $0%2 }
        .sink(receiveValue: { (value) in
            print(value)
        })
    
    // filtering
    print("Filtering")
    _ = [1,2,3,5,8,12].publisher.filter {
        $0%2 == 0
    }.sink(receiveValue: { (value) in
        print(value)
    })
    
    // min
    print("Min")
    _ = [1,2,3,5,8,12].publisher.min().sink(receiveValue: { (value) in
        print(value)
    })
    
    // reduce
    print("Reduce")
    _ = [1,2,3,5,8,12].publisher.reduce("", { (text, value) -> String in
        if value % 2 == 0 {
            return text + " Even"
        } else {
            return text + " Odd"
        }
    }).sink(receiveValue: { (value) in
        print(value)
    })
    
    // decode
    print("Decode")
    struct DummyDecodable: Decodable {
        let userName: String
        let userId: Int
    }
    
    let dataProvider = PassthroughSubject<Data, Never>()
    
    _ = dataProvider
        .decode(type: DummyDecodable.self, decoder: JSONDecoder())
        .sink(receiveCompletion: { completion in
            print(completion)
        }, receiveValue: { postmanResponse in
            print(postmanResponse.userName)
        })
    
    dataProvider.send(Data("{\"userName\":\"Alex\",\"userId\":1}".utf8))
    
    
    // decode+map
    print("Decode+Map")
        
    _ = dataProvider
        .decode(type: DummyDecodable.self, decoder: JSONDecoder())
        .map({ (decodable) -> String in
            return "The user is \(decodable.userName) and his id is \(decodable.userId)"
        })
        .sink(receiveCompletion: { completion in
            print(completion)
        }, receiveValue: { response in
            print(response)
        })
    
    dataProvider.send(Data("{\"userName\":\"Alex\",\"userId\":1}".utf8))
    
}
