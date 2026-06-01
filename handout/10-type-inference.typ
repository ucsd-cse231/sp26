#import "@preview/codly:1.3.0": *
#import "tufte-handout.typ": margin-note, template

#show: codly-init.with()
#codly(
  number-format: none,
  zebra-fill: none,
  display-name: false,
)

#let show-toggle = false

#show raw.where(block: true): it => {
  if it.lang == "rust-toggle" and show-toggle {
    let lines = it.text.split("\n")
    let new-lines = lines.map(line => if line.starts-with("// ") { line.slice(3) } else { line })
    let new-text = new-lines.join("\n")
    set text(size: 1.25em)
    block(width: 100%, raw(new-text, lang: "rust", block: true))
  } else if it.lang == "rust-toggle" {
    set text(size: 1.25em)
    let lines = it.text.split("\n")
    let new-lines = lines.map(line => if line.starts-with("//") { " " } else { line })
    let new-text = new-lines.join("\n")
    block(width: 100%, raw(new-text, lang: "rust", block: true))
  } else if it.lang == "clojure-toggle" and show-toggle {
    let lines = it.text.split("\n")
    let new-lines = lines.map(line => if line.starts-with(";; ") { line.slice(3) } else { line })
    let new-text = new-lines.join("\n")
    set text(size: 1.25em)
    block(width: 100%, raw(new-text, lang: "clojure", block: true))
  } else if it.lang == "clojure-toggle" {
    set text(size: 1.25em)
    let lines = it.text.split("\n")
    let new-lines = lines.map(line => if line.starts-with(";;") { " " } else { line })
    let new-text = new-lines.join("\n")
    block(width: 100%, raw(new-text, lang: "clojure", block: true))
  } else {
    block(width: 100%, it)
  }
}

#set page(footer: context align(center, text(size: 7pt, counter(page).display("1"))))

#show: doc => template(
  title: "CSE 231: Type Inference (Harlequin)",
  author: "Ranjit Jhala",
  date: "June 2, 2026",
  doc,
)

= Harlequin

`fer-de-lance` with two changes:

- *replace* unbounded tuples, with _pairs_,
- *add* _static types_.

That is,

- extend `checker` with a proper type system,
- `compile` _only_ if code type-checks.

== Why?

What are some benefits of compile-time type checking?

```rust-toggle
// eliminate *dynamic tests*
// - arithmetic args are actually numbers,
// - branch conditions are actually booleans,
// - tuple accesses are actually on tuples,
// - that call-targets are actually functions,
// - the arity of function calls,



```

= Strategy

Lets start with an informal overview of our strategy for type inference;
as usual we will then formalize and implement this strategy.

The core idea is this:

+ *Traverse* the `Expr` ...
+ *Generating* fresh variables for unknown types...
+ *Unifying* function input types with their arguments ...
+ *Substituting* solutions for variables to infer types.

Lets do the above procedure informally for a couple of examples!

== Example 1: Inputs and Outputs

```clojure
(defn (incr x) (+ x 1))

(incr input)
```

== Example 2: Polymorphism

```clojure
(defn (id x) x)

(let* ((a1 (id 7))
       (a2 (id true)))
  true)
```

== Example 3: Higher-Order Functions

```clojure
(defn (f it x)
  (+ (it x) 1))

(defn (incr z)
  (+ z 1))

(f incr 10)
```

== Example 4: Lists

```clojure
;; --- an API for lists --------------------------------------
(defn (nil) (as (forall (a) (-> () (list a))))
  false)

(defn (cons h t) (as (forall (a) (-> (a (list a)) (list a))))
  (vec h t))

(defn (head l) (as (forall (a) (-> ((list a)) a)))
  (vec-get l 0))

(defn (tail l) (as (forall (a) (-> ((list a)) (list a))))
  (vec-get l 1))

(defn (isnil l) (as (forall (a) (-> ((list a)) bool)))
  (= l false))

;;--- computing with lists ----------------------------------

(defn (length xs)
  (if (isnil xs)
    0
    (+ 1 (length (tail xs)))))

(defn (sum xs)
  (if (isnil xs)
    0
    (+ (head xs) (sum (tail xs)))))

(let (xs  (cons 10 (cons 20 (cons 30 (nil)))))
  (vec (length xs) (sum xs)))
```


