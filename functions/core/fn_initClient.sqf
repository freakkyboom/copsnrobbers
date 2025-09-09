/*
    Client-Start: visuelles Lebenszeichen, Interaktionen, Aufgaben.
*/
if (!hasInterface) exitWith {};
waitUntil { !isNull player };

diag_log format ["[CR] Client init start %1", getPlayerUID player];

[] call CR_fnc_bootToast;
[] call CR_fnc_setupInteractions;

// Zusätzliche Systeme: Tankstellenraub, Gear-Dealer, Car-Dealer, Garage
[] spawn { uiSleep 0.2; [] call CR_fnc_setupRobberyNPCs; };
[] spawn { uiSleep 0.2; [] call CR_fnc_setupGearDealer; };
[] spawn { uiSleep 0.2; [] call CR_fnc_setupCarDealer; };
[] spawn { uiSleep 0.2; [] call CR_fnc_setupGarage; };

// Aufgaben zuweisen
[] spawn {
    uiSleep 0.2;
    private _ok = false;
    try {
        [] call CR_fnc_assignTasks;
        _ok = true;
    } catch {
        diag_log format ["[CR][assignTasks] Fehler beim Zuweisen: %1", _exception];
        hint "Aufgaben konnten nicht initialisiert werden (siehe RPT).";
    };
    if (_ok) then {
        ["CR_INFO", ["Cops & Robbers", "Aufgaben zugewiesen."]] call BIS_fnc_showNotification;
    };
};

// Cash-UI-Hinweis beim ersten Spawn
[] spawn {
    sleep 1;
    private _cash = player getVariable ["CR_Cash", -1];
    if (_cash < 0) then {
        publicVariable "CR_ECON_init";
        sleep 0.5;
        _cash = player getVariable ["CR_Cash", 0];
    };
    hintSilent format ["Willkommen! Startguthaben: $%1", _cash max 0];
};

diag_log "[CR] Client init done";