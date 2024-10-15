import TrieSet "mo:base/TrieSet";
import Nat64 "mo:base/Nat64";
import Hash "mo:base/Hash";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Random "random";
import Profiling "../../../utils/motoko/Profiling";

actor {
    stable let profiling = Profiling.init();

    func hash(x: Nat64) : Nat32 = Hash.hash(Nat64.toNat x);
    var set = TrieSet.empty<Nat64>();
    stable var stableSet : [Nat64] = [];
    let rand = Random.new(null, 42);

    system func preupgrade() {
      stableSet := TrieSet.toArray(set);
    };
    system func postupgrade() {
      set := TrieSet.fromArray(Iter.toArray(stableSet.vals()), hash, Nat64.equal);
    };

    public func generate(size: Nat32) : async () {
        let rand = Random.new(?size, 1);
        let iter = Iter.toArray(rand);
        set := TrieSet.fromArray(iter, hash, Nat64.equal);
    };
    public query func get_mem() : async (Nat,Nat,Nat) {
        Random.get_memory()
    };
    public func batch_get(n : Nat) : async () {
      for (i in Iter.range(1, n)) {
        let elem = Option.get<Nat64>(rand.next(), 0);
        ignore TrieSet.contains<Nat64>(set, elem, hash elem, Nat64.equal);
        }
    };
    public func batch_put(n : Nat) : async () {
        for (_ in Iter.range(1, n)) {
            let elem = Option.get<Nat64>(rand.next(), 0);
            ignore TrieSet.put(set, elem, hash elem, Nat64.equal);
        }
    };
    public func batch_remove(n : Nat) : async () {
      let rand = Random.new(null, 1);
      for (_ in Iter.range(1, n)) {
        let elem = Option.get<Nat64>(rand.next(), 0);
        ignore TrieSet.delete(set, elem, hash elem, Nat64.equal);
      }
    };

    public func intersect(n : Nat32) : async () {
      let rand = Random.new (?n, 1);
      let iter = Iter.toArray(rand);
      let set2 = TrieSet.fromArray(iter, hash, Nat64.equal);
      ignore TrieSet.intersect(set, set2, Nat64.equal)
    };

    public func union(n : Nat32) : async () {
      let rand = Random.new (?n, 1);
      let iter = Iter.toArray(rand);
      let set2 = TrieSet.fromArray(iter, hash, Nat64.equal);
      ignore TrieSet.union(set, set2, Nat64.equal)
    };

    public func diff(n : Nat32) : async () {
      let rand = Random.new (?n, 1);
      let iter = Iter.toArray(rand);
      let set2 = TrieSet.fromArray(iter, hash, Nat64.equal);
      ignore TrieSet.diff(set, set2, Nat64.equal)
    };

    public func equal(n : Nat32) : async () {
      let rand = Random.new (?n, 1);
      let iter = Iter.toArray(rand);
      let set2 = TrieSet.fromArray(iter, hash, Nat64.equal);
      ignore TrieSet.equal(set, set2, Nat64.equal)
    };

    public func equals(n : Nat32) : async () {
      ignore TrieSet.equal(set, set, Nat64.equal)
    };

    public func isSubset(n : Nat32) : async () {
      ignore TrieSet.isSubset(set, set, Nat64.equal)
    };
}
