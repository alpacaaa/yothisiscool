/* jshint node: true */

module.exports = function(environment) {

  var ENV = {
    modulePrefix: 'client',
    environment: environment,
    baseURL: '/',
    locationType: 'auto',
    EmberENV: {
      FEATURES: {
        // 'ember-htmlbars': true
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      }
    },

    APP: {
      // Here you can pass flags/options to your application instance
      // when it is created
    }
  };

  var WS_ENDPOINT = process.env.WS_ENDPOINT || 'http://localhost:3000';

  if (environment === 'development') {
    // ENV.APP.LOG_RESOLVER = true;
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    // ENV.APP.LOG_TRANSITIONS = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.baseURL = '/';
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
  }


  ENV.APP.OAUTH_ENDPOINT = WS_ENDPOINT;
  ENV.APP.WS_ENDPOINT = WS_ENDPOINT + '/api/';


  ENV.contentSecurityPolicy = {
    'default-src': "'none'",
    'script-src': "'self'",
    'font-src': "'self' https://fonts.gstatic.com",
    'connect-src': "'self' https://api.github.com/ " + WS_ENDPOINT ,
    'img-src': "*",
    'style-src': "'self' 'unsafe-inline' https://fonts.googleapis.com",
    'media-src': "'self'"
  };


  return ENV;
};
