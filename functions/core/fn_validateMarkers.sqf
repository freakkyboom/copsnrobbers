/*
    Validiere Pflichtmarker und melde fehlende Marker.
*/
private _missing = [];
{
    if (isNil { getMarkerPos _x }) then { _missing pushBack _x; };
} forEach (missionNamespace getVariable ["CR_MarkersRequired", []]);

if (_missing isNotEqualTo []) then {
    private _msg = format ["[CR] Marker fehlen: %1", _missing];
    diag_log _msg;
    if (hasInterface) then { hintSilent _msg; };
} else {
    diag_log "[CR] Alle Pflichtmarker vorhanden.";
};