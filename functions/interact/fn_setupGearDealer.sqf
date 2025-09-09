/*
    CR_fnc_setupGearDealer
    Adds a purchase interaction to the NPC named "gear_dealer_1" (or
    creates a fallback logic object at the marker with the same name).
    The interaction presents a simple shop menu to the player
    categorised into standard equipment and weapons. After the
    player selects an item, a purchase request is forwarded to the
    server via CR_fnc_toServer.

    This function should be called on each client during initClient.
*/

if (!hasInterface) exitWith {};

// Attempt to find the gear dealer by variable name
private _npc = missionNamespace getVariable ["gear_dealer_1", objNull];

// Fallback: look for a marker with the same name and spawn a logic
if (isNull _npc) then {
    private _mOK = ["gear_dealer_1"] call CR_fnc_nearMarkerPos;
    if ((_mOK select 0)) then {
        private _pos = _mOK select 1;
        _npc = "Logic" createVehicleLocal _pos;
    };
};

if (isNull _npc) exitWith {
    diag_log "[CR][GearDealer] Kein NPC oder Marker für gear_dealer_1 gefunden.";
};

// Define the shop inventory on the client. Categories and items are
// defined locally; the server will trust the transmitted price but
// still checks the player's cash.
private _equipItems = [
    ["FirstAidKit",50],
    ["NVGoggles",800],
    ["Binocular",150],
    ["V_TacVest_blk_POLICE",600],
    ["B_AssaultPack_blk",200]
];
private _weaponItems = [
    ["hgun_P07_F",600],
    ["SMG_01_F",1200],
    ["arifle_Mk20_F",1800]
];

// Code to execute when the player selects the gear dealer interaction
private _openShop = {
    params ["_target", "_caller", "_actionId", "_args"];
    // Present category selection
    private _categories = ["Ausrüstung", "Waffen"];
    private _catIdx = ["Shop Kategorien", _categories] call BIS_fnc_guiSelectMenu;
    if (_catIdx < 0) exitWith {};
    private _items = [];
    switch (_catIdx) do {
        case 0: { _items = _equipItems; };
        case 1: { _items = _weaponItems; };
    };
    // Build a list of display strings
    private _display = _items apply { format ["%1 ($%2)", _x select 0, _x select 1] };
    private _itemIdx = ["Artikel", _display] call BIS_fnc_guiSelectMenu;
    if (_itemIdx < 0) exitWith {};
    private _selected = _items select _itemIdx;
    private _className = _selected select 0;
    private _price = _selected select 1;
    // Request purchase from server via the toServer router
    ["CR_fnc_toServer", ["CR_fnc_srv_purchaseGear", [_caller, _className, _price]]] remoteExec [2];
};

// Attach the interaction using the ACE/fallback helper
[_npc, "Ausrüstung kaufen", _openShop] call CR_fnc_addAceOrAction;