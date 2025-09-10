/*
    CR_fnc_startRobberyWithProgress
    Client-side function to start a robbery with a 2-minute progress bar.
    Uses ACE3 progress bar if available, otherwise falls back to vanilla progress.
    
    Params:
      0: Position - robbery location
      1: STRING - robbery type ("gas_station" or "atm")
*/

params ["_pos", "_type"];

private _hasACE = isClass (configFile >> "CfgPatches" >> "ace_interact_menu");
private _robberyText = if (_type isEqualTo "atm") then { "ATM wird geknackt..." } else { "Tankstelle wird ausgeraubt..." };

if (_hasACE && !isNil "ace_common_fnc_progressBar") then {
    // Use ACE3 progress bar (2 minutes = 120 seconds)
    [
        120,
        [_pos],
        {
            // On completion: notify server to start robbery
            params ["_args"];
            ["CR_fnc_toServer", ["CR_fnc_srv_startRobbery", [player, _args select 0]]] remoteExec [2];
            true
        },
        {
            // On failure: show message
            hint "Überfall abgebrochen!";
            false
        },
        _robberyText,
        {
            // Condition: player must stay close to robbery location
            params ["_args"];
            (player distance (_args select 0)) < 6
        },
        []
    ] call ace_common_fnc_progressBar;
    diag_log format ["[CR][Robbery] Gestartet ACE3 Progress Bar für %1 an Position %2", _type, _pos];
} else {
    if (_hasACE) then {
        diag_log "[CR][Robbery] WARNUNG: ACE3 erkannt aber ace_common_fnc_progressBar nicht verfügbar, nutze Fallback";
    };
    // Fallback: vanilla progress using hint system
    private _startTime = time;
    private _duration = 120;
    
    diag_log format ["[CR][Robbery] Gestartet Vanilla Progress für %1 an Position %2", _type, _pos];
    
    [] spawn {
        while {(time - _startTime) < _duration && (player distance _pos) < 6} do {
            private _remaining = _duration - (time - _startTime);
            private _minutes = floor (_remaining / 60);
            private _seconds = floor (_remaining % 60);
            hintSilent format ["%1\nVerbleibend: %2:%3", _robberyText, _minutes, if (_seconds < 10) then {"0" + str _seconds} else {str _seconds}];
            sleep 1;
        };
        
        if ((player distance _pos) < 6) then {
            // Completed successfully
            ["CR_fnc_toServer", ["CR_fnc_srv_startRobbery", [player, _pos]]] remoteExec [2];
            hintSilent "";
        } else {
            // Failed due to distance
            hint "Überfall abgebrochen - zu weit entfernt!";
        };
    };
};