== Strategy Recap

+ *Traverse* the `Expr` ...
+ *Fresh* variables for unknown types...
+ *Unifying* function input types with their arguments ...
+ *Substituting* solutions for variables to infer types ...
+ *Generalizing* types into polymorphic functions ...
+ *Instantiating* polymorphic type variables at each use-site.

= Plan

+ Types
+ Expressions
+ Variables & Substitution
+ Unification
+ Generalize & Instantiate
+ Inferring Types
+ Extensions

= Syntax of Types

First, lets see how the syntax of our `garter` changes to
enable static types.

A `Type` is one of:

```rust
pub enum Ty {
  Int,
  Bool,
  Fun(Vec<Ty>, Box<Ty>),
  Var(TyVar),
  Vec(Box<Ty>, Box<Ty>),
  Ctor(TyCtor, Vec<Ty>),
}
```

Here `TyCtor` and `TyVar` are just string names:

```rust
pub struct TyVar(String);  // e.g. "a", "b", "c"

pub struct TyCtor(String); // e.g. "List", "Tree"
```

Finally, a *polymorphic type* is represented as:

```rust
pub struct Poly {
  pub vars: Vec<TyVar>,
  pub ty: Ty,
}
```

== Monomorphic Types

A function that takes two input `Int` and returns an output `Int`
has the _monomorphic_ type `(-> (Int Int) Int)` which we would
represent as a `Poly` value:

```rust
forall(vec![], fun(vec![Ty::Int, Ty::Int], Ty::Int))
```

*Note:* If a function is *monomorphic* (i.e. _not polymorphic_),
we can just use the empty vec of `TyVar`.

== Polymorphic Types

A function that takes a value of *any* type and returns a value of *the same* type has the _polymorphic_ type `(forall (a) (-> (a) a))` which we would represent as:

```rust
forall(
    vec![tv("a")],
    fun(vec![Ty::Var(tv("a"))],
        Box::new(Ty::Var(tv("a")))),
)
```

Similarly, a function that takes two values and returns the first
can be given a `Poly` type `(forall (a b) (-> (a b) a))`:

```rust
forall(
    vec![tv("a"), tv("b")],
    fun(vec![Ty::Var(tv("a")), Ty::Var(tv("b"))],
        Ty::Var(tv("a"))))
)
```

= Syntax of Expressions

To enable inference `harlequin` simplifies the language a little bit.

- _Dynamic tests_ `isNum` and `isBool` are removed,
- _Tuples_ always have exactly _two_ elements; you can represent `(vec e1 e2 e3)` as `(vec e1 (vec e2 e3))`.
- _Tuple_ access is limited to the fields `Zero` and `One` (instead of arbitrary expressions).

```rust
pub enum ExprKind<Ann>{
  ...
  Vek(Box<Expr<Ann>>, Box<Expr<Ann>>),  // Tuples have 2 elems
  Get(Box<Expr<Ann>>, Index),           // Get 0-th or 1-st elem
  Fun(Defn<Ann>),                       // Named functions
}

pub enum Index {
    Zero,                               // 0-th field
    One,                                // 1-st field
}
```

#v(0.5em)
*Plan:*
+ Types
+ Expressions
+ *Variables & Substitution*
+ Unification
+ Generalize & Instantiate
+ Inferring Types
+ Extensions

= Substitutions

Our informal algorithm proceeds by

- Generating *fresh type* variables for unknown types,
- Traversing the `Expr` to *unify* the types of sub-expressions,
- By *substituting* a type _variable_ with a whole _type_.

Lets formalize _substitutions_, and use it to define unification.

== Representing Substitutions

We represent substitutions as a record with two fields:

```rust
struct Subst {
    /// hashmap from type-var |-> type
    map: HashMap<TyVar, Ty>,
    /// counter used to generate fresh type variables
    idx: usize,
}
```

