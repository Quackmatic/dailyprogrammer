open System

type stick = { n: int; x1: float; y1: float; x2: float; y2: float }

let stickFromString (s: string) =
    let parts = s.Split(',', ':')
    let n, x1, y1, x2, y2 =
        Int32.Parse parts.[0],
        Double.Parse parts.[1],
        Double.Parse parts.[2],
        Double.Parse parts.[3],
        Double.Parse parts.[4]
    if x2 > x1 then
        { n = n; x1 = x1; y1 = y1; x2 = x2; y2 = y2 }
    else
        { n = n; x1 = x2; y1 = y2; x2 = x1; y2 = y1 }

let yAt s x =
    if s.x1 = s.x2 then
        if s.y1 < s.y2 then s.y1 else s.y2
    else
        s.y1 + (s.y2 - s.y1) * (x - s.x1) / (s.x2 - s.x1)

let inColumn s x1 x2 =
    s.x1 <= x2 && s.x2 >= x1

let separate list predicate =
    let rec separateR list tl fl =
        if List.isEmpty list then
            (List.rev tl, List.rev fl)
        else
            let lh = List.head list
            if predicate lh then
                separateR (List.tail list) (lh :: tl) fl
            else
                separateR (List.tail list) tl (lh :: fl)
    separateR list [] []

let isFree sticks stick =
    sticks
    |> List.forall (fun stick2 ->
        if not (inColumn stick2 stick.x1 stick.x2) || stick2.n = stick.n then
            true
        else
            let mid = (Math.Max(stick.x1, stick2.x1) + Math.Min(stick.x2, stick2.x2)) / 2.0
            (yAt stick2 mid) < (yAt stick mid))

let getStickOrder sticks =
    let rec getStickOrderR sticks acc =
        if List.isEmpty sticks then acc else
            let free, trapped = separate sticks (isFree sticks)
            getStickOrderR trapped (List.append acc free)
    getStickOrderR sticks []

[<EntryPoint>]
let main argv = 
    let stickCount = Console.ReadLine() |> Int32.Parse
    let sticks = [for x in 1..stickCount do yield Console.ReadLine() |> stickFromString ]
    let order = getStickOrder sticks |> List.map (fun stick -> stick.n)
    printfn "%s" (String.Join(", ", order))
    Console.ReadKey() |> ignore
    0