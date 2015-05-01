open Util // fs-util available at https://gist.github.com/Quackmatic/2309d4f7b93631c99f22

/// Relation tree structure.
type Relation =
| Add of left: Relation * right: Relation
| Subtract of left: Relation * right: Relation
| Multiply of left: Relation * right: Relation
| Divide of left: Relation * right: Relation
| Constant of value: float
| Relative of offset: int

/// Defined terms needed to begin the series.
type Term = { index : int; value: float }
type Series = { terms: Term list; relation: Relation}

/// Evaluates relation with the given function to get a relative value
let rec evaluateRelation getRelative relation =
    match relation with
    | Add(l, r) -> (evaluateRelation getRelative l) + (evaluateRelation getRelative r)
    | Subtract(l, r) -> (evaluateRelation getRelative l) - (evaluateRelation getRelative r)
    | Multiply(l, r) -> (evaluateRelation getRelative l) * (evaluateRelation getRelative r)
    | Divide(l, r) -> (evaluateRelation getRelative l) / (evaluateRelation getRelative r)
    | Constant(x) -> x
    | Relative(o) -> getRelative o

/// Gets the relative requirements of the given relation, e. if the relation is
/// first-order, return [-1]; ie. needs the value offset -1 from current index.
/// Fibonacci sequence relation would return [-1, -2].
let getRequirements relation =
    let rec getRequirementsR relation =
        match relation with
        | Constant(x) -> []
        | Relative(o) -> [o]
        | Add(l, r) | Subtract(l, r) | Multiply(l, r) | Divide(l, r) -> (getRequirementsR l, getRequirementsR r) ||> List.append
    getRequirementsR relation
    |> List.distinct
    |> List.sort

/// Determines whether the i-th term is defined with the given pre-existing term
let isDefinedAt terms i =
    List.exists (fun x -> terms |> List.exists (fun def -> i + x = def.index) |> not) >> not

/// Evaluates the i-th term of the series
let evaluateAt terms relation i =
    let getPrev i' =
        (terms |> List.filter (fun def -> def.index = i + i') |> List.head).value
    evaluateRelation getPrev relation

/// Converts the given series information to a generator sequence
let toGenerator series limit =
    let reqs = getRequirements series.relation
    let ord  = -(reqs |> List.min)
    let terms =
               series.terms
               |> List.sortBy (fun def -> def.index)
    if List.isEmpty terms then
        failwith "No initial condition."
    else
        let nextTerm terms =
            let startDef, endDef = terms |> List.head, terms |> List.rev |> List.head
            let rec nextTermR i =
                if i < startDef.index + ord then
                    failwith <| sprintf "%d-th term undefined." i
                elif isDefinedAt terms i reqs then
                    let newDef = { index = i; value = evaluateAt terms series.relation i }
                    if newDef.index > limit && limit > 0 then // Give limit 0 or below to go on forever
                        None
                    else
                        Some(newDef, (terms @ [newDef]))
                else
                    nextTermR (i - 1)
            nextTermR (endDef.index + ord)
        terms |> Seq.unfold nextTerm |> (terms |> Seq.ofList |> Seq.append)

/// Parses challenge input for the Easy challenge
let readEasy =
    let relation =
              System.Console.ReadLine()
              |> String.split [" "]
              |> List.fold (fun relation s ->
                             let c, x = s.[0], s.Substring(1) |> float
                             match c with
                             | '+' -> Relation.Add(relation, Relation.Constant(x))
                             | '-' -> Relation.Subtract(relation, Relation.Constant(x))
                             | '*' -> Relation.Multiply(relation, Relation.Constant(x))
                             | '/' -> Relation.Divide(relation, Relation.Constant(x))
                             | _ -> failwith <| sprintf "Unknown operator %c." c) (Relation.Relative(-1))
    let startVal = System.Console.ReadLine() |> float
    { terms = [ { index = 0; value = startVal } ]; relation = relation }

[<EntryPoint>]
let main argv =
    let gen = toGenerator readEasy
    let max = System.Console.ReadLine() |> int
    Seq.iter (fun x ->
        printfn "Term %d: %A" x.index x.value) (gen max)
    System.Console.ReadKey() |> ignore
    0