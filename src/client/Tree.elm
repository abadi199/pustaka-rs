module Tree exposing
    ( Node
    , Tree
    , flatten
    , map
    , node
    , roots
    )


type alias Tree n =
    List (Node n)


type Node n
    = Node n (Tree n)


node : n -> Tree n -> Node n
node n c =
    Node n c


roots : Tree n -> List n
roots t =
    t
        |> List.map (\(Node n _) -> n)


children : Node n -> Tree n
children (Node n c) =
    c


map : (a -> b) -> Tree a -> Tree b
map f t =
    t
        |> List.map (\(Node n c) -> Node (f n) (map f c))


flatten : (Int -> n -> List m -> m) -> Tree n -> List m
flatten f t =
    t
        |> List.map (\(Node n c) -> f 0 n (flattenChildren 1 f c))


flattenChildren : Int -> (Int -> n -> List m -> m) -> Tree n -> List m
flattenChildren level f t =
    t
        |> List.map (\(Node n c) -> f level n (flattenChildren (level + 1) f c))
