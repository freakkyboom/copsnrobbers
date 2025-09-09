class CfgFunctions {
    class CR {
        tag = "CR";

        class Core {
            file = "functions\core";
            class initCommon { preInit = 1; };
            class initServer {};
            class initClient {};
            class validateMarkers {};
            class bootToast {};
        };

        class Net {
            file = "functions\net";
            class notifySide {};
            class toServer {};
        class createDispatchMarker {};
        };

        class Util {
            file = "functions\util";
            class nearMarkerPos {};
            class unitIsCop {};
            class unitIsRobber {};
        };

        class Interact {
            file = "functions\interact";
            class setupInteractions {};
            // ACE/Action helper
            class addAceOrAction {};
            // Custom setups
            class setupRobberyNPCs {};
            class setupGearDealer {};
            class setupCarDealer {};
            class setupGarage {};
        };

        class Gameplay {
            file = "functions\gameplay";
            class assignTasks {};
            // client stub for robbery start
            class startRobbery {};
        };

        class Server {
            file = "functions\server";
            class srv_registerRobbery {};
            class srv_deposit {};
            class srv_withdraw {};
            class srv_startRobbery {};
            class srv_finishRobbery {};
            class srv_purchaseGear {};
            class srv_purchaseVehicle {};
        };
    };
};