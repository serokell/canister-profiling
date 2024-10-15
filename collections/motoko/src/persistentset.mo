import Set "mo:base/PersistentOrderedSet";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Random "random";
import Profiling "../../../utils/motoko/Profiling";

actor {
    stable let profiling = Profiling.init();

    let setOps = Set.SetOps<Nat64>(Nat64.compare);
    stable var rbSet = Set.empty<Nat64>();
    let rand = Random.new(null, 42);

    public func generate(size: Nat32) : async () {
        let rand = Random.new(?size, 1);
        rbSet := setOps.fromIter(rand);
    };
    public query func get_mem() : async (Nat,Nat,Nat) {
        Random.get_memory()
    };
    public func batch_get(n : Nat) : async () {
        for (_ in Iter.range(1, n)) {
            ignore setOps.contains(rbSet, Option.get<Nat64>(rand.next(), 0));
        }
    };
    public func batch_put(n : Nat) : async () {
        for (_ in Iter.range(1, n)) {
            let k = Option.get<Nat64>(rand.next(), 0);
            rbSet := setOps.put(rbSet, k);
        }
    };
    public func batch_remove(n : Nat) : async () {
        let rand = Random.new(null, 1);
        for (_ in Iter.range(1, n)) {
            rbSet := setOps.delete(rbSet, Option.get<Nat64>(rand.next(), 0));
        }
    };

    public func intersect(n : Nat32) : async () {
      let rand = Random.new (?n, 1);
      let set2 = setOps.fromIter(rand);
      ignore setOps.intersect(rbSet, set2)
    };

    public func union(n : Nat32) : async () {
      let rand = Random.new (?n, 1);
      let set2 = setOps.fromIter(rand);
      ignore setOps.union(rbSet, set2)
    };

    public func diff(n : Nat32) : async () {
      let rand = Random.new (?n, 1);
      let set2 = setOps.fromIter(rand);
      ignore setOps.diff(rbSet, set2)
    };

    public func equals(n : Nat32) : async () {
      ignore setOps.equals(rbSet, rbSet)
    };

    public func isSubset(n : Nat32) : async () {
      ignore setOps.isSubset(rbSet, rbSet)
    };

    public func foldLeft() : async () {
        ignore Set.foldLeft<Nat64, Nat64>(rbSet, 0, func (x, acc) {x + acc});
    };
    public func foldRight() : async () {
        ignore Set.foldRight<Nat64, Nat64>(rbSet, 0, func (x, acc) {x + acc});
    };
    public func mapfilter() : async () {
        ignore setOps.mapFilter<Nat64>(rbSet, func (elem) {
          switch (elem % 2) {
            case 1 { null };
            case _ { ?elem }
          };
        })
    };
    public func map() : async () {
      ignore setOps.map<Nat64>(rbSet, func (elem) {elem + elem})
    };
}
