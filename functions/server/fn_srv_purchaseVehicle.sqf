/*
    CR_fnc_srv_purchaseVehicle
    Server-side vehicle purchase handler. This function validates the
    player's cash, deducts the purchase price and spawns the selected
    vehicle at the appropriate spawn marker for the player's faction.
    If the spawn area is occupied, the purchase is declined and the
    money is not deducted.

    Params:
      0: Object - player unit making the purchase
      1: STRING - vehicle class name
      2: SCALAR - price

    Spawn logic:
      - For robbers (civilian side) the marker "robber_vehicle_spawn"
        is used. If it does not exist, "respawn_civilian" is used.
      - For cops (west/independent) the marker "cop_vehicle_spawn" is used.
      - If no marker exists, the vehicle spawns near the player.

    The spawned vehicle is refueled, rearmed, unlocked and assigned
    ownership to the buyer via CR_OwnerUID variable.
*/

if (!isServer) exitWith {};

params ["_unit", "_class", "_price"];

if (isNull _unit || {!isPlayer _unit}) exitWith {};

private _priceN = _price max 0;
private _cash = _unit getVariable ["CR_Cash", 0];

if (_cash < _priceN) exitWith {
    ["CR_INFO", ["Händler", "Zu wenig Geld."]] remoteExec ["BIS_fnc_showNotification", owner _unit];
};

// Determine spawn marker based on side
private _spawnMarker = "";
if ([_unit] call CR_fnc_unitIsRobber) then {
    _spawnMarker = "robber_vehicle_spawn";
} else {
    if ([_unit] call CR_fnc_unitIsCop) then {
        _spawnMarker = "cop_vehicle_spawn";
    };
};

// Fallbacks: use respawn markers if dedicated vehicle marker is missing
if (_spawnMarker isEqualTo "" || { !([_spawnMarker] call CR_fnc_nearMarkerPos) select 0 }) then {
    // Use respawn markers based on side
    if ([_unit] call CR_fnc_unitIsRobber) then { _spawnMarker = "respawn_civilian"; } else { _spawnMarker = "respawn_west"; };
};

// Get spawn position; if still not found, use player's position offset
private _mOK = [_spawnMarker] call CR_fnc_nearMarkerPos;
private _pos = [];
if ((_mOK select 0)) then {
    _pos = _mOK select 1;
} else {
    // Offset 5m in front of player
    _pos = _unit modelToWorld [0,5,0];
};

// Check if the spawn area is free of other vehicles (6m radius)
private _occupied = (nearestObjects [_pos, ["LandVehicle"], 6]) isNotEqualTo [];
if (_occupied) exitWith {
    ["CR_INFO", ["Händler", "Spawnfläche belegt."]] remoteExec ["BIS_fnc_showNotification", owner _unit];
};

// Deduct payment
_unit setVariable ["CR_Cash", _cash - _priceN, true];

// Spawn the vehicle on the server
private _veh = _class createVehicle _pos;
_veh setDir random 360;
_veh lock 0;
_veh setVehicleAmmo 1;
_veh setFuel 1;
_veh setVariable ["CR_OwnerUID", getPlayerUID _unit, true];

// Give keys (optional): by default vehicles are unlocked so no further key system required

["CR_INFO", ["Händler", format ["%1 gekauft. Viel Spaß!", _class]]] remoteExec ["BIS_fnc_showNotification", owner _unit];

diag_log format ["[CR][CarDealer] %1 purchased %2 for %3$", name _unit, _class, _priceN];