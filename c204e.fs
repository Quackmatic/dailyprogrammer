open System
open System.Text.RegularExpressions

type Passage = { speakers: string list; lines: string list }

type Scene = { numeral: string; setting: string; speakers: string list; passages: Passage list }
type Act = { numeral: string; scenes: Scene list }

type Token =
    | OpenAct of numeral: string
    | OpenScene of numeral: string * setting: string
    | OpenPassage of speaker: string list
    | Line of line: string
    | Direction of direction: string
    | Whitespace

type TokenizerRule = { regex: Regex; tokenCreator: GroupCollection -> Token }

let rule regex creator =
    { regex = new Regex(regex, RegexOptions.Multiline); tokenCreator = creator }

let ruleSet = [
    rule @"^[ \t]*$" (fun g -> Whitespace);
    rule @"ACT ([IVX]+)\." (fun g -> OpenAct(g.[1].Value));
    rule @"SCENE ([IVX]+)\. (.+)\.$" (fun g -> OpenScene(g.[1].Value, g.[2].Value));
    rule @"  ([A-Z, ]+)\.$" (fun g -> OpenPassage(g.[1].Value.Split(',')
                                                  |> List.ofArray
                                                  |> List.map (fun s -> s.Trim())));
    rule @"    (.+)$" (fun g -> Line(g.[1].Value));
    rule @"\[(.+?)\]" (fun g -> Direction(g.[1].Value));
    ]

let tokenizeLine line =
    let m, c = 
        ruleSet
        |> List.map (fun r -> r.regex.Match(line), r.tokenCreator)
        |> List.filter (fun r ->
            let m, c = r in m.Success)
        |> List.head
    c m.Groups

let tokenizeLines lines =
    lines
    |> List.map tokenizeLine
    |> List.filter (fun t -> match t with
                             | Whitespace -> false
                             | Direction(_) -> false
                             | _ -> true)

let take l (f: Token list -> 't option * Token list) =
    let rec takeR acc l =
        if List.isEmpty l then
            List.rev acc, l
        else
            let t, l2 = f l
            match t with
            | Some(t) -> takeR (t :: acc) l2
            | None -> List.rev acc, l
    takeR [] l

let parseLines r =
    take r (fun l ->
        let line, r = List.head l, List.tail l in
            match line with
            | Line(line) -> Some(line), r
            | _ -> None, l)

let parseEvents r =
    take r (fun l -> 
        let opening, r = List.head l, List.tail l
        match opening with
        | OpenPassage(speakers) -> 
            let lines, r = parseLines r
            Some({ speakers = speakers; lines = lines }), r
        | _ -> None, l)

let parseScenes r =
    take r (fun l ->
        let opening, r = List.head l, List.tail l
        match opening with
        | OpenScene(numeral, setting) ->
            let passages, r = parseEvents r
            let speakers =
                seq [ for passage in passages do yield! passage.speakers ]
                |> Seq.distinct // bit annoying to have no List.distinct but oh well
                |> Seq.filter ((<>) "ALL")
                |> List.ofSeq
            Some({ numeral = numeral; setting = setting; speakers = speakers; passages = passages }), r
        | _ -> None, l)

let parseActs tokens =
    take tokens (fun l ->
        let opening, r = List.head l, List.tail l
        match opening with
        | OpenAct(numeral) ->
            let scenes, r = parseScenes r
            Some({ numeral = numeral; scenes = scenes }), r
        | _ -> None, l)

let rec readLines acc =
    let line = Console.ReadLine()
    if (List.isEmpty acc |> not && List.head acc = "" && line = "") then
        List.rev acc
    else
        readLines (line :: acc)

[<EntryPoint>]
let main argv = 
    printfn "Copy the text of Macbeth to stdin, with two newlines at the end of the play."
    let acts, _ = [] |> readLines |> tokenizeLines |> parseActs
    printf "Enter your phrase: "
    let phrase = Console.ReadLine().Trim()
    printfn "Possible scenes:"
    printfn ""
    acts |> List.iter (fun act ->
        act.scenes |> List.iter (fun scene -> 
            scene.passages |> List.iter (fun passage -> 
                if passage.lines |> List.exists (fun s -> s.ToLower().Contains(phrase.ToLower())) then
                    printfn "In Act %s, Scene %s. (%s)" act.numeral scene.numeral scene.setting
                    printfn "%s present." (scene.speakers |> String.concat ", ")
                    printfn "  %s:" (passage.speakers |> String.concat ", ")
                    passage.lines |> List.iter (fun line ->
                        printfn "    %s" line)
                    printfn "")))
    Console.ReadKey() |> ignore
    0