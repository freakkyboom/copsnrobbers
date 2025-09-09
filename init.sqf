// Failsafe-Router: läuft immer und verkabelt Server/Client-Init zuverlässig
diag_log "[CR] init.sqf start";
[] call CR_fnc_bootToast;

if (isServer) then {
    [] spawn {
        waitUntil { time > 0 };
        [] call CR_fnc_initServer;
        diag_log "[CR] initServer called from init.sqf";
    };
};

if (hasInterface) then {
    [] spawn {
        waitUntil { !isNull player };
        [] call CR_fnc_initClient;
        diag_log "[CR] initClient called from init.sqf";
    };
};

[] spawn { [] call CR_fnc_validateMarkers; };