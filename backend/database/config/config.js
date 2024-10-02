const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

module.exports = {
  development: {
    username: process.env.DEV_DB_USERNAME,
    password: process.env.DEV_DB_PASSWORD,
    database: process.env.DEV_DB_NAME,
    host: 'localhost',
    port: 3306,
    dialect: 'mysql',
    dialectOptions: {
      bigNumberStrings: true,
    },
    use_env_variable: process.env.DEV_DB_URL,
  },
  test: {
    username: process.env.TEST_DB_USERNAME,
    password: process.env.TEST_DB_PASSWORD,
    database: process.env.TEST_DB_NAME,
    host: 'localhost',
    port: 3306,
    dialect: 'mysql',
    dialectOptions: {
      bigNumberStrings: true,
    },
    use_env_variable: process.env.DEV_DB_URL,
  },
  production: {
    username: process.env.PROD_DB_USERNAME,
    password: process.env.PROD_DB_PASSWORD,
    database: process.env.PROD_DB_NAME,
    host: process.env.PROD_DB_HOSTNAME, 
    dialect: 'mysql',
    dialectOptions: {
      bigNumberStrings: true,
    },
    use_env_variable: process.env.PROD_DB_URL,
  },
};
