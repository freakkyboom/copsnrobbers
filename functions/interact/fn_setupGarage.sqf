/*
    CR_fnc_setupGarage
    Creates garage interactions at vehicle spawn points. Players can:
    - Spawn faction-appropriate vehicles (cops get BLUEFOR vehicles)
    - Remove (despawn) their owned vehicle when they are the driver
    Ownership is tracked via the CR_OwnerUID variable on vehicles.

    This function is intended to run on each client. It does not
    require ACE but will use ACE if available.
*/

if (!hasInterface) exitWith {};

// Vehicle lists by faction
private _copVehicles = [
    ["B_MRAP_01_F", "Hunter", 0],
    ["B_LSV_01_unarmed_F", "Prowler", 0],
    ["B_Quadbike_01_F", "Quad Bike", 0],
    ["B_Truck_01_transport_F", "HEMTT Transport", 0],
    ["B_APC_Wheeled_01_cannon_F", "AMV-7 Marshall", 0]
];

private _robberVehicles = [
    ["C_Hatchback_01_F", "Hatchback", 2500],
    ["C_Offroad_01_F", "Offroad", 4500],
    ["B_Quadbike_01_F", "Quad Bike", 1000]
];

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
        
        // Determine which vehicles this garage can spawn
        private _isCopGarage = (_mName isEqualTo "cop_vehicle_spawn");
        private _availableVehicles = if (_isCopGarage) then { _copVehicles } else { _robberVehicles };
        
        // Add vehicle spawning action
        [_anchor, "Fahrzeug spawnen", {
            params ["_target", "_caller", "_actionId", "_args"];
            _args params ["_vehicles", "_spawnPos", "_isCopGarage"];
            
            // Check faction access
            if (_isCopGarage && !([_caller] call CR_fnc_unitIsCop)) exitWith {
                hint "Nur für Polizei zugänglich.";
            };
            if (!_isCopGarage && !([_caller] call CR_fnc_unitIsRobber)) exitWith {
                hint "Nur für Robber zugänglich.";
            };
            
            // Check if spawn area is clear
            private _occupied = (nearestObjects [_spawnPos, ["LandVehicle"], 8]) isNotEqualTo [];
            if (_occupied) exitWith {
                hint "Spawnbereich ist blockiert.";
            };
            
            // Create vehicle selection menu
            private _choices = _vehicles apply { 
                private _price = _x select 2;
                if (_price > 0) then {
                    format ["%1 ($%2)", _x select 1, _price]
                } else {
                    _x select 1  // Free for cops
                }
            };
            
            private _idx = ["Fahrzeug auswählen", _choices] call BIS_fnc_guiSelectMenu;
            if (_idx < 0) exitWith {};
            
            private _selected = _vehicles select _idx;
            private _className = _selected select 0;
            private _price = _selected select 2;
            
            if (_price > 0) then {
                // Use existing purchase system for robbers
                ["CR_fnc_toServer", ["CR_fnc_srv_purchaseVehicle", [_caller, _className, _price]]] remoteExec [2];
            } else {
                // Free spawn for cops
                ["CR_fnc_toServer", ["CR_fnc_srv_spawnFreeVehicle", [_caller, _className, _spawnPos]]] remoteExec [2];
            };
        }, [_availableVehicles, _pos, _isCopGarage]] call CR_fnc_addAceOrAction;
        
        // Add vehicle despawning action
        [_anchor, "Fahrzeug einparken", {
            params ["_target", "_caller", "_actionId", "_args"];
            private _veh = vehicle _caller;
            // Ensure the player is in a vehicle and is the driver
            if (!(_veh isKindOf "LandVehicle") || {driver _veh != _caller}) exitWith {
                hint "Du musst der Fahrer deines Fahrzeugs sein.";
            };
            // Check ownership (if set) - cops can despawn any BLUEFOR vehicle
            private _ownerUID = _veh getVariable ["CR_OwnerUID", ""];
            private _isCopVehicle = (side _veh isEqualTo west);
            if (_ownerUID != getPlayerUID _caller && !(_isCopVehicle && ([_caller] call CR_fnc_unitIsCop))) exitWith {
                hint "Das ist nicht dein Fahrzeug.";
            };
            // Delete the vehicle on the server so it disappears for everyone
            ["deleteVehicle", [_veh]] remoteExec [2];
            ["CR_INFO", ["Garage", "Fahrzeug eingeparkt."]] call BIS_fnc_showNotification;
        }] call CR_fnc_addAceOrAction;
    };
} forEach _markers;