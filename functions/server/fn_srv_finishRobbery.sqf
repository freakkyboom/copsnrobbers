/*
    CR_fnc_srv_finishRobbery
    Awards the robber after a successful robbery. This function
    retrieves the globally stored CR_CurrentRobbery information,
    validates it, and pays out a predefined amount. After awarding
    the robber the money, it clears the current robbery state.

    Should be called only on the server. Typically invoked
    automatically by CR_fnc_srv_startRobbery after a delay. You can
    also trigger it manually for testing.
*/

if (!isServer) exitWith {};

// If no robbery is currently in progress, nothing to do
if (isNil "CR_CurrentRobbery") exitWith {};

// Unpack data: [robber, position, startTime]
CR_CurrentRobbery params ["_robber", "_pos", "_start"];

if (isNull _robber || {!isPlayer _robber}) exitWith {
    // Clean up in case the robber disconnected or became invalid
    CR_CurrentRobbery = nil;
    publicVariable "CR_CurrentRobbery";
};

// Payout amount from the configured economy. Fallback to 2500 if
// undefined.
private _basePayoutEntry = (missionNamespace getVariable ["CR_Config_Economy", []]) param [0, ["baseRobberyPayout", 2500]];
private _payout = _basePayoutEntry select 1;

// Credit the money to the robber and make it public so clients sync
private _cash = _robber getVariable ["CR_Cash", 0];
_robber setVariable ["CR_Cash", _cash + _payout, true];

// Send notification to the robber
["CR_INFO", ["Tankstelle", format ["Beute: %1$.", _payout]]] remoteExec ["BIS_fnc_showNotification", owner _robber];

diag_log format ["[CR][Robbery] Finished: %1 earned %2$ (duration %3s)", name _robber, _payout, round (time - _start)];

// Clear the robbery state
CR_CurrentRobbery = nil;
publicVariable "CR_CurrentRobbery";