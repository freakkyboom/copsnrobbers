/*
    Server: registriert einen Überfall, alarmiert Cops und trägt Log ein.
*/
if (!isServer) exitWith {};
params ["_robber","_pos"];

private _alarms = (CR_GlobalState select { (_x select 0) isEqualTo "alarms" });
if (_alarms isEqualTo []) then {
    CR_GlobalState pushBack ["alarms", []];
};
private _arr = (CR_GlobalState select { (_x select 0) isEqualTo "alarms" }) select 0;
private _list = +(_arr select 1);
_list pushBack [time, name _robber, _pos];
_arr set [1, _list];

["CR_fnc_notifySide", [west, format ["Überfall durch %1 gemeldet!", name _robber]]] remoteExec ["CR_fnc_notifySide", 0, true];
diag_log format ["[CR][ROBBERY] t=%1 robber=%2 pos=%3", time, name _robber, _pos];