/*
    CR_fnc_addNpcSpecialAction
    Spezialisierte Funktion für NPC-Interaktionen die eine eigene Kategorie
    anstatt der Standard "Interaktionen" nutzen.
    
    Diese Funktion erstellt eine separate ACE3-Hauptkategorie für NPCs
    um zu vermeiden, dass sie in der Standard-Interaktions-Gruppe landen.

    Params:
      0: Object (_obj) - NPC object
      1: Titel (_title) - Interaction title
      2: Code - Script to execute
      3: Icon path (optional)
      4: Show condition (optional, defaults to {true})
      5: Enable condition (optional, defaults to {true})
      6: arguments array (optional)
*/

params [
    "_obj",
    "_title", 
    "_code",
    ["_icon", ""],
    ["_cond_show", {true}],
    ["_cond_enable", {true}],
    ["_args", []]
];

private _hasACE = isClass (configFile >> "CfgPatches" >> "ace_interact_menu");

if (!isNull _obj) then {
    if (_hasACE && !isNil "ace_interact_menu_fnc_createAction" && !isNil "ace_interact_menu_fnc_addActionToObject") then {
        // Create a custom category for this NPC to avoid "Interaktionen"
        private _categoryName = format ["CR_NPC_%1", typeOf _obj];
        private _categoryTitle = format ["%1 Dienste", typeOf _obj];
        
        // Create the category action
        private _category = [
            _categoryName,
            _categoryTitle,
            _icon,
            {},
            {true},
            {},
            {},
            []
        ] call ace_interact_menu_fnc_createAction;
        
        // Add category to main actions if it doesn't exist
        [_obj, 0, ["ACE_MainActions"], _category] call ace_interact_menu_fnc_addActionToObject;
        
        // Create the specific action
        private _action = [
            format ["CR_%1_%2", _categoryName, _title],
            _title,
            _icon,
            _code,
            _cond_show,
            _cond_enable,
            {},
            _args
        ] call ace_interact_menu_fnc_createAction;
        
        // Add action to our custom category
        [_obj, 0, ["ACE_MainActions", _categoryName], _action] call ace_interact_menu_fnc_addActionToObject;
        
        diag_log format ["[CR][NPC] Added specialized ACE interaction '%1' to %2 in category '%3'", _title, typeOf _obj, _categoryTitle];
    } else {
        if (_hasACE) then {
            diag_log format ["[CR][NPC] WARNUNG: ACE3 erkannt aber Funktionen nicht verfügbar für '%1'", _title];
        };
        // Fallback: standard addAction
        _obj addAction [
            _title,
            _code,
            _args,
            1.5,
            true,
            true,
            "",
            "",
            ""
        ];
        diag_log format ["[CR][NPC] Added standard action '%1' to %2", _title, typeOf _obj];
    };
} else {
    diag_log format ["[CR][NPC] ERROR: Cannot add NPC interaction '%1' - object is null", _title];
};