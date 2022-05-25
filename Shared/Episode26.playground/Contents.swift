enum Expr: Equatable {
    case int(Int)
    indirect case add(Expr,Expr)
    indirect case mul(Expr,Expr)
    case `var`
}

func eval(_ exp:Expr, with value:Int)->Int {
    switch (exp) {
    case .int(let x):
        return (x)
    case let .add(x,y):
        return eval(x, with:value) + eval(y, with:value)
    case let .mul(x,y):
        return eval(x, with:value) * eval(y, with:value)
    case .var:
        return value
    }
}

func print(_ exp:Expr)->String {
    switch (exp) {
    case let .int(x):
        return "\(x)"
    case let .add(x, y):
        return "(\(print(x)) + \(print(y)))"
    case let .mul(x, y):
        return "\(print(x)) * \(print(y))"
    case .var:
        return "x"
    }
}

extension Expr: ExpressibleByIntegerLiteral {
    init(integerLiteral value:Int) {
        self = .int(value)
    }
}

let myExpr = Expr.mul(.add(2,3), .add(2,4))

eval(myExpr,with: 0)
print(myExpr)

func simplify(_ expr:Expr)->Expr {
    switch expr {
    case .int:
        return expr
    case let .add(.mul(a,b),.mul(c,d)) where a == c:
        return .mul(a,.add(b,d))
    case let .add(.mul(a,b),.mul(c,d)) where b == d:
        return .mul(b,.add(a,c))
    case .add:
        return expr
    case .mul(.int(1),let b):
        return b
    case .mul(let a,.int(1)):
        return a
    case .mul:
        return expr
    case .var:
        return expr
    }
}

print(.add(.mul(2,3),.mul(2,4)))
print(simplify(.add(.mul(2,3),.mul(2,4))))
