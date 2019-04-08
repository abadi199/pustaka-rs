module UI.Nav exposing (SelectedItem(..))


type SelectedItem
    = NoSelection
    | Home
    | CategoryId Int
    | BrowseByCategory
    | BrowseByMediaType
    | Settings
