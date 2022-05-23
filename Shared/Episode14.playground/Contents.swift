import Overture
import Foundation

//Exercise 1

//(A) -> (B) -> (C)
//(A) -> ( (B) -> (C) )
//          |______|
//          -1     +1
// |____________|
// -1           +1
//
// A = -1
// B = -1
// C = +1

//Exercise 2

// (A, B) -> (((C) -> (D) -> E) -> F) -> G
//                    |_|   |_|
//                     -1    +1
//             |_|    |_______|
//              -1        +1
//           |________________|    |_|
//                   -1             +1
//           |________________________|  |_|
//                      -1                +1
// |_____|   |_____________________________|
//    -1                   +1

// A = -1
// B = -1
// C = -1
// D = -1
// E = +1
// F = -1
// G = +1

//Exercise 3

// Setter: ( (A) -> B ) -> (S) -> T
//            -1    +1      -1    +1
//               -1            +1
// A = +1
// B = -1
// S = -1
// T = +1

typealias Setters<S, T, A, B> = ( (@escaping (A) ->B ) -> (S) -> T)

func mapA<S,T,A,B,C>(_ f: @escaping (A) -> C )
  -> (@escaping Setters<S,T,A,B>)
    -> Setters<S,T,C,B> {
        return { origSetter in // (A->B) -> (S) -> T
            return {update in // (C) -> B
                return { s in
                    return origSetter(pipe(f,update))(s)
                }
            }
        }
}

func mapB<S,T,A,B,C>(_ f: @escaping (C) -> B )
  -> (@escaping Setters<S,T,A,B>)
    -> Setters<S,T,A,C> {
        return { origSetter in // (A->B) -> (S) -> T
            return {update in // (A) -> C
                return { s in
                    return origSetter(compose(f,update))(s)
                }
            }
        }
}

func mapS<S,T,A,B,C>(_ f: @escaping (C) -> S )
  -> (@escaping Setters<S,T,A,B>)
    -> Setters<C,T,A,B> {
        return { origSetter in // (A->B) -> (S) -> T
            return {update in // (A) -> B
                return { s in
                    return origSetter(update)(f(s))
                }
            }
        }
}

func mapT<S,T,A,B,C>(_ f: @escaping (T) -> C )
  -> (@escaping Setters<S,T,A,B>)
    -> Setters<S,C,A,B> {
        return { origSetter in // (A->B) -> (S) -> T
            return {update in // (A) -> B
                return { s in
                    return f(origSetter(update)(s))
                }
            }
        }
}

// Exercise 4

struct PredicateSet<A> {
    let contains: (A)->Bool
    func union(_ y:PredicateSet<A>)->PredicateSet<A>{
        return PredicateSet { self.contains($0) || y.contains($0) }
    }
    func intersect(_ y:PredicateSet<A>)->PredicateSet<A>{
        return PredicateSet { self.contains($0) && y.contains($0) }
    }
    func invert()->PredicateSet<A>{
        return PredicateSet { !self.contains($0) }
    }
}

let setX = PredicateSet {[1,3,5,6].contains($0)}
let setY = PredicateSet {[5,6,8,10].contains($0)}

var setZ = setX.union(setY)
setZ.contains(1)
setZ.contains(5)
setZ.contains(10)

setZ = setX.intersect(setY)
setZ.contains(1)
setZ.contains(5)
setZ.contains(10)

setZ = setX.invert()
setZ.contains(1)
setZ.contains(5)
setZ.contains(100)

// Exercise 5

let powersOf2 = PredicateSet { (x:Int) in
    if(x<=0) {
        return false
    } else {
        let unsignedX = UInt64(x)
        return (unsignedX & (unsignedX-1)) == 0
    }
}

powersOf2.contains(2)
powersOf2.contains(7)
powersOf2.contains(256)
powersOf2.contains(2034)
powersOf2.contains(4096)

let powersOf2Minus1 = PredicateSet { powersOf2.contains($0+1)}

powersOf2Minus1.contains(1)
powersOf2Minus1.contains(7)
powersOf2Minus1.contains(255)
powersOf2Minus1.contains(2034)

func isPrime(_ n: Int) -> Bool {
    guard n >= 2     else { return false }
    guard n != 2     else { return true  }
    guard n % 2 != 0 else { return false }
    return !stride(from: 3, through: Int(sqrt(Double(n))), by: 2).contains { n % $0 == 0 }
}

let primes = PredicateSet { isPrime($0) }

primes.contains(2)
primes.contains(17)
primes.contains(81)


let mersennes = powersOf2Minus1.intersect(primes)

//var first10: [Int] = []
//var i = 0
//
//while (first10.count < 10) {
//    if(mersennes.contains(i)) {
//        first10.append(i)
//    }
//    i+=1
//}
//print(first10)

//Exercise 6
struct FalseDictionary<K,V> {
    private let entries: [V] = []
    let findKey: (V)->K
    func get(k:K)->V {
        entries.first(where: { v in self.findKey(v)==k })!
    }
}

//Exercise 7

//Exercise 8

//Exercise 9

struct Equate<A> {
    let equals: (A,A) -> Bool
}

func contramap<A,B>(_ f: @escaping (B)->A)->(Equate<A>)->Equate<B> {
    return { equate in
        return Equate<B>(equals: { (b1,b2) in
            equate.equals(f(b1),f(b2))
        } )
    }
}

let intEquate = Equate<Int> { $0 == $1 }