- `map` is a *map* from type variables to types,
- `idx` is a *counter* used to generate *new* type variables.

For example, `ex_subst()` is a substitution that maps `a`, `b` and `c` to
`int`, `bool` and `(-> (int int) int)` respectively.

```rust
let ex_subst = Subst::new(&[
  (tv("a"), Ty::Int),
  (tv("b"), Ty::Bool),
  (tv("c"), fun(vec![Ty::Int, Ty::Int], Ty::Int)),
]);
```

== Applying Substitutions

The main _use_ of a substitution is to *apply* it to a type, which
has the effect of _replacing_ each occurrence of a type variable
with its substituted value (or leaving it untouched if it is not
mentioned in the substitution.)

We define an interface for "things that can be substituted" as:

```rust
trait Subable {
  fn apply(&self, subst: &Subst) -> Self;
  fn free_vars(&self) -> HashSet<TyVar>;
}
```

and then we define how to `apply` substitutions to `Type`, `Poly`,
and lists and maps of `Type` and `Poly`.

For example,

```rust
let ty = fun(vec![tyv("a"), tyv("z")], tyv("b"));
ty.apply(&ex_subst)
```

returns a type like

```rust
fun(vec![Ty::Int, tyv("z")], Ty::Bool)
```

by replacing `"a"` and `"b"` with `Ty::Int` and `Ty::Bool`
and leaving `"z"` alone.

== QUIZ

Recall that `let ex_subst = ["a" |-> Ty::Int, "b" |-> Ty::Bool]`...

What should be the result of

```rust
let ty = forall(vec!["a"], fun(vec![tyv("a")], tyv("a")));
ty.apply(ex_subst)
```

+ `forall(vec!["a"], fun(vec![Ty::Int ], Ty::Bool))`
+ `forall(vec!["a"], fun(vec![tyv("a")], tyv("a")))`
+ `forall(vec!["a"], fun(vec![tyv("a")], Ty::Bool))`
+ `forall(vec!["a"], fun(vec![Ty::Int ], tyv("a")))`
+ `forall(vec![   ], fun(vec![Ty::Int ], Ty::Bool))`

== Bound vs. Free Type Variables

Indeed, the type `(forall (a) (-> (a) a))` is identical to `(forall (z) (-> (z) z))`.

- A *bound* type variable is one that appears under a `forall`.
- A *free* type variable is one that is *not* bound.

We should only substitute *free type variables*.

#colbreak()

== Applying Substitutions (Implementation)

Keeping the above in mind, we can define `apply` as a recursive traversal:

```rust
fn apply(&self, subst: &Subst) -> Self {
  let mut subst = subst.clone();
  subst.remove(&self.vars);
  forall(self.vars.clone(), self.ty.apply(&subst))
}

fn apply(ty: &Ty, subst: &Subst) -> Self {
  match ty {
    Ty::Int => Ty::Int,
    Ty::Bool => Ty::Bool,
    Ty::Var(a) => subst.lookup(a)
                    .unwrap_or(Ty::Var(a.clone())),
    Ty::Fun(in_tys, out_ty) => {
      let in_tys = in_tys.iter()
                    .map(|ty| ty.apply(subst)).collect();
      let out_ty = out_ty.apply(subst);
      fun(in_tys, out_ty)
    }
    Ty::Vec(ty0, ty1) => {
      let ty0 = ty0.apply(subst);
      let ty1 = ty1.apply(subst);
      Ty::Vec(Box::new(ty0), Box::new(ty1))
    }
    Ty::Ctor(c, tys) => {
      let tys = tys.iter()
                  .map(|ty| ty.apply(subst)).collect();
      Ty::Ctor(c.clone(), tys)
    }
  }
}
```

where `subst.remove(vs)` *removes* the mappings for `vs` from `subst`.

== Creating Substitutions

We can start with an *empty substitution* that maps no variables:

```rust
fn new() -> Subst {
  Subst { map: Hashmap::new(), idx: 0 }
}
```

== Extending Substitutions

We can *extend* the substitution by assigning a variable `a` to type `t`:

