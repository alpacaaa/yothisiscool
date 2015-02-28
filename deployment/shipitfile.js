
var fs = require('fs');
var path = require('path');
var Promise = require('bluebird');

module.exports = function (shipit) {
  require('shipit-deploy')(shipit);
  require('shipit-shared')(shipit);

  var config = getConfig(shipit);
  var repo_url = path.join(__dirname, '..');

  shipit.initConfig({
    default: {
      workspace: '/tmp/dude-build',
      deployTo: '/home/dude/www',
      repositoryUrl: repo_url,
      ignores: ['.git', 'node_modules', 'client', 'deployment'],
      key: '~/.ssh/id_rsa',
      keepReleases: 4,
      shallowClone: true,
      shared: {
        dirs: [
          'logs'
        ],
        files: [
          'server/datasources.development.json',
          'server/datasources.production.json',
          'server/dude-config.json'
        ]
      }
    },

    vagrant: {
      servers: 'dude@' + config.HOST,
      key: '/.vagrant.d/insecure_private_key',
      dude: {
        USE_HTTPS: false
      }
    },

    production: {
      servers: 'dude@' + config.HOST,
      dude: {
        WS_ENDPOINT: 'https://dudethisis.cool'
      }
    }
  });


  shipit.config.dude = shipit.config.dude || {};

  Object.keys(shipit.config.dude).forEach(function(key) {
    config[key] = shipit.config.dude[key];
  });


  if (!config.WS_ENDPOINT) {
    var prefix = config.USE_HTTPS ? 'https://' : 'http://';
    config.WS_ENDPOINT = prefix + config.HOST + ":3000";
  }







  shipit.task('deploy-dude', [
    'deploy:init',
    'deploy:fetch',
    'link-clientfolders',
    'build-frontend',
    'deploy:update',
    'copy-modules',
    'install-modules',
    'deploy:publish',
    'migrate-db',
    'deploy:clean',
    'reload-app'
  ]);




  shipit.blTask('link-clientfolders', function() {
    var dest = path.join(shipit.config.workspace, 'client');

    var promises = ['bower_components', 'node_modules'].map(function (folder) {
      var src = path.join(repo_url, 'client', folder);
      return shipit.local('ln -s ' + src + ' ' + dest);
    });

    return Promise.all(promises);
  });




  shipit.blTask('build-frontend', function() {
    var endpoint = 'WS_ENDPOINT=' + config.WS_ENDPOINT;
    var environment = '--environment=' + config.DUDE_ENV;
    var ember_path  = path.join(shipit.config.workspace, 'client');

    var command = [
      endpoint,
      'ember build --output-path=../frontend',
      environment
    ].join(' ');

    return shipit.local(command, {cwd: ember_path});
  });




  shipit.blTask('copy-modules', function() {
    var currentPath = path.join(shipit.config.deployTo, 'current/node_modules');

    var copy_modules = [
      'cp -R',
      currentPath,
      shipit.releasePath,
      '2>/dev/null || :'
    ].join(' ');

    return shipit.remote(copy_modules);
  });



  shipit.blTask('install-modules', function() {
    var npm_install = [
      'cd',
      shipit.releasePath,
      '&& npm install'
    ].join(' ');

    return shipit.remote(npm_install);
  });




  shipit.blTask('migrate-db', function() {
    var command = [
      'cd',
      shipit.releasePath,
      '&&',
      'NODE_ENV=' + config.DUDE_ENV,
      '/usr/local/nodejs/default/bin/coffee',
      'migrate.coffee'
    ].join(' ');

    return shipit.remote(command);
  });



  shipit.blTask('reload-app', function() {
    var pm2 = '/usr/local/nodejs/default/bin/pm2';
    return shipit.remote(pm2 + ' reload dude');
  });




  shipit.blTask('start-app', function() {
    var script = 'current/server/server.coffee';
    var currentPath = path.join(shipit.config.deployTo, script);

    var command = [
      'NODE_ENV=' + config.DUDE_ENV,
      '/usr/local/nodejs/default/bin/pm2',
      'start',
      currentPath,
      '--name dude -i 0' // Start in cluster mode so that it can be reloaded
    ].join(' ');

    return shipit.remote(command);
  });
};







function getConfig(shipit) {
  var config = {
    DUDE_ENV: 'production',
    HOST: null,
    WS_ENDPOINT: null,
    USE_HTTPS: true
  };

  Object.keys(config).forEach(function(key) {
    if (process.env[key])
      config[key] = process.env[key];
  });

  if (!config.HOST) {
    var env  = shipit.environment;
    var file = env + '.txt';
    if (!fs.existsSync(file)) {
      throw new Error("Don't know where to deploy man.");
    }

    var content = fs.readFileSync(file).toString();
    var host = content.replace(/\s+$/,"");

    if (!host) {
      throw new Error("Found .txt file but looks kinda fucked up.")
    }


    config.HOST = host;
  }

  return config;
}
