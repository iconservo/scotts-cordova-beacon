/*global cordova, module*/

console.log('ScottsBeacon is present.');

var ScottsBeacon = {
    initializeScottsBeacon: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, 'ScottsBeacon', 'initializeScottsBeacon', []);
    }
};

module.exports = ScottsBeacon