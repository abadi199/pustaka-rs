module Entity.Category
    exposing
        ( Category(..)
        , create
        , decoder
        , delete
        , get
        , list
        , update
        )

import Json.Decode as JD
import Json.Encode as JE
import RemoteData exposing (WebData)
import RemoteData.Http


type Category
    = Category
        { id : Int
        , name : String
        , parent : Maybe Category
        }


type alias NewCategory =
    { name : String, parent : Maybe Category }


decoder : JD.Decoder Category
decoder =
    JD.map2 (\id name -> Category { id = id, name = name, parent = Nothing })
        (JD.field "id" JD.int)
        (JD.field "name" JD.string)


list : (WebData (List Category) -> msg) -> Cmd msg
list msg =
    RemoteData.Http.get "/api/category"
        msg
        (JD.list decoder)


get : (WebData Category -> msg) -> Int -> Cmd msg
get msg id =
    RemoteData.Http.get ("/api/category/" ++ toString id)
        msg
        decoder


create : (WebData Category -> msg) -> NewCategory -> Cmd msg
create msg newCategory =
    RemoteData.Http.post "/api/category/"
        msg
        decoder
        (JE.object
            [ ( "name", JE.string newCategory.name )
            , ( "parent_id"
              , newCategory.parent
                    |> Maybe.map (\(Category parent) -> parent.id)
                    |> Maybe.map JE.int
                    |> Maybe.withDefault JE.null
              )
            ]
        )


delete : (WebData () -> msg) -> Int -> Cmd msg
delete msg id =
    RemoteData.Http.delete "/api/category"
        (RemoteData.map (always ()) >> msg)
        (JE.int id)


update : (WebData Category -> msg) -> Category -> Cmd msg
update msg (Category category) =
    RemoteData.Http.put "/api/category"
        msg
        decoder
        (JE.object
            [ ( "id", JE.int category.id )
            , ( "name", JE.string category.name )
            , ( "parent_id"
              , category.parent
                    |> Maybe.map (\(Category parent) -> parent.id)
                    |> Maybe.map JE.int
                    |> Maybe.withDefault JE.null
              )
            ]
        )
