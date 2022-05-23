import Foundation
import Overture

// Exercise 1
func map<K,V,W>(f: @escaping ((V)->W))->([K:V])->[K:W] {
    return { dict in
        var newDict = Dictionary<K,W>()
        for (key, value) in dict {
            newDict[key] = f(value)
        }
        return newDict
    }
}

let ages = [
    "sam": 45,
    "amanda": 45,
    "nicholas": 14,
    "emma": 12
]

let stringifiedAges = with(ages,
                           map(f: { String($0)})
)

//return { dict in
//    var newDict = Dictionary<K,W>()
//    for (key, value) in dict {
//        newDict[key] = f(value)
//    }
//    return newDict
//}

//return { dict in
//    var newDict = Dictionary<K,W>()
//    for (key, value) in dict {
//        newDict[key] = id(value)
//    }
//    return newDict
//}

//return { dict in
//    var newDict = Dictionary<K,W>()
//    for (key, value) in dict {
//        newDict[key] = value
//    }
//    return newDict
//}

//return { dict in
//    var newDict = dict
//    return newDict
//}

//return { $0 }

let idAges = with(ages,
                  map(f:{$0})
)

// Exercise 2

func transformSet<A,B>(f: @escaping (A)->B)->(Set<A>)->Set<B> {
    return { setA in
        var setB = Set<B>()
        for a in setA {
            setB.insert(f(a))
        }
        return setB
    }
}

let setA = Set<Int>([1,2,3,4,5])

func transform(_ x:Int)->Int {
    return x%2
}

//NB: range of transform may have duplicates even if domain does not
let resultA = transform(1)
let resultB = transform(3)

let setB = with(setA,
                transformSet(f:transform)
)

var areEqual = setA.count == setB.count

//Exercise 3

func f(_ x:Int)->Int { return x%2 }
func g(_ x:Int)->Int { return 2 }

let setB1 = with(setA,
                 transformSet(f:pipe(f,g))
)

let setB2 = with(setA,
                 compose(
                    transformSet(f: f),
                    transformSet(f: g)
                 )
)

areEqual = setB1 == setB2

//Exercise 4

struct PredicateSet<A> {
    let spec: (A)->Bool
    func isElement(_ x:A)->Bool { spec(x) }
}

func evenSpec(_ x:Int)->Bool { return x%2 == 0 ? true : false}

let EvenSet = PredicateSet(spec: evenSpec)

EvenSet.isElement(4)
EvenSet.isElement(43)

func startsWith2Spec(_ s:String)->Bool { return s.first == "2" }

let Start2Set = PredicateSet(spec: startsWith2Spec)

Start2Set.isElement("23")
Start2Set.isElement("34")

//func map<A,B>(_ f: @escaping (A)->B)->(PredicateSet<A>)->PredicateSet<B> {
//    return { predSetA in
//        func newSpec(_ b:B)->Bool {
//            predSetA.isElement( // but we don't have an A!)
//        }
//    }
//}

//Exercise 5

func fakeMap<A,B>(_ f: @escaping (B)->A)->(PredicateSet<A>)->PredicateSet<B> {
    return { predSetA in
        func newSpec(_ b:B)->Bool {
            predSetA.isElement(f(b))
        }
        return PredicateSet(spec:newSpec)
    }
}

let NumberStartsWith2 = with(Start2Set,
                             fakeMap() {(x:Int) in String(x)}
)

NumberStartsWith2.isElement(23)
NumberStartsWith2.isElement(34)

//Exercise 6

// fakeMap((C) -> B >>> (B)->A) == fakeMap((B)->A) >>> fakeMap((C)->B)

// convert Int to String
func cToB(_ c: Int)->String { String(c) }
// Count the letters (i.e., digits) in the string
func bToA(_ b: String)->Int { b.count }

let PredSetMapCompose = with(NumberStartsWith2, fakeMap(pipe(cToB, bToA)))

let PredSetComposeMap = with(NumberStartsWith2, pipe(fakeMap(bToA),fakeMap(cToB)))

// Both of these will return the set of integers where the number of digits are 2*10^n
// (although anything more than 2 will overflow Int...

PredSetMapCompose.isElement(34)
PredSetMapCompose.isElement(3)
PredSetMapCompose.isElement(343)

PredSetComposeMap.isElement(34)
PredSetComposeMap.isElement(3)
PredSetComposeMap.isElement(343)

//Exercise 7

enum Either<A, B> {
    case left(A)
    case right(B)
}

func bimap<A,B,X,Y>(_ f: @escaping (A)->B, _ g: @escaping (X)->Y)->(Either<A,X>)->Either<B,Y> {
    return { either in
        switch either {
        case .left(let a):
            return Either.left(f(a))
        case .right(let x):
            return Either.right(g(x))
        }
    }
}

with(Either<Int,String>.left(2),
     bimap({ String($0) }, { $0.count })
)

with(Either<Int,String>.right("three"),
     bimap({ String($0) }, { $0.count })
)

func bimapResult<A,B,X,Y>(_ f: @escaping (A)->B, _ g: @escaping (X)->Y)->(Result<A,X>)->Result<B,Y> {
    return { result in
        switch result {
        case .success(let a):
            return Result.success(f(a))
        case .failure(let x):
            return Result.failure(g(x))
        }
    }
}

enum MyError: Error {
    case someProblem(String)
}

enum MyOtherError: Error {
    case someOtherProblem(Int)
}

with(Result<Int,MyError>.success(2),
     bimapResult({ String($0) }, { $0 })
)

with(Result<Int,MyError>.failure(MyError.someProblem("error")),
     bimapResult( { String($0) }, { _ in MyOtherError.someOtherProblem(5) })
)

//Exercise 8

func r1<A>(_ xs: [A])->A? {
    xs.first
}

r1([])
r1([1,2])

func r2<A>(_ xs: [A])->A? {
    xs.last
}

r2([])
r2([1,2])

//Exercise 9

func s1<A,B>(_ f: @escaping (A)->B, _ xs: [A])->B? {
    let value: B?
    switch xs.first {
    case .some(let a):
        value = f(a)
    case .none:
        value = nil
    }
    return value
}

s1({$0*2},[])
s1({$0*2},[1,2])

func s2<A,B>(_ f: @escaping (A)->B, _ xs: [A])->B? {
    let value: B?
    switch xs.last {
    case .some(let a):
        value = f(a)
    case .none:
        value = nil
    }
    return value
}

s2({$0*2},[])
s2({$0*2},[1,2])

//Exercise 10
