/*
    CR_fnc_setupGarage
    Creates garage interactions at vehicle spawn points. Players can
    remove (despawn) their owned vehicle when they are the driver and
    in close proximity to the spawn marker. Ownership is tracked via
    the CR_OwnerUID variable on vehicles assigned at purchase time.

    This function is intended to run on each client. It does not
    require ACE but will use ACE if available.
*/

if (!hasInterface) exitWith {};

// Marker names to place garage actions at
private _markers = ["robber_vehicle_spawn", "cop_vehicle_spawn"];

{
    private _mName = _x;
    private _mOK = [_mName] call CR_fnc_nearMarkerPos;
    if ((_mOK select 0)) then {
        private _pos = _mOK select 1;
        // Create a local logic to anchor the action. Using a logic
        // avoids interfering with other mission objects.
        private _anchor = "Logic" createVehicleLocal _pos;
        [_anchor, "Fahrzeug einparken", {
            params ["_target", "_caller", "_actionId", "_args"];
            private _veh = vehicle _caller;
            // Ensure the player is in a vehicle and is the driver
            if (!(_veh isKindOf "LandVehicle") || {driver _veh != _caller}) exitWith {
                hint "Du musst der Fahrer deines Fahrzeugs sein.";
            };
            // Check ownership (if set)
            private _ownerUID = _veh getVariable ["CR_OwnerUID", ""];
            if (_ownerUID != getPlayerUID _caller) exitWith {
                hint "Das ist nicht dein Fahrzeug.";
            };
            // Delete the vehicle on the server so it disappears for everyone
            ["deleteVehicle", [_veh]] remoteExec [2];
            ["CR_INFO", ["Garage", "Fahrzeug eingeparkt."]] call BIS_fnc_showNotification;
        }] call CR_fnc_addAceOrAction;
    };
} forEach _markers;