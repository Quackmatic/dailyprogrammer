open System

type Vec = { x: int; y: int }
type Tile = { pos: Vec; size: Vec; fill: char }
type Grid = { size: Vec; data: char[,] }

/// Creates a Vec from x and y
let vec x y =
    { x = x; y = y }

/// Determines if Vec v is in tile
let inTile v tile =
    v.x >= tile.pos.x &&
    v.y >= tile.pos.y &&
    v.x < tile.pos.x + tile.size.x &&
    v.y < tile.pos.y + tile.size.y

/// Gets the size of the grid from the user
let getGridSize = 
    let line = Console.ReadLine().Split(' ') |> Array.map int
    vec line.[0] line.[1]

/// Transposes a 2D array... why is there no built-in for this?
let transpose (arr: 'a[,]) =
    let w, h = arr.GetLength(0), arr.GetLength(1)
    Array2D.init h w (fun x y -> arr.[y, x])

/// Gets the grid data from the user
let getGrid size =
    { size = size; data = (fun i -> Console.ReadLine().ToCharArray()
                                    |> Seq.ofArray)
                          |> Seq.init size.y 
                          |> array2D
                          |> transpose }

/// Extracts a grid tile from the given top-left point of a tile
let extractTile grid topLeft =
    let fillChar = grid.data.[topLeft.x, topLeft.y]
    let rec extractTileR x y =
        if x + 1 < grid.size.x &&
           grid.data.[x + 1, y] = fillChar then
            extractTileR (x + 1) y
        else
            if y + 1 < grid.size.y &&
               grid.data.[x, y + 1] = fillChar then
                extractTileR x (y + 1)
            else
                vec x y
    let bottomRight = extractTileR topLeft.x topLeft.y
    { pos = topLeft; size = vec (1 + bottomRight.x - topLeft.x) (1 + bottomRight.y - topLeft.y); fill = fillChar }

/// Extracts all tiles from the grid
let extractTiles grid =
    let points = [ for x in 0..(grid.size.x - 1) do for y in 0..(grid.size.y - 1) do yield vec x y ]
    let rec extractTilesR acc queue =
        match queue with
        | [] -> List.rev acc
        | v :: queueAfter ->
            if acc |> List.exists (inTile v) ||
               grid.data.[v.x, v.y] = '.' then
                extractTilesR acc queueAfter
            else
                let newTile = extractTile grid v
                extractTilesR (newTile :: acc) queueAfter
    extractTilesR List.empty points

[<EntryPoint>]
let main argv = 
    let tiles = getGridSize
                |> getGrid
                |> extractTiles
    for tile in tiles do
         printfn "%i×%i tile of character '%c' located at (%i,%i)" tile.size.x tile.size.y tile.fill tile.pos.x tile.pos.y
    Console.ReadKey() |> ignore
    0