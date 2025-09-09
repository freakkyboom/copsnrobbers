/*
    [side, message] remoteExec ["CR_fnc_notifySide", 0, true]
    Sendet eine Hinweisbox nur an Spieler einer bestimmten Seite.
*/
params ["_side", "_message"];
if (!hasInterface) exitWith {};
if (side player == _side) then {
    hint parseText format ["<t size='1.2' color='#FFD700'>ALARM</t><br/>%1", _message];
};