module Entity.Category exposing
    ( Category
    , create
    , decoder
    , delete
    , favorite
    , get
    , list
    , tree
    , update
    )

import Json.Decode as JD
import Json.Encode as JE
import ReloadableData exposing (ReloadableWebData)
import ReloadableData.Http
import Set exposing (Set)
import Tree exposing (Node, Tree)



-- MODEL


type alias Category =
    { id : Int
    , name : String
    , parentId : Maybe Int
    }


type alias NewCategory =
    { name : String, parent_id : Maybe Int }



-- DECODER


decoder : JD.Decoder Category
decoder =
    JD.map3 Category
        (JD.field "id" JD.int)
        (JD.field "name" JD.string)
        (JD.field "parent_id" (JD.nullable JD.int))



-- HELPER


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



-- HTTP


get : { msg : ReloadableWebData Int Category -> msg, categoryId : Int } -> Cmd msg
get { msg, categoryId } =
    ReloadableData.Http.get
        { initial = categoryId
        , url = "/api/category/" ++ String.fromInt categoryId
        , msg = msg
        , decoder = decoder
        }


create : { msg : ReloadableWebData () Category -> msg, newCategory : NewCategory } -> Cmd msg
create { msg, newCategory } =
    ReloadableData.Http.post
        { initial = ()
        , url = "/api/category/"
        , msg = msg
        , decoder = decoder
        , json =
            JE.object
                [ ( "name", JE.string newCategory.name )
                , ( "parent_id"
                  , newCategory.parent_id
                        |> Maybe.map JE.int
                        |> Maybe.withDefault JE.null
                  )
                ]
        }


delete : { msg : ReloadableWebData () () -> msg, categoryId : Int } -> Cmd msg
delete { msg, categoryId } =
    ReloadableData.Http.delete
        { initial = ()
        , url = "/api/category"
        , msg = msg
        , json = JE.int categoryId
        }


update : { msg : ReloadableWebData () Category -> msg, category : Category } -> Cmd msg
update { msg, category } =
    ReloadableData.Http.put
        { initial = ()
        , url = "/api/category"
        , msg = msg
        , decoder = decoder
        , json =
            JE.object
                [ ( "id", JE.int category.id )
                , ( "name", JE.string category.name )
                , ( "parent_id"
                  , category.parentId
                        |> Maybe.map JE.int
                        |> Maybe.withDefault JE.null
                  )
                ]
        }


list : (ReloadableWebData () (List Category) -> msg) -> Cmd msg
list msg =
    ReloadableData.Http.get
        { initial = ()
        , url = "/api/category/"
        , msg = msg
        , decoder = JD.list decoder
        }


tree : (ReloadableWebData () (Tree Category) -> msg) -> Cmd msg
tree msg =
    ReloadableData.Http.get
        { initial = ()
        , url = "/api/category/"
        , msg = msg
        , decoder = JD.list decoder |> JD.map toTree
        }


favorite : (ReloadableWebData () (List Category) -> msg) -> Cmd msg
favorite msg =
    ReloadableData.Http.get
        { initial = ()
        , url = "/api/category/favorite/"
        , msg = msg
        , decoder = JD.list decoder
        }
