/*
    CR_fnc_createDispatchMarker
    Client-side helper that creates a temporary dispatch marker on the
    map when a robbery is reported. This function is designed to be
    called via remoteExec from the server. It checks the player's
    side and only displays the marker for cops (west). The marker is
    removed automatically after a fixed duration.

    Params:
      0: Position - the location of the incident

    Usage (from server):
        ["CR_fnc_createDispatchMarker", [_pos]] remoteExec ["CR_fnc_createDispatchMarker", 0, true];
*/

if (!hasInterface) exitWith {};
params ["_pos"];

// Only create the marker for cops
if !(side player == west) exitWith {};

// Create or update a local marker. Use a fixed name so repeated
// reports simply move the marker. Delete any old marker with the
// same name first.
private _name = "CR_dispatch_marker";
deleteMarkerLocal _name;
private _m = createMarkerLocal [_name, _pos];
_m setMarkerTypeLocal "mil_warning";
_m setMarkerColorLocal "ColorRed";
_m setMarkerTextLocal "Raubüberfall";

// Remove the marker after 180 seconds on the client
[] spawn {
    sleep 180;
    deleteMarkerLocal "CR_dispatch_marker";
};