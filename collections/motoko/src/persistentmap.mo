import Map "mo:base/PersistentOrderedMap";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Random "random";
import Profiling "../../../utils/motoko/Profiling";

actor {
    stable let profiling = Profiling.init();

    stable var rbMap = Map.empty<Nat64, Nat64>();
    let rand = Random.new(null, 42);

    public func generate(size: Nat32) : async () {
        let rand = Random.new(?size, 1);
        let iter = Iter.map<Nat64, (Nat64, Nat64)>(rand, func x = (x, x));
        rbMap := Map.Internal.fromIter(iter, Nat64.compare);
    };
    public query func get_mem() : async (Nat,Nat,Nat) {
        Random.get_memory()
    };
    public func batch_get(n : Nat) : async () {
        for (_ in Iter.range(1, n)) {
            ignore Map.Internal.get(rbMap, Nat64.compare, Option.get<Nat64>(rand.next(), 0));
        }
    };
    public func batch_put(n : Nat) : async () {
        for (_ in Iter.range(1, n)) {
            let k = Option.get<Nat64>(rand.next(), 0);
            rbMap := Map.Internal.put(rbMap, Nat64.compare, k, k);
        }
    };
    public func batch_remove(n : Nat) : async () {
        let rand = Random.new(null, 1);
        for (_ in Iter.range(1, n)) {
            rbMap := Map.Internal.delete(rbMap, Nat64.compare, Option.get<Nat64>(rand.next(), 0));
        }
    };
    public func foldLeft() : async () {
        ignore Map.foldLeft<Nat64, Nat64, Nat64>(rbMap, 0, func (x, y, acc) {x + y + acc});
    };
    public func foldRight() : async () {
        ignore Map.foldRight<Nat64, Nat64, Nat64>(rbMap, 0, func (x, y, acc) {x + y + acc});
    };
    public func mapfilter() : async () {
        ignore Map.Internal.mapFilter<Nat64, Nat64, Nat64>(rbMap, Nat64.compare, func (key, value) {
          switch (key % 2) {
            case 1 { null };
            case _ { ?value }
          };
        })
    };
    public func map() : async () {
      ignore Map.map<Nat64, Nat64, Nat64>(rbMap, func (key, value) {key + value})
    };
}