```rust
fn extend(&mut self, tv: &TyVar, ty: &Ty) {
  // create a new substitution tv |-> ty
  let subst_tv_ty =
      Self::new(&[(tv.clone(), ty.clone())]);
  // apply tv |-> ty to all existing mappings
  let mut map = hashmap! {};
  for (k, t) in self.map.iter() {
      map.insert(k.clone(), t.apply(&subst_tv_ty));
  }
  // add new mapping
  map.insert(tv.clone(), ty.clone());
  self.map = map
}
```

*Telescoping:*
Note that when we extend `[b |-> a]` by assigning `a` to `Int` we must
take care to also update `b` to now map to `Int`. That is why we:

+ Create a new substitution `[a |-> Int]`
+ Apply it to each binding in `self.map` to get `[b |-> Int]`
+ Insert it to get the extended substitution `[b |-> Int, a |-> Int]`

#v(0.5em)
*Plan:*
+ Types
+ Expressions
+ Variables & Substitution
+ *Unification*
+ Generalize & Instantiate
+ Inferring Types
+ Extensions

= Unification

Next, lets use `Subst` to implement a procedure to `unify` two types,
i.e. to determine the conditions under which the two types are _the same_.

#table(
  columns: 4,
  align: left,
  table.header([*T1*], [*T2*], [*Unified*], [*Substitution*]),
  [`Int`], [`Int`], [`Int`], [`empSubst`],
  [`a`], [`Int`], [`Int`], [`a |-> Int`],
  [`a`], [`b`], [`b`], [`a |-> b`],
  [`a -> b`], [`a -> d`], [`a -> d`], [`b |-> d`],
  [`a -> Int`], [`Bool -> b`], [`Bool -> Int`], [`a |-> Bool, b |-> Int`],
  [`Int`], [`Bool`], [_Error_], [_Error_],
  [`Int`], [`a -> b`], [_Error_], [_Error_],
  [`a`], [`a -> Int`], [_Error_], [_Error_],
)

- The first few cases: unification is possible.
- The last few cases: unification fails, i.e. type error in source!

*Occurs Check:*
The very last failure: `a` in the first type *occurs inside*
free inside the second type!
If we try substituting `a` with `a -> Int` we will just keep
spinning forever! Hence, this also throws a unification failure.

*Exercise:* Can you think of a program that would trigger the _occurs check_ failure?

== Implementing Unification

We implement unification as a function:

```rust
fn unify<A: Span>(
  ann: &A, subst: &mut Subst, t1: &Ty, t2: &Ty
) -> Result<(), Error>
```

such that `unify(ann, subst, t1, t2)` either *extends* `subst` with assignments needed to make `t1` the same as `t2`, or returns an *error* if the types cannot be unified.

```rust
fn unify<A: Span>(
  ann: &A, subst: &mut Subst, t1: &Ty, t2: &Ty
) -> Result<(), Error> {
  match (t1, t2) {
    (Ty::Int, Ty::Int)
    | (Ty::Bool, Ty::Bool) => Ok(()),
    (Ty::Fun(ins1, out1), Ty::Fun(ins2, out2)) => {
      unifys(ann, subst, ins1, ins2)?;
      let out1 = out1.apply(subst);
      let out2 = out2.apply(subst);
      unify(ann, subst, &out1, &out2)
    }
    (Ty::Ctor(c1, t1s), Ty::Ctor(c2, t2s))
      if *c1 == *c2 =>
        unifys(ann, subst, t1s, t2s),
    (Ty::Vec(s1, s2), Ty::Vec(t1, t2)) => {
      unify(ann, subst, s1, t1)?;
      let s2 = s2.apply(subst);
      let t2 = t2.apply(subst);
      unify(ann, subst, &s2, &t2)
    }
    (Ty::Var(a), t) | (t, Ty::Var(a)) =>
      var_assign(ann, subst, a, t),
    (_, _) => Err(Error::new(
      ann.span(),
      format!{"Type Error: cannot unify {t1} and {t2}"},
    ))
  }
}
```

