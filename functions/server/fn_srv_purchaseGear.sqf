/*
    CR_fnc_srv_purchaseGear
    Server-side handler for equipment and weapon purchases. The client
    sends the selected class name and price; the server validates the
    player's cash and subtracts the appropriate amount before adding
    the item to the player's inventory. Weapons are detected via
    CfgWeapons and granted with three magazines. Items are added to
    uniform/backpack and assigned where appropriate.

    Params:
      0: Object - the player making the purchase
      1: STRING - className of the item to purchase
      2: SCALAR - price of the item

    Note: The server trusts the passed price but still verifies
    sufficient funds exist. For a more secure shop you could cross
    reference a whitelist of class names and prices server-side.
*/

if (!isServer) exitWith {};

params ["_unit", "_className", "_price"];

// Validate
if (isNull _unit || {!isPlayer _unit}) exitWith {};

private _priceN = _price max 0;
private _cash = _unit getVariable ["CR_Cash", 0];

if (_cash < _priceN) exitWith {
    ["CR_INFO", ["Shop", "Zu wenig Geld."]] remoteExec ["BIS_fnc_showNotification", owner _unit];
};

// Deduct payment
_unit setVariable ["CR_Cash", _cash - _priceN, true];

// Determine if the class is a weapon
private _isWeapon = isClass (configFile >> "CfgWeapons" >> _className);

if (_isWeapon) then {
    // Add the weapon and magazines
    _unit addWeapon _className;
    private _mags = getArray (configFile >> "CfgWeapons" >> _className >> "magazines");
    if (_mags isNotEqualTo []) then {
        private _mag = _mags select 0;
        for "_i" from 1 to 3 do { _unit addMagazine _mag; };
    };
} else {
    // Otherwise treat as equipment item
    _unit addItem _className;
    _unit assignItem _className;
    // Attempt to add to uniform or backpack for storage
    _unit addItemToUniform _className;
};

// Notify client
["CR_INFO", ["Shop", format ["Gekauft: %1 für $%2", _className, _priceN]]] remoteExec ["BIS_fnc_showNotification", owner _unit];

diag_log format ["[CR][Shop] %1 purchased %2 for %3$", name _unit, _className, _priceN];