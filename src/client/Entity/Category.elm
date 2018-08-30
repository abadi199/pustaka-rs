module Entity.Category
    exposing
        ( Category
        , create
        , decoder
        , delete
        , favorite
        , get
        , list
        , update
        )

import Json.Decode as JD
import Json.Encode as JE
import ReloadableData exposing (ReloadableWebData)
import ReloadableData.Http
import Set exposing (Set)
import Tree exposing (Node, Tree)


type alias Category =
    { id : Int
    , name : String
    , parentId : Maybe Int
    }


type alias NewCategory =
    { name : String, parent_id : Maybe Int }


decoder : JD.Decoder Category
decoder =
    JD.map3 Category
        (JD.field "id" JD.int)
        (JD.field "name" JD.string)
        (JD.field "parent_id" (JD.nullable JD.int))


list : (ReloadableWebData () (Tree Category) -> msg) -> Cmd msg
list msg =
    ReloadableData.Http.get
        ()
        "/api/category"
        msg
        (JD.list decoder |> JD.map toTree)


favorite : (ReloadableWebData () (List Category) -> msg) -> Cmd msg
favorite msg =
    ReloadableData.Http.get
        ()
        "/api/category/favorite"
        msg
        (JD.list decoder)


toTree : List Category -> Tree Category
toTree categories =
    let
        set =
            categories |> List.map (\category -> category.id) |> Set.fromList

        roots =
            categories
                |> List.filter
                    (\category ->
                        category.parentId
                            == Nothing
                            || (parentExists category set |> not)
                    )

        toTreeHelper root =
            let
                children =
                    categories |> List.filter (\category -> category.parentId == Just root.id)
            in
            Tree.node root (toTree children)
    in
    roots
        |> List.map toTreeHelper


parentExists : Category -> Set Int -> Bool
parentExists category set =
    category.parentId
        |> Maybe.map (\parentId -> Set.member parentId set)
        |> Maybe.withDefault False


get : (ReloadableWebData () Category -> msg) -> Int -> Cmd msg
get msg id =
    ReloadableData.Http.get
        ()
        ("/api/category/" ++ String.fromInt id)
        msg
        decoder


create : (ReloadableWebData () Category -> msg) -> NewCategory -> Cmd msg
create msg newCategory =
    ReloadableData.Http.post
        ()
        "/api/category/"
        msg
        decoder
        (JE.object
            [ ( "name", JE.string newCategory.name )
            , ( "parent_id"
              , newCategory.parent_id
                    |> Maybe.map JE.int
                    |> Maybe.withDefault JE.null
              )
            ]
        )


delete : (ReloadableWebData () () -> msg) -> Int -> Cmd msg
delete msg id =
    ReloadableData.Http.delete "/api/category"
        (ReloadableData.map (always ()) >> msg)
        (JE.int id)


update : (ReloadableWebData () Category -> msg) -> Category -> Cmd msg
update msg category =
    ReloadableData.Http.put
        ()
        "/api/category"
        msg
        decoder
        (JE.object
            [ ( "id", JE.int category.id )
            , ( "name", JE.string category.name )
            , ( "parent_id"
              , category.parentId
                    |> Maybe.map JE.int
                    |> Maybe.withDefault JE.null
              )
            ]
        )
