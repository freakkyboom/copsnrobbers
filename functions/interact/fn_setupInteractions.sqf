/*
    Kontextabhängige Interaktionen (Vanilla).
    - Arsenal an Fraktionspunkten
    - ATM Benutzung
    - Überfall-Start an Tankstellen & Vault
*/
if (!hasInterface) exitWith {};
waitUntil { !isNull player };

private _isCop    = [player] call CR_fnc_unitIsCop;
private _isRobber = [player] call CR_fnc_unitIsRobber;

// Arsenal
private _arsMarkers = if (_isCop) then { ["cop_arsenal"] } else { if (_isRobber) then { ["robber_arsenal"] } else { [] } };
{
    private _ok = [_x] call CR_fnc_nearMarkerPos;
    if ((_ok select 0)) then {
        private _pos = _ok select 1;
        [
            player, "Ausrüstung öffnen",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
            { (player distance (_thisArgs select 0)) < 4 },
            { (player distance (_thisArgs select 0)) < 4 },
            { /* onStart */ },
            { /* onProgress */ },
            { 
                // Apply faction-specific blacklist
                private _blacklist = [];
                if ([player] call CR_fnc_unitIsCop) then {
                    // Cop blacklist - restrict some civilian items
                    _blacklist = [
                        "srifle_DMR_06_camo_F", "srifle_DMR_06_olive_F",
                        "arifle_AK12_F", "arifle_AKM_F", "arifle_AKS_F"
                    ];
                } else {
                    // Robber blacklist - restrict military equipment
                    _blacklist = [
                        "B_Carryall_Base", "B_AssaultPack_dgtl",
                        "arifle_MX_Black_F", "arifle_MX_GL_Black_F",
                        "srifle_EBR_F", "srifle_GM6_F", "srifle_LRR_F"
                    ];
                };
                
                ["Open", true] spawn BIS_fnc_arsenal;
                
                // Apply blacklist after arsenal opens
                [] spawn {
                    waitUntil { !isNull (uiNamespace getVariable ["BIS_fnc_arsenal_cam", objNull]) };
                    {
                        [_x, false] call BIS_fnc_removeVirtualItemCargo;
                    } forEach _blacklist;
                };
            },
            { /* onInterrupted */ },
            [_pos], 2, 0, true, false
        ] call BIS_fnc_holdActionAdd;
    };
} forEach _arsMarkers;

// ATM – ACE3 self-interactions for robbers, addAction for deposits/withdrawals
{
    private _ok = [_x] call CR_fnc_nearMarkerPos;
    if ((_ok select 0)) then {
        private _pos = _ok select 1;
        private _atmObject = "Land_Atm_01_F" createVehicleLocal _pos;
        
        // Standard banking actions for all players
        [_atmObject, "ATM: $500 einzahlen", {
            ["CR_fnc_toServer", ["CR_fnc_srv_deposit", [player, 500]]] remoteExec [2];
        }] call CR_fnc_addAceOrAction;
        
        [_atmObject, "ATM: $500 abheben", {
            ["CR_fnc_toServer", ["CR_fnc_srv_withdraw", [player, 500]]] remoteExec [2];
        }] call CR_fnc_addAceOrAction;
        
        // Robbery action only for robbers using ACE3 self-interaction
        if (_isRobber) then {
            private _hasACE = isClass (configFile >> "CfgPatches" >> "ace_interact_menu");
            if (_hasACE) then {
                // ACE3 self-interaction (Windows key) for robbery
                private _action = [
                    format ["CR_RobATM_%1", _x],
                    "ATM knacken",
                    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_hack_ca.paa",
                    {
                        params ["_target", "_player", "_params"];
                        [_params select 0, "atm"] call CR_fnc_startRobberyWithProgress;
                    },
                    {
                        params ["_target", "_player", "_params"];
                        [_player] call CR_fnc_unitIsRobber && (player distance (_params select 0)) < 3
                    },
                    {},
                    [_pos]
                ] call ace_interact_menu_fnc_createAction;
                [player, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;
            } else {
                // Fallback for non-ACE
                _atmObject addAction [
                    "ATM knacken",
                    {
                        params ["_target", "_caller", "_actionId", "_args"];
                        [_args select 0, "atm"] call CR_fnc_startRobberyWithProgress;
                    },
                    [_pos], 1.5, true, true, "", format ["([player] call CR_fnc_unitIsRobber) && (player distance %1) < 3", _pos]
                ];
            };
        };
    };
} forEach ["atm_1","atm_2","atm_3","atm_4","atm_5"];

// Robbery Trigger – uses new progress-based robbery system
if (_isRobber) then {
    {
        private _ok = [_x] call CR_fnc_nearMarkerPos;
        if ((_ok select 0)) then {
            private _pos = _ok select 1;
            private _hasACE = isClass (configFile >> "CfgPatches" >> "ace_interact_menu");
            
            if (_hasACE) then {
                // ACE3 self-interaction (Windows key) for gas station robbery
                private _action = [
                    format ["CR_RobGasStation_%1", _x],
                    "Tankstelle ausrauben",
                    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_hack_ca.paa",
                    {
                        params ["_target", "_player", "_params"];
                        [_params select 0, "gas_station"] call CR_fnc_startRobberyWithProgress;
                    },
                    {
                        params ["_target", "_player", "_params"];
                        [_player] call CR_fnc_unitIsRobber && (player distance (_params select 0)) < 6
                    },
                    {},
                    [_pos]
                ] call ace_interact_menu_fnc_createAction;
                [player, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;
            } else {
                // Fallback for non-ACE
                player addAction [
                    format ["Tankstelle ausrauben (%1)", _x],
                    {
                        params ["_tgt", "_caller", "_actionId", "_args"];
                        [_args select 0, "gas_station"] call CR_fnc_startRobberyWithProgress;
                    },
                    [_pos], 1.5, true, true, "", format ["([player] call CR_fnc_unitIsRobber) && (player distance %1) < 6", _pos]
                ];
            };
        };
    } forEach ["gas_station_1","gas_station_2","gas_station_3","vault_area"];
};