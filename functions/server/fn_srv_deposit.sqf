/*
    Server: Einzahlung am ATM. Betrugssicher durch Server-Quelle.
*/
if (!isServer) exitWith {};
params ["_unit","_amount"];

if (isNull _unit || !isPlayer _unit) exitWith { diag_log "[CR][BANK] invalid depositor"; };

private _fee = (missionNamespace getVariable "CR_Config_Economy") param [1, ["atmFee", 0.02]];
private _cash = _unit getVariable ["CR_Cash", 0];
private _amountN = round (_amount max 0);

if (_amountN <= 0) exitWith {};
if (_cash < _amountN) exitWith {
    ["CR_INFO", ["Bank", "Nicht genug Bargeld."]] remoteExec ["BIS_fnc_showNotification", owner _unit];
};

private _feeVal = round (_amountN * (_fee select 1));
private _newCash = _cash - _amountN;
_unit setVariable ["CR_Cash", _newCash, true];

// hier könnte man Kontostände führen; für Demo nur Meldung
["CR_INFO", ["Bank", format ["Einzahlung %1$, Gebühr %2$, Neues Bargeld: %3$", _amountN, _feeVal, _newCash]]] remoteExec ["BIS_fnc_showNotification", owner _unit];

diag_log format ["[CR][BANK] deposit uid=%1 amount=%2 fee=%3 cashNow=%4", getPlayerUID _unit, _amountN, _feeVal, _newCash];