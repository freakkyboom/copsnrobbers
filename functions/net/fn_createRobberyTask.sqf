/*
    CR_fnc_createRobberyTask
    Client-side function to create a robbery response task for cops.
    Called via remoteExec when a robbery starts.
    
    Params:
      0: Position - robbery location
*/

if (!hasInterface) exitWith {};
params ["_pos"];

// Only create task for cops
if !(side player == west) exitWith {};

// Create the robbery response task
private _taskId = format ["CR_Task_RobberyResponse_%1", round time];
[
    west,
    _taskId,
    ["Raubüberfall stoppen", "Ein Raubüberfall wurde gemeldet. Begebe dich zum Tatort und stoppe die Täter!", "Respond"],
    _pos,
    "ASSIGNED",
    2,
    true
] call BIS_fnc_taskCreate;

// Show notification to cops
["CR_INFO", ["EINSATZ", "Raubüberfall gemeldet! Neue Aufgabe erhalten."]] call BIS_fnc_showNotification;

// Auto-complete the task after 3 minutes (when robbery would be over)
[] spawn {
    sleep 180;
    if (!isNil _taskId) then {
        [_taskId, "SUCCEEDED"] call BIS_fnc_taskSetState;
    };
};