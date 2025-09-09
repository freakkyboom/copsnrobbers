/*
    CR_fnc_srv_startRobbery
    Server-side logic to handle the initiation of a robbery. This
    function enforces weapon requirements, manages cooldowns, applies
    punishments when necessary and notifies cops of an active
    incident. A separate finish handler awards the robber after a
    delay.

    Params:
      0: Object - the robber (player unit)
      1: Position - approximate robbery location (marker/NPC position)

    This function should only be called via CR_fnc_toServer with
    allowedTargets = 2. It is therefore safe against remote code
    execution by untrusted clients.
*/

if (!isServer) exitWith {};
params ["_unit", "_pos"];

// Validate the unit parameter
if (isNull _unit || {!isPlayer _unit}) exitWith {};

// Only civilians (robbers) are allowed to start a robbery
if (!([_unit] call CR_fnc_unitIsRobber)) exitWith {
    diag_log format ["[CR][srv_startRobbery] Player %1 is not a robber; aborting.", name _unit];
};

// Determine whether the player has at least one weapon (primary or handgun)
private _hasPrimary = !(primaryWeapon _unit isEqualTo "");
private _hasHandgun = !(handgunWeapon _unit isEqualTo "");
private _armed = _hasPrimary || _hasHandgun;

// Weapon required: punish players who attempt a robbery without a weapon
if (!_armed) exitWith {
    private _cash = _unit getVariable ["CR_Cash", 0];
    // Fine is capped at the player's current cash to avoid negative
    private _fine = 500 min _cash;
    _unit setVariable ["CR_Cash", _cash - _fine, true];
    // Play a simple surrender animation on all clients
    [_unit, "AmovPercMstpSsurWnonDnon"] remoteExec ["switchMove", 0];
    ["CR_INFO", ["Tankstelle", format ["Ohne Waffe? Bußgeld %1$.", _fine]]] remoteExec ["BIS_fnc_showNotification", owner _unit];
    diag_log format ["[CR][Robbery] %1 attempted without weapon; fine %2", name _unit, _fine];
};

// Cooldown handling: a global cooldown for gas station robberies. If you
// wish to have per-station cooldowns, you can incorporate a hash map
// keyed by position or station name. Here we use a single timer.
private _cooldownEnd = missionNamespace getVariable ["CR_GAS_COOLDOWN", 0];
if (time < _cooldownEnd) exitWith {
    ["CR_INFO", ["Tankstelle", "Hier gab es gerade erst einen Überfall. Warte etwas."]] remoteExec ["BIS_fnc_showNotification", owner _unit];
};

// Set a new cooldown period (5 minutes)
missionNamespace setVariable ["CR_GAS_COOLDOWN", time + 300, true];

// Notify all cops: show hint on clients. We broadcast to all clients
// and let the notifySide function handle filtering based on side.
["CR_fnc_notifySide", [west, "Tankstellenraub gemeldet!"]] remoteExec [0, true];

// Create a dispatch marker on cop clients. The client-side function
// checks the player's side before showing it. We broadcast to all
// clients (target 0); only cops will display the marker.
["CR_fnc_createDispatchMarker", [_pos]] remoteExec [0, true];

// Store the ongoing robbery information and publish it so other
// functions (e.g. finish handler) can read it.
CR_CurrentRobbery = [_unit, _pos, time];
publicVariable "CR_CurrentRobbery";

// Schedule the robbery completion after 60 seconds. We use a spawned
// thread on the server so we do not block. After the wait, we call
// the finish handler directly (no remote exec needed since we're
// already on the server).
[] spawn {
    sleep 60;
    call CR_fnc_srv_finishRobbery;
};

diag_log format ["[CR][Robbery] %1 initiated robbery at %2", name _unit, _pos];