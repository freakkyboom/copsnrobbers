/*
    CR_fnc_setupCarDealer
    Adds a purchase interaction to the NPC named "car_dealer_1". If no
    NPC exists with that name, a fallback logic will be created at
    a marker of the same name. The interaction presents a list of
    available vehicles and forwards the purchase to the server via
    CR_fnc_toServer.

    To function correctly, a spawn marker for the player's faction
    should exist: "robber_vehicle_spawn" for robbers and
    "cop_vehicle_spawn" for cops. If missing, the player's respawn
    marker will be used as a last resort.
*/

if (!hasInterface) exitWith {};

// Resolve the dealer NPC
private _npc = missionNamespace getVariable ["car_dealer_1", objNull];

if (isNull _npc) then {
    private _mOK = ["car_dealer_1"] call CR_fnc_nearMarkerPos;
    if ((_mOK select 0)) then {
        private _pos = _mOK select 1;
        try {
            _npc = "Logic" createVehicleLocal _pos;
            diag_log format ["[CR][CarDealer] Erstellt Logic-Objekt für car_dealer_1 an Marker-Position %1", _pos];
        } catch {
            diag_log format ["[CR][CarDealer] FEHLER beim Erstellen des Logic-Objekts: %1", _exception];
        };
    } else {
        diag_log "[CR][CarDealer] WARNUNG: Marker car_dealer_1 nicht gefunden";
    };
};

if (isNull _npc) exitWith {
    diag_log "[CR][CarDealer] FEHLER: Kein NPC oder Marker für car_dealer_1 gefunden.";
};

// Client-side list of vehicles (className, price)
private _vehicles = [
    ["C_Hatchback_01_F", 2500],
    ["C_Offroad_01_F", 4500],
    ["B_Quadbike_01_F", 1000]
];

// Interaction callback: opens menu and sends purchase request
private _openDealer = {
    params ["_target", "_caller", "_actionId", "_args"];
    private _choices = _vehicles apply { format ["%1 ($%2)", _x select 0, _x select 1] };
    private _idx = ["Fahrzeuge", _choices] call BIS_fnc_guiSelectMenu;
    if (_idx < 0) exitWith {};
    private _sel = _vehicles select _idx;
    private _class = _sel select 0;
    private _price = _sel select 1;
    // Send to server via toServer router
    ["CR_fnc_toServer", ["CR_fnc_srv_purchaseVehicle", [_caller, _class, _price]]] remoteExec [2];
};

// Attach the interaction using specialized NPC helper  
[_npc, "Fahrzeug kaufen", _openDealer, "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa"] call CR_fnc_addNpcSpecialAction;
diag_log "[CR][CarDealer] Fahrzeug-Kauf Interaktion erfolgreich hinzugefügt";