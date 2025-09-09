/*
    preInit (unscheduled): Basiskonfiguration & Konstanten.
*/
missionNamespace setVariable ["CR_StartedAt", diag_tickTime];
missionNamespace setVariable ["CR_Version", "1.0.0"];
missionNamespace setVariable ["CR_MarkersRequired", [
    "cop_spawn","robber_spawn",
    "cop_vehicle_spawn","robber_vehicle_spawn",
    "cop_arsenal","robber_arsenal",
    "vault_area",
    "gas_station_1","gas_station_2","gas_station_3",
    "atm_1","atm_2","atm_3","atm_4","atm_5"
]];

// ökonomische Defaults
missionNamespace setVariable ["CR_Config_Economy", [
    ["baseRobberyPayout", 2500],
    ["atmFee", 0.02],               // 2 %
    ["startCash", 1000]
]];

publicVariable "CR_Version";
diag_log format ["[CR] preInit ok. Version %1", missionNamespace getVariable ["CR_Version","?"]];