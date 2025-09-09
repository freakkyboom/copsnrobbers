/*
    CR_fnc_setupRobberyNPCs
    Scans the mission for NPCs named "gas_station_1", "gas_station_2" and
    "gas_station_3" (as defined in the mission.sqm) and attaches an
    interaction to each. If an NPC cannot be found, a local Logic
    object will be spawned at the associated marker (if one exists)
    and used as the interaction point. This wrapper ensures that
    players have a consistent way to start a robbery regardless of
    whether ACE is loaded or not.

    Each interaction invokes CR_fnc_startRobbery on the client which
    forwards the request to the server. No conditions or distance
    checks are enforced here; those are handled by the server.

    This function should be called on each client during initClient.
*/

if (!hasInterface) exitWith {};

private _stations = ["gas_station_1","gas_station_2","gas_station_3"];

{
    private _name = _x;
    // Attempt to resolve the NPC by its variable name. In ArmA, units
    // with a 'name' attribute become variables in the mission namespace.
    private _npc = missionNamespace getVariable [_name, objNull];

    // If the NPC does not exist (is null), attempt to fall back to a
    // marker position with the same name. Note: some missions may
    // instead have numbered markers (e.g. "1", "marker_10"), so this
    // fallback only covers the direct case. When no marker exists,
    // interaction for that station is skipped.
    if (isNull _npc) then {
        private _mOK = [_name] call CR_fnc_nearMarkerPos;
        if ((_mOK select 0)) then {
            private _pos = _mOK select 1;
            // Create a local logic to attach the action to. This will
            // not be synced across clients but is sufficient for
            // interactions.
            _npc = "Logic" createVehicleLocal _pos;
        };
    };

    if (!isNull _npc) then {
        // Attach the robbery interaction using our ACE/fallback helper.
        [_npc, "Tankstelle ausrauben", {
            params ["_target", "_caller", "_actionId", "_args"];
            // Delegate to the client stub which will call the server.
            [_target] call CR_fnc_startRobbery;
        }] call CR_fnc_addAceOrAction;
    } else {
        diag_log format ["[CR][RobberyNPC] Kein NPC oder Marker gefunden für %1", _name];
    };
} forEach _stations;