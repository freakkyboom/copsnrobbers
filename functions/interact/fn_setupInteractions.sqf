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
            { ["Open",true] spawn BIS_fnc_arsenal; },
            { /* onInterrupted */ },
            [_pos], 2, 0, true, false
        ] call BIS_fnc_holdActionAdd;
    };
} forEach _arsMarkers;

// ATM – einfache Demo mit Server-Ökonomie
{
    private _ok = [_x] call CR_fnc_nearMarkerPos;
    if ((_ok select 0)) then {
        private _pos = _ok select 1;
        player addAction [
            "ATM: $500 einzahlen",
            {
                // Use the toServer router on the server (target 2) and pass our
                // desired function name and arguments
                ["CR_fnc_toServer", ["CR_fnc_srv_deposit", [player, 500]]] remoteExec [2];
            },
            [], 1.5, true, true, "", format ["(player distance %1) < 3", _pos]
        ];
        player addAction [
            "ATM: $500 abheben",
            {
                ["CR_fnc_toServer", ["CR_fnc_srv_withdraw", [player, 500]]] remoteExec [2];
            },
            [], 1.5, true, true, "", format ["(player distance %1) < 3", _pos]
        ];
    };
} forEach ["atm_1","atm_2","atm_3","atm_4","atm_5"];

// Robbery Trigger – nutzt das neue Server-Handling (srv_startRobbery)
if (_isRobber) then {
    {
        private _ok = [_x] call CR_fnc_nearMarkerPos;
        if ((_ok select 0)) then {
            private _pos = _ok select 1;
            player addAction [
                "Überfall starten",
                {
                    params ["_tgt", "_caller"];
                    ["CR_fnc_toServer", ["CR_fnc_srv_startRobbery", [_caller, position _caller]]] remoteExec [2];
                    hint "Überfall gestartet!";
                },
                [], 1.5, true, true, "", format ["(player distance %1) < 6", _pos]
            ];
        };
    } forEach ["gas_station_1","gas_station_2","gas_station_3","vault_area"];
};