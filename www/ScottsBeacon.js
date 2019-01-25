/*global cordova, module*/

console.log('ScottsBeacon is present. Run cordova.plugins.initializeScottsBeacon() to launch.');

module.exports = {
    initializeScottsBeacon: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, 'ScottsBeacon', 'initializeScottsBeacon', []);
    }
};
