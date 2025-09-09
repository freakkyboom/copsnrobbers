/*
    Server-Start: Spielzustand, Heartbeat, globale Variablen.
*/
if (!isServer) exitWith {};
diag_log "[CR] Server init start";

CR_GlobalState = [
    ["vaultOpen", false],
    ["alarms", []],
    ["economy", [["cashFactor",1.0],["wantedFactor",1.0]]]
];
publicVariable "CR_GlobalState";

// Heartbeat ins RPT alle 60s
[] spawn {
    while {true} do {
        diag_log format ["[CR] HB t=%1 players=%2", time, count allPlayers];
        sleep 60;
    };
};

// Ensure cash variables on JIP players
"CR_ECON_init" addPublicVariableEventHandler {
    {
        if (isPlayer _x && isNil {_x getVariable "CR_Cash"}) then {
            private _start = (missionNamespace getVariable "CR_Config_Economy") param [2, ["startCash", 1000]];
            _x setVariable ["CR_Cash", _start select 1, true];
        };
    } forEach allPlayers;
};

publicVariable "CR_ECON_init";
diag_log "[CR] Server init done";