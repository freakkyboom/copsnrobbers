/*
    CR_fnc_srv_spawnFreeVehicle
    Server-side free vehicle spawning for cops. Spawns BLUEFOR vehicles
    at the specified position without any cost requirements.

    Params:
      0: Object - player unit (must be cop)
      1: STRING - vehicle class name
      2: Position - spawn position
*/

if (!isServer) exitWith {};

params ["_unit", "_class", "_pos"];

if (isNull _unit || {!isPlayer _unit}) exitWith {};

// Only cops can use free vehicle spawning
if (!([_unit] call CR_fnc_unitIsCop)) exitWith {
    ["CR_INFO", ["Garage", "Nur für Polizei zugänglich."]] remoteExec ["BIS_fnc_showNotification", owner _unit];
    diag_log format ["[CR][FreeSpawn] Non-cop %1 attempted to spawn free vehicle", name _unit];
};

// Check if the spawn area is free of other vehicles (8m radius)
private _occupied = (nearestObjects [_pos, ["LandVehicle"], 8]) isNotEqualTo [];
if (_occupied) exitWith {
    ["CR_INFO", ["Garage", "Spawnbereich ist blockiert."]] remoteExec ["BIS_fnc_showNotification", owner _unit];
};

// Spawn the vehicle on the server
private _veh = _class createVehicle _pos;
_veh setDir random 360;
_veh lock 0;
_veh setVehicleAmmo 1;
_veh setFuel 1;
_veh setVariable ["CR_OwnerUID", getPlayerUID _unit, true];

// Set vehicle side to west (BLUEFOR) for proper identification
_veh setVariable ["BIS_enableRandomization", false];

["CR_INFO", ["Garage", format ["Fahrzeug gespawnt: %1", _class]]] remoteExec ["BIS_fnc_showNotification", owner _unit];

diag_log format ["[CR][FreeSpawn] %1 spawned free vehicle %2", name _unit, _class];