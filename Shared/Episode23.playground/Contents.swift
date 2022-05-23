let titles = [
"Notes", "Binders", "Documents", "Players"]

dump(
Array(titles.enumerated()).map { n, title in "\(n+1).) \(title)" }
)

Array(zip(1..., titles)).map { n, title in "\(n+1).) \(title)" }

//Exercise 1

func unpack<A,B,C>(_ x:(A,(B,C)))->(A,B,C) {
    return (x.0, x.1.0, x.1.1)
}

func unpack<A,B,C,D>(_ x:(A,(B,C,D))) -> (A,B,C,D) {
    return (x.0, x.1.0, x.1.1, x.1.2)
}

func unpack2<A,B,C,D>(_ x:(A,(B,(C,D)))) -> (A,B,C,D) {
   let y = unpack(x)
    return unpack((y.0, unpack((y.1, y.2))))
}

//Excercise 2

func zip2<A,B>(_ xs:[A], _ ys:[B]) -> [(A,B)] {
    var result: [(A,B)] = []
    (0..<min(xs.count, ys.count)).forEach {idx in
        result[idx]=(xs[idx],ys[idx])
    }
    return result
}

func zip4<A,B,C,D>(_ xs:[A], _ ys:[B], _ zs:[C], _ zzs:[D])->[(A,B,C,D)] {
   let result = zip2(zip2(xs,ys),zip2(zs,zzs))
    return result.map { ($0.0, $0.1, $1.0, $1.1) }
}

func zip4<A,B,C,D,E>(with f:@escaping (A,B,C,D)->E)->([A],[B],[C],[D])->[E] {
    return { a,b,c,d in
        zip4(a,b,c,d).map(f)
    }
}

//Exercise 7

struct Func<R, A> {
    let apply: (R)->A
}

func zip2<A,B,R>(_ fa:Func<R,A>, _ fb: Func<R,B>)->Func<R,(A,B)> {
    let result = Func<R,(A,B)>(apply: {r in (fa.apply(r), fb.apply(r))})
    return result
}

func zip2<A,B,C,R>(with f:@escaping (A,B)->C)->(Func<R,A>, Func<R,B>)->Func<R,C> {
    return { xs, ys in
        Func<R,C>(apply: { f(xs.apply($0), ys.apply($0)) })
    }
}

