enum NaturalNumber:Comparable {
    indirect case succ(NaturalNumber)
    case zero
    public var value: Int {
        switch self {
        case .zero:
            return 0
        case .succ(let pred):
            return 1 + pred.value
        }
    }
}

let two = NaturalNumber.succ(.succ(.zero))
let three = NaturalNumber.succ(.succ(.succ(.zero)))
let five = NaturalNumber.succ(.succ(.succ(.succ(.succ(.zero)))))

func pred(_ nat:NaturalNumber)->NaturalNumber? {
    switch nat {
    case .zero:
        return nil
    case .succ(let pred):
        return pred
    }
}

//Excercise 1

func +(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber {
    switch rhs {
    case .zero:
        return lhs
    case .succ(let pred):
        return .succ(lhs + pred)
    }
}

(two + three + five) == (five + two + three)

func *(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber {
    switch rhs {
    case .zero:
        return .zero
    case .succ(let pred):
        return (lhs * pred) + lhs
    }
}

(two * three * five).value
(three * five * two).value

//Exercise 2

func exp(_ base: NaturalNumber, _ power: NaturalNumber) -> NaturalNumber {
    switch power {
    case .zero:
        return .succ(.zero)
    case .succ(let pred):
        return exp(base, pred) * base
    }
}

exp(two,three).value
exp(three,three).value

//Exercise 3

extension NaturalNumber {
    static func ==(_ lhs:NaturalNumber, _ rhs:NaturalNumber)->Bool {
        switch (lhs,rhs) {
        case (.zero, .zero):
            return true
        case (.zero, _), (_,.zero):
            return false
        case (.succ(let predl),succ(let predr)):
            return (predl == predr)
        }
    }
    
    static func <(_ lhs:NaturalNumber, _ rhs:NaturalNumber)->Bool {
        switch (lhs,rhs){
           case (.zero,.zero),(.succ,.zero):
            return false
        case(.zero,.succ):
            return true
        case(.succ,.succ(let pred)):
            return (lhs==pred) || lhs < pred
        }
    }
}

two == three
three == three
two < three
three > two
two > three

//Exercise 4

extension NaturalNumber {
    static func min(_ lhs:NaturalNumber, _ rhs:NaturalNumber)->NaturalNumber {
        return lhs <= rhs ? lhs : rhs
    }
    static func max(_ lhs:NaturalNumber, _ rhs:NaturalNumber)->NaturalNumber {
        return lhs > rhs ? lhs : rhs
    }
}

min(two,three).value
min(two,five).value
max(three,five).value
min(two,two).value
max(three,three).value

//Exercise 6

enum List<A> {
    case empty
    indirect case cons(A, List<A>)
}

typealias MyNum = List<Void>
extension MyNum {
    static public func to(_ x:MyNum)->NaturalNumber {
        switch x {
        case .empty:
            return .zero
        case .cons(_, let tail):
            return .succ(MyNum.to(tail))
        }
    }
    static public func from(_ n:NaturalNumber)->MyNum {
        switch n {
        case .zero:
            return .empty
        case .succ(let pred):
            return .cons((),MyNum.from(pred))
        }
    }
}

let myFive = MyNum.from(five)
MyNum.to(myFive).value

//Excercise 10

enum FList<A,B> {
    case empty
    case cons(A,B)
}

enum Fix<A> {
    indirect case fix(FList<A,Fix<A>>)
}

let x = Fix<Int>.fix(FList.empty)

typealias FixInt = Fix<Int>

let y = FixInt.fix(FList.cons(3, FixInt.fix(FList.empty)))

func fromInt(_ fix: FixInt) -> List<Int> {
    switch fix {
    case .fix(let x):
        switch x {
        case .empty:
            return List.empty
        case .cons(let head, let tail):
            return List.cons(head,fromInt(tail))
        }
   }
}

fromInt(y)

enum G<A> {
    case term
    indirect case cons(G<A>)
}
