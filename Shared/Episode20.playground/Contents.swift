struct NonEmpty<C: Collection> {
    var head: C.Element
    var tail: C
    
    init(_ head: C.Element, _ tail: C){
        self.head = head
        self.tail = tail
    }
}

NonEmpty<[Int]>(1,[2,3])

extension NonEmpty: CustomStringConvertible {
    var description: String {
        return "\(head)\(tail)"
    }
}

extension NonEmpty where C: RangeReplaceableCollection {
    init(_ head: C.Element, _ tail: C.Element...){
        self.init(head, C(tail))
    }
}

NonEmpty<[Int]>(1,2,3)

extension NonEmpty:Collection {
   enum Index:Comparable {
        case head
        case tail(C.Index)
        
       // typo in Episode; missing static
        static func < (lhs: Index, rhs: Index)->Bool {
            switch (lhs, rhs) {
            case (.head,.tail):
                return true
            case (.tail,.head):
                return false
            case (.head, .head):
                return false
            case let (.tail(l), .tail(r)):
                return l < r
            }
        }
    }
    
    var startIndex: Index {
        return .head
    }
    
    var endIndex: Index {
        return .tail(self.tail.endIndex)
    }
    
    subscript(position: Index) -> C.Element {
        switch position {
        case .head:
            return self.head
        case let .tail(t):
            return self.tail[t]
        }
    }
    
    func index(after i: Index) -> Index {
        switch i {
        case .head:
            return .tail(self.tail.startIndex)
        case let .tail(t):
            return .tail(self.tail.index(after: t))
        }
    }
}

let ys = NonEmpty<[Int]>(1,2,3)

ys.forEach { print($0) }

extension NonEmpty {
    var first: C.Element {
        return self.head
    }
}

ys.first + 1

extension NonEmpty: BidirectionalCollection where C:BidirectionalCollection {
    func index(before i: Index) -> Index {
        switch i {
        case .head:
            // typo in code
            return .tail(self.tail.index(before: self.tail.startIndex))
        case let .tail(index):
            return index == self.tail.startIndex
            ?  .head
            : .tail(self.tail.index(before:index))
        }
    }
    
    var last: C.Element {
        return (self.tail.last) ?? self.head
    }
}

ys.last + 1

extension NonEmpty where C.Index == Int {
    subscript(position:Int) -> C.Element {
        return self[position == 0 ? .head : .tail(self.tail.startIndex + position - 1)]
    }
}

ys[2]

extension NonEmpty: MutableCollection where C: MutableCollection {
  subscript(position: Index) -> C.Element {
    get {
      switch position {
      case .head:
        return self.head
      case let .tail(index):
        return self.tail[index]
      }
    }
    set(newValue) {
      switch position {
      case .head:
        self.head = newValue
      case let .tail(index):
        self.tail[index] = newValue
      }
    }
  }
}

extension NonEmpty where C: MutableCollection, C.Index == Int {
  subscript(position: Int) -> C.Element {
    get {
      return self[position == 0 ? .head : .tail(position - 1)]
    }
    set(newValue) {
      self[position == 0 ? .head : .tail(position - 1)] = newValue
    }
  }
}

var zs = NonEmpty<[Int]>(1,2,3)
zs[0] = 42
zs

extension NonEmpty where C:SetAlgebra {
    init(_ head: C.Element, _ tail:C ) {
        var tail = tail
        tail.remove(head)
        self.head = head
        self.tail = tail
    }
}

let nonEmptySet = NonEmpty(1, Set([1,2,3]))

extension NonEmpty where C: SetAlgebra {
    init(_ head: C.Element, _ tail: C.Element...) {
        self.init(head, C(tail))
    }
}

NonEmpty<Set<Int>>(1,1,2,3)


typealias NonEmptySet<A:Hashable> = NonEmpty<Set<A>>

typealias NonEmptyArray<A> = NonEmpty<Array<A>>

//Exercise 1

extension NonEmpty: SetAlgebra where C:SetAlgebra {
    
}
