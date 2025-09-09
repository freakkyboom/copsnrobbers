/*
    Router für sichere Client->Server Calls.
    Aufruf: ["CR_fnc_srv_deposit", [player, 500]] remoteExec ["CR_fnc_toServer", 2];
*/
if (!isServer) exitWith {};
params ["_fnName","_args"];

private _wl = [
    "CR_fnc_srv_registerRobbery",
    "CR_fnc_srv_deposit",
    "CR_fnc_srv_withdraw",
    "CR_fnc_srv_startRobbery",
    "CR_fnc_srv_finishRobbery",
    "CR_fnc_srv_purchaseGear",
    "CR_fnc_srv_purchaseVehicle"
];

if (!(_fnName in _wl)) exitWith {
    diag_log format ["[CR][SEC] Reject toServer call: %1", _fnName];
};

private _fn = missionNamespace getVariable [_fnName, objNull];
if (isNil "_fn") exitWith {
    diag_log format ["[CR][SEC] Missing server fn: %1", _fnName];
};
_args call _fn;