The helpers:

- `unifys` recursively calls `unify` on _sequences_ of types,
- `var_assign` extends `su` with `[a |-> t]` if *required* and *possible*:

```rust
fn var_assign<A: Span>(
  ann: &A, subst: &mut Subst, a: &TyVar, t: &Ty
) -> Result<(), Error> {
  if *t == Ty::Var(a.clone()) {
    Ok(())
  } else if t.free_vars().contains(a) {
    Err(Error::new(
      ann.span(),
      "occurs check error".to_string()))
  } else {
    subst.extend(a, t);
    Ok(())
  }
}
```

We can test out the above table:

```rust
#[test]
fn unify0() {
  let mut subst = Subst::new(&[]);
  let _ = unify(&(0, 0), &mut subst,
                &Ty::Int, &Ty::Int);
  assert!(format!("{:?}", subst)
    == "Subst { map: {}, idx: 0 }")
}

#[test]
fn unify1() {
  let mut subst = Subst::new(&[]);
  let t1 = fun(vec![tyv("a")], Ty::Int);
  let t2 = fun(vec![Ty::Bool], tyv("b"));
  let _ = unify(&(0, 0), &mut subst, &t1, &t2);
  assert!(subst.map
    == hashmap! {tv("a") => Ty::Bool,
                 tv("b") => Ty::Int})
}

#[test]
fn unify2() {
  let mut subst = Subst::new(&[]);
  let t1 = tyv("a");
  let t2 = fun(vec![tyv("a")], Ty::Int);
  let res = unify(&(0, 0), &mut subst, &t1, &t2)
              .err().unwrap();
  assert!(format!("{res}")
    == "occurs check error: a occurs in (-> (a) int)")
}

#[test]
fn unify3() {
  let mut subst = Subst::new(&[]);
  let res = unify(&(0, 0), &mut subst,
              &Ty::Int, &Ty::Bool).err().unwrap();
  assert!(format!("{res}")
    == "Type Error: cannot unify int and bool")
}
```

#v(0.5em)
*Plan:*
+ Types
+ Expressions
+ Variables & Substitution
+ Unification
+ *Generalize & Instantiate*
+ Inferring Types
+ Extensions

= Generalize and Instantiate

Recall the example:

```clojure
(defn (id x) x)

(let* ((a1 (id 7))
       (a2 (id true)))
  true)
```

For the expression `(defn (id x) x)` we inferred the type `(-> (a0) a0)`.

We needed to *generalize* the above to assign `id` the `Poly`\-type: `(forall (a0) (-> (a0) a0))`.

We needed to *instantiate* the above `Poly`\-type at each _use_:

- at `(id 7)` the function `id` has type `(-> (int) int)`
- at `(id true)` the function `id` has type `(-> (bool) bool)`

Lets see how to implement those two steps.

== Type Environments

To `generalize` a type, we:

+ Compute its (free) type variables,
+ Remove the ones that may still be constrained by _other_ in-scope program variables.

We represent the types of *in scope* program variables as a *type environment*:

```rust
struct TypeEnv(HashMap<String, Poly>);
```

i.e. a `Map` from program variables `Id` to their (inferred) `Poly` type.

== Generalize

We can now implement `generalize` as:

```rust
fn generalize(env: &TypeEnv, ty: Ty) -> Poly {
    // 1. compute ty_vars of `ty`
    let ty_vars = ty.free_vars();
    // 2. compute ty_vars of `env`
    let env_vars = env.free_vars();
    // 3. compute unconstrained vars: (1) minus (2)
    let tvs = ty_vars.difference(env_vars)
                      .into_iter().collect();
    // 4. slap a `forall` on the unconstrained `tvs`
    forall(tvs, ty)
}
```

The helper `free_vars` computes the set of variables
that appear inside a `Type`, `Poly` and `TypeEnv`:

