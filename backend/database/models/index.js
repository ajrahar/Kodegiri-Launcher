'use strict';

const fs = require('fs');
const path = require('path');
const Sequelize = require('sequelize'); 
const basename = path.basename(__filename);
const env = 'development';
const config = require(__dirname + '/../config/config.js')[env];
const db = {};

let sequelize;
if (config.use_env_variable) {
  sequelize = new Sequelize(config.use_env_variable);  
} else {
  sequelize = new Sequelize(config.database, config.username, config.password, config);  

}

sequelize
  .authenticate()
  .then(() => {
    console.log(`connected database ${db.sequelize.getDatabaseName()} :)`);
  })
  .catch(err => {
    console.error(`disconnect database ${db.sequelize.getDatabaseName()} :( \n\n`, err);
  });

fs
  .readdirSync(__dirname)
  .filter(file => {
    return (
      file.indexOf('.') !== 0 &&
      file !== basename &&
      file.slice(-3) === '.js' &&
      file.indexOf('.test.js') === -1
    );
  })
  .forEach(file => {
    const model = require(path.join(__dirname, file))(sequelize, Sequelize.DataTypes);
    db[model.name] = model;
  });

Object.keys(db).forEach(modelName => {
  if (db[modelName].associate) {
    db[modelName].associate(db);
  }
});

db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db;
