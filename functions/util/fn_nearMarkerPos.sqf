/*
    Liefert [true,posASL] wenn Marker existiert, sonst [false,[0,0,0]]
    Enhanced with better error reporting
*/
params ["_markerName"];

if (isNil "_markerName" || _markerName isEqualTo "") exitWith { 
    diag_log "[CR][nearMarkerPos] FEHLER: Marker-Name ist nil oder leer";
    [false, [0,0,0]] 
};

private _markerPos = getMarkerPos _markerName;
if (_markerPos isEqualTo [0,0,0]) exitWith { 
    diag_log format ["[CR][nearMarkerPos] Marker '%1' nicht gefunden oder an Position [0,0,0]", _markerName];
    [false, [0,0,0]] 
};

diag_log format ["[CR][nearMarkerPos] Marker '%1' gefunden an Position %2", _markerName, _markerPos];
[true, _markerPos]