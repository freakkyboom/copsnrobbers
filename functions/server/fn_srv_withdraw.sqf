/*
    Server: Auszahlung am ATM (reines Demo – ohne Kontostand).
    Für echte Ökonomie: Kontostand-Variable führen und prüfen.
*/
if (!isServer) exitWith {};
params ["_unit","_amount"];

if (isNull _unit || !isPlayer _unit) exitWith { diag_log "[CR][BANK] invalid withdrawer"; };

private _amountN = round (_amount max 0);
if (_amountN <= 0) exitWith {};

private _cash = _unit getVariable ["CR_Cash", 0];
private _newCash = _cash + _amountN;
_unit setVariable ["CR_Cash", _newCash, true];

["CR_INFO", ["Bank", format ["Auszahlung %1$, Neues Bargeld: %2$", _amountN, _newCash]]] remoteExec ["BIS_fnc_showNotification", owner _unit];
diag_log format ["[CR][BANK] withdraw uid=%1 amount=%2 cashNow=%3", getPlayerUID _unit, _amountN, _newCash];