```rust
// Free Variables of a Type
fn free_vars(ty: &Ty) -> HashSet<TyVar> {
  match ty {
    Ty::Int | Ty::Bool => hashset! {},
    Ty::Var(a) => hashset! {a.clone()},
    Ty::Fun(in_tys, out_ty) =>
      free_vars_many(in_tys).union(out_ty.free_vars()),
    Ty::Vec(t0, t1) =>
      t0.free_vars().union(t1.free_vars()),
    Ty::Ctor(_, tys) => free_vars_many(tys),
  }
}

// Free Variables of a Poly
fn free_vars(poly: &Poly) -> HashSet<TyVar> {
  let bound_vars = poly.vars.clone().into();
  poly.ty.free_vars().difference(bound_vars)
}

// Free Variables of a TypeEnv
fn free_vars(env: &TypeEnv) -> HashSet<TyVar> {
  let mut res = HashSet::new();
  for poly in self.0.values() {
      res = res.union(poly.free_vars());
  }
  res
}
```

== Instantiate

To *instantiate* a `Poly` of the form `forall(vec![a1,...,an], ty)` we:

+ Generate *fresh* type variables, `b1,...,bn` for each "parameter" `a1...an`,
+ Substitute `[a1 |-> b1,...,an |-> bn]` in the "body" `ty`.

For example, to instantiate

```rust
forall(vec![tv("a")], fun(vec![tyv("a")], tyv("a")))
```

we:

+ Generate a fresh variable e.g. `"a66"`,
+ Substitute `["a" |-> "a66"]` in the body

to get

```rust
fun(vec![tyv("a66")], tyv("a66"))
```

== Implementing Instantiate

```rust
fn instantiate(&mut self, poly: &Poly) -> Ty {
  let mut tv_tys = vec![];
  // 1. Generate fresh type variables for each poly var
  for tv in &poly.vars {
      tv_tys.push((tv.clone(), self.fresh()));
  }
  // 2. Substitute in the body `ty`
  let su_inst = Subst::new(&tv_tys);
  poly.ty.apply(&su_inst)
}
```

*Question:* Why does `instantiate` *update* a `Subst`?

Lets run it and see what happens!

```rust
let t_id = forall(
  vec![tv("a")],
  fun(vec![tyv("a")], tyv("a")));

let mut subst = Subst::new(&[]);

let ty0 = subst.instantiate(&t_id);
let ty1 = subst.instantiate(&t_id);
let ty2 = subst.instantiate(&t_id);

assert!(ty0 == fun(vec![tyv("a0")], tyv("a0")));
assert!(ty1 == fun(vec![tyv("a1")], tyv("a1")));
assert!(ty2 == fun(vec![tyv("a2")], tyv("a2")));
```

The `fresh` calls *bump up* the counter (so we _actually_ get fresh variables).

#v(0.5em)
*Plan:*
+ Types
+ Expressions
+ Variables & Substitution
+ Unification
+ Generalize & Instantiate
+ *Inferring Types*
+ Extensions

= Inference

Finally, we have all the pieces to implement the actual
*type inference* procedure `infer`:

```rust
fn infer<A: Span>(
  env: &TypeEnv,
  subst: &mut Subst,
  e: &Expr<A>
) -> Result<Ty, Error>
```

which takes as _input_:

+ A `TypeEnv` (`env`) mapping in-scope variables to their previously inferred (`Poly`)\-types,
+ A `Subst` (`subst`) containing the _current_ substitution/fresh-variable-counter,
+ An `Expr` (`e`) whose type we want to infer,

and

- _returns_ as output the *inferred type* for `e` (or an `Error` if no such type exists), and
- _updates_ `subst` by generating *fresh type* variables and doing the *unifications* needed to check the `Expr`.

Lets look at how `infer` is implemented for the different cases of expressions.

== Inference: Literals

For numbers and booleans, we just return the respective type and the input `Subst` without any modifications.

```rust
Num(_) | Input => Ty::Int,
True | False => Ty::Bool,
```

== Inference: Variables

For identifiers, we *lookup* their type in the `env` and *instantiate* type-variables to get _different types at different uses_.

```rust
Var(x) => subst.instantiate(env.lookup(x)?),
```

Why do we _instantiate_? Recall the `id` example!

== Inference: Let-bindings

