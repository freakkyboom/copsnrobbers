/*
    Liefert [true,posASL] wenn Marker existiert, sonst [false,[0,0,0]]
*/
params ["_markerName"];
if (isNil { getMarkerPos _markerName }) exitWith { [false, [0,0,0]] };
[true, getMarkerPos _markerName]