// Generated by CoffeeScript 1.10.0
(function() {
  var assert, tile, w, w2, world;

  assert = require('assert');

  world = require('./world.coffee');

  w = new world.World();

  w.map.set(0, 0, 11);

  w.map.set(0, 1, 22);

  w.map.set(1, 0, 33);

  tile = w.getTile(0, 0);

  w2 = new world.World();

  w2.loadTile(0, 0, tile);

  assert.equal(11, w2.map.get(0, 0));

  assert.equal(22, w2.map.get(0, 1));

  assert.equal(33, w2.map.get(1, 0));

  console.log('all tests ok');

}).call(this);