```rust
Let(x, e1, e2) => {
  let t1   = infer(env, subst, e1)?;          // (1)
  let env1 = env.apply(subst);                // (2)
  let s1   = generalize(&env1, t1);           // (3)
  let env2 = env1.extend(&[(x.clone(), s1)]); // (4)
  infer(&env2, subst, e2)?                    // (5)
}
```

In essence,

+ *Infer* the type `t1` for `e1`,
+ *Apply* the substitutions from (1) to the `env`,
+ *Generalize* `t1` to make it a `Poly` type `s1`,
+ *Extend* the env to map `x` to `s1` and,
+ *Infer* the type of `e2` in the extended environment.

== Inference: Function Definitions

```rust
fn infer_defn<A: Span>(
  env: &TypeEnv, subst: &mut Subst, defn: &Defn<A>
) -> Result<Ty, Error> {
  // 1. Generate a fresh template for the function
  let (in_tys, out_ty) = fresh_fun(defn, subst);

  // 2. Add the types of the params to the environment
  let mut binds = vec![];
  for (x, ty) in defn.params.iter().zip(&in_tys) {
    binds.push((x.clone(), mono(ty.clone())))
  }
  let env = env.extend(&binds);

  // 3. Infer the type of the body
  let body_ty = infer(&env, subst, &defn.body)?;

  // 4. Unify the body type with the output type
  unify(&defn.body.ann, subst,
        &body_ty, &out_ty.apply(subst))?;

  // 5. Return the function's template after applying subst
  Ok(fun(in_tys.clone(), out_ty.clone()).apply(subst))
}
```

Inference works as follows:

+ Generate a _function type_ with fresh variables for the unknown inputs (`in_tys`) and output (`out_ty`),
+ Extend the `env` so the parameters `xs` have types `in_tys`,
+ Infer the type of `body` under the extended `env` as `body_ty`,
+ Unify the _expected_ output `out_ty` with the _actual_ `body_ty`,
+ Apply the substitutions to infer the function's type.

#colbreak()

== Inference: Function Calls

```rust
fn infer_app<A: Span>(
    ann: &A,
    env: &TypeEnv,
    subst: &mut Subst,
    poly: Poly,
    args: &[Expr<A>],
) -> Result<Ty, Error> {
    // 1. Infer the types of input `args` as `in_tys`
    let mut in_tys = vec![];
    for arg in args {
        in_tys.push(infer(env, subst, arg)?);
    }
    // 2. Generate a variable for the unknown output type
    let out_ty = subst.fresh();

    // 3. Unify actual input-output with expected `mono`
    let mono = subst.instantiate(&poly);
    unify(ann, subst, &mono,
          &fun(in_tys, out_ty.clone()))?;

    // 4. Return the (substituted) `out_ty`
    Ok(out_ty.apply(subst))
}
```

The code works as follows:

+ Infer the types of the inputs `args` as `in_tys`,
+ Generate a template `out_ty` for the unknown output type,
+ Unify the actual input-output with the expected `mono`,
+ Return the (substituted) `out_ty` as the inferred type of the expression.

#v(0.5em)
*Plan:*
+ Types
+ Expressions
+ Variables & Substitution
+ Unification
+ Generalize & Instantiate
+ Inferring Types
+ *Extensions*

= Extensions

The above gives you the basic idea, now _you_ will have to
implement a bunch of extensions.

+ Primitives e.g. `add1`, `sub1`, comparisons etc.
+ (Recursive) Functions
+ Type Checking

== Extensions: Primitives

What about _primitives_? `add1(e)`, `print(e)`, `e1 + e2` etc.

What about _branches_? `if cond: e1 else: e2`

What about _tuples_? `(e1, e2)` and `e[0]` and `e[1]`

All of the above can be handled as *applications* to special functions.

For example, you can handle `add1(e)` by treating it
as passing a parameter `e` to a function with type:

```
(-> (int) int)
```

Similarly, handle `e1 + e2` by treating it as passing the
parameters `[e1, e2]` to a function with type:

```
(-> (int int) int)
```

