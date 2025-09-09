/*
    CR_fnc_assignTasks
    Weist dem Spieler kontextabhängige Aufgaben zu (Cop/Robber).
    MP-sicher, JIP-sicher, defensiv gegen fehlende Marker.

    Aufruf: [] call CR_fnc_assignTasks;
*/
if (!hasInterface) exitWith {};

// Hilfsfunktion: Task defensiv erstellen
private _createTask = {
    params ["_owner","_taskId","_title","_desc","_markerName"];

    private _exists = !(isNil { getMarkerPos _markerName });
    if (!_exists) exitWith {
        private _msg = format ["[CR][assignTasks] Marker '%1' fehlt – Task '%2' wird übersprungen.", _markerName, _taskId];
        diag_log _msg;
        if (hasInterface) then { hintSilent _msg; };
        false
    };

    // Task Position via Marker
    private _pos = getMarkerPos _markerName;

    // Falls schon vorhanden: löschen/neu erstellen (defensiv)
    if (!isNil { _owner getVariable _taskId }) then {
        private _old = _owner getVariable _taskId;
        if (!isNil "_old") then {
            [_old, true] call BIS_fnc_deleteTask;
        };
    };

    private _task = [
        _owner,                 // owner (objNull, grpNull, side – hier: Spielerobjekt)
        _taskId,                // Task ID
        [_desc, _title, ""],    // Beschreibung/Titel
        _pos,                   // Position
        "CREATED",              // State
        0,                      // Priority
        true,                   // Show in task list
        true,                   // Visible in 3D
        "target"                // Type
    ] call BIS_fnc_taskCreate;

    _owner setVariable [_taskId, _task, false];

    true
};

// Spielerrolle bestimmen
private _isCop    = [player] call CR_fnc_unitIsCop;
private _isRobber = [player] call CR_fnc_unitIsRobber;

// Bestehende Aufgaben wegräumen (defensiv)
{
    if (!isNil { player getVariable _x }) then {
        private _t = player getVariable _x;
        [_t, true] call BIS_fnc_deleteTask;
        player setVariable [_x, nil, false];
    };
} forEach ["CR_Task_ReportToHQ","CR_Task_StartRobbery","CR_Task_CheckATMs","CR_Task_Generic"];

// Aufgaben je Rolle
if (_isCop) then {
    // Cop: zum HQ / Arsenal bewegen
    private _ok1 = [player, "CR_Task_ReportToHQ", "Melde dich beim HQ", "Gehe zum Polizeiarsenal.", "cop_arsenal"] call _createTask;
    if (_ok1) then {
        ["CR_INFO", ["Aufgabe", "Melde dich beim HQ (Arsenal)."]] call BIS_fnc_showNotification;
    };

    // Cop: ATMs patrouillieren
    private _ok2 = [player, "CR_Task_CheckATMs", "Kontrolliere Geldautomaten", "Prüfe die markierten ATM-Standorte.", "atm_1"] call _createTask;
    // Falls atm_1 fehlt, versuche atm_2 oder atm_3
    if (!_ok2) then {
        _ok2 = [player, "CR_Task_CheckATMs", "Kontrolliere Geldautomaten", "Prüfe die markierten ATM-Standorte.", "atm_2"] call _createTask;
        if (!_ok2) then {
            _ok2 = [player, "CR_Task_CheckATMs", "Kontrolliere Geldautomaten", "Prüfe die markierten ATM-Standorte.", "atm_3"] call _createTask;
        };
    };
} else {
    if (_isRobber) then {
        // Robber: Überfall starten an Tankstelle
        private _okR = [player, "CR_Task_StartRobbery", "Finde ein Ziel", "Begebe dich zu einer Tankstelle oder zum Tresorbereich.", "gas_station_1"] call _createTask;
        if (!_okR) then {
            _okR = [player, "CR_Task_StartRobbery", "Finde ein Ziel", "Begebe dich zu einer Tankstelle oder zum Tresorbereich.", "gas_station_2"] call _createTask;
            if (!_okR) then {
                _okR = [player, "CR_Task_StartRobbery", "Finde ein Ziel", "Begebe dich zu einer Tankstelle oder zum Tresorbereich.", "gas_station_3"] call _createTask;
                if (!_okR) then {
                    _okR = [player, "CR_Task_StartRobbery", "Finde ein Ziel", "Begebe dich zu einer Tankstelle oder zum Tresorbereich.", "vault_area"] call _createTask;
                };
            };
        };
        if (_okR) then {
            ["CR_INFO", ["Aufgabe", "Suche dir ein Ziel für einen Überfall."]] call BIS_fnc_showNotification;
        };
    } else {
        // Fallback: keine klare Rolle – gib einen generischen Task am nächsten Marker
        private _targets = ["cop_arsenal","robber_arsenal","atm_1","gas_station_1","vault_area"];
        private _done = false;
        {
            if (!_done) then {
                _done = [player, "CR_Task_Generic", "Orientierung", "Begebe dich zum markierten Punkt.", _x] call _createTask;
            };
        } forEach _targets;
        if (!_done) then {
            hint "Keine geeigneten Marker gefunden. Bitte Marker gemäß Missionsanleitung anlegen.";
            diag_log "[CR][assignTasks] Kein Task erstellt – Marker fehlen.";
        };
    };
};

// Erfolg
true