module Entity.Category
    exposing
        ( Category(..)
        , decoder
        )

import Json.Decode as JD


type Category
    = Category
        { id : Int
        , name : String
        , parent : Maybe Category
        }


decoder : JD.Decoder Category
decoder =
    JD.map2 (\id name -> Category { id = id, name = name, parent = Nothing })
        (JD.field "id" JD.int)
        (JD.field "name" JD.string)