Can you figure out how to similarly account for branches, tuples, etc. by
filling in suitable implementations?

== Extensions: (Recursive) Functions

Extend or modify the code for handling `Defn` so that you can handle recursive functions.

- You can basically reuse the code as is
- *Except* if `f` appears in the body of `e`

Can you figure out how to modify the environment under
which `e` is checked to handle the above case?

== Extensions: Type Checking

While inference is great, it is often useful to _specify_ the types.

- They can describe behavior of _untyped code_
- They can be nice _documentation_, e.g. when we want a function to have a more _restrictive_ type.

=== Assuming Specifications for Untyped Code

For example, we can *implement* lists as tuples and tell the
type system to *trust the implementation* of the core list library API,
but *verify the uses* of the list library.

We do this by:

```clojure
;; list "stdlib" (unchecked) -------------------------
(defn (nil) (as (forall (a) (-> () (list a))))
  false)

(defn (cons h t)
  (as (forall (a) (-> (a (list a)) (list a))))
  (vec h t))

(defn (head l) (as (forall (a) (-> ((list a)) a)))
  (vec-get l 0))

(defn (tail l)
  (as (forall (a) (-> ((list a)) (list a))))
  (vec-get l 1))

(defn (isnil l)
  (as (forall (a) (-> ((list a)) bool)))
  (= l false))

;; ---------------------------------------------------

(defn (length l)
  (if (isnil l)
      0
      (+ 1 (length (tail l)))))

(let (l0 (cons 0 (cons 1 (cons 2 (nil)))))
  (length l0))
```

The `as` keyword tells the system to *trust* the signature,
i.e. to *assume* it is ok, and to *not check* the implementations
of the function.

However, the signatures are *used* to ensure that `nil`, `cons` and `tail`
are used properly, for example, if we tried

```clojure
(let (xs (cons 10 (cons true (cons 30 (nil)))))
  (vec (head 10) (tail xs)))
```

we should get an error:

```
error: Type Error: cannot unify bool and int
   ┌─ tests/list2-err.snek:19:20
   │
19 │ (let (xs  (cons 10 (cons true ...)))
   │                    ^^^^^^^^^^^^^^^^^
```

=== Checking Specifications

Sometimes we may want to restrict a function to be used
to some more _specific_ type than what would be inferred.

`garter` allows for specifications on functions using the `is`
operator. For example, you may want a special function that
just compares two `Int` for equality:

```clojure
(defn (eqInt x y) (is (-> (int int) bool))
  (= x y))

(eqInt 17 19)
```

As another example, you might write a `swapList` function
that swaps *pairs of lists*. The same code would
swap arbitrary pairs, but lets say you really want
it to work just for lists:

```clojure
(defn (swapList p)
  (is (forall (a b)
    (-> ((vec (list a) (list b)))
        (vec (list b) (list a)))))
  (vec (vec-get p 1) (vec-get p 0)))

(let*
    ((l0 (cons 1 (nil)))
     (l1 (cons true (nil))))
  (swapList (vec l0 l1)))
```

Can you figure out how to extend the `ti` procedure to
handle the case of `Fun f (Check s) xs e`, and thus allow
for *checking type specifications*?

*HINT:* You may want to _factor_ out steps 2--5 in the `infer_defn`
definition --- i.e. the code that checks the `body` has type `out_ty`
when `xs` have type `in_tys` --- into a separate function to implement
the `infer` cases for the different `Sig` values.

This is a bit tricky, and so am leaving it as *Extra Credit*.

== Recommended TODO List

+ Copy over the relevant compilation code from `fdl`
  - Modify tuple implementation to work for pairs
  - You can remove the dynamic tests (except overflow!)
+ Fill in the signatures to get inference for `add1`, `+`, `(if ...)` etc.
+ Complete the cases for `vec` and `vec-get` to get inference for pairs.
+ Extend `infer` to get inference for (recursive) functions.
+ Complete the `Ctor` case to get inference for constructors (e.g. `(list a)`).
+ Complete `check` to implement *checking* of user-specified types *(extra credit)*.
