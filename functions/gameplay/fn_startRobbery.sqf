/*
    CR_fnc_startRobbery
    Client-side stub to initiate a robbery on the server. This function
    should be invoked from a player interaction (e.g. on an NPC or
    marker). It simply packages the player and their current position
    and forwards the request to the server via CR_fnc_toServer.

    Params:
      _target (Object) – optional NPC or logic object used for context.

    Example usage:
        [_npc] call CR_fnc_startRobbery;

    The server function CR_fnc_srv_startRobbery handles all checks,
    cooldowns, punishments and dispatch notifications.
*/

params ["_target"];

// Determine the position from where the robbery is attempted. We use
// the player’s position instead of the target to prevent any errors
// when no explicit NPC is available.
private _robPos = position player;

// Forward to server via the toServer router. Pass the function name
// and its arguments. Target 2 ensures execution on the server.
["CR_fnc_toServer", ["CR_fnc_srv_startRobbery", [player, _robPos]]] remoteExec [2];