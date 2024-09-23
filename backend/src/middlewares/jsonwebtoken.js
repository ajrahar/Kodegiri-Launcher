const models = require('../../database/models/index');
const env = 'token';
const config = require(__dirname + '/../../database/config/config.json')[env];
const jsonwebtoken = require('jsonwebtoken');

exports.middleware = async (req, res, next) => {
     const jwtToken = config.jwttoken;
     // const token = req.header('token');
     // const { email } = req.body;
     // // console.log('author : ',token)
     // if (!token) {
     //      return res.status(401).json({
     //           status: false, 
     //           message: "Access denied. No token provided. Please log in to continue."
     //      })
     // }
     // const decode = jsonwebtoken.verify(token, jwtToken)
     // req.uid = decode.uid
     // next()
     const authHeader = req.header('Authorization');   

     console.log('user hedaer '+authHeader );
     if (!authHeader) {
          return res.status(401).json({
               status: false,
               message: "Access denied. No token provided. Please log in to continue.",
               reponse : authHeader
          })
     }
     const token = authHeader.split(' ')[1];

     try {
          const decode = jsonwebtoken.verify(authHeader, jwtToken);
          req.isAdmin = decode.isAdmin;

          if (req.isAdmin == 1) {
               next();
          } else if (req.isAdmin == 0) {
               return res.status(401).json({
                    status: false,
                    message: "Access denied. You are not an admin."
               })
          } else {
               return res.status(401).json({
                    status: false,
                    message: "Access denied. Not found role."
               })
          }
     } catch (error) {
          return res.status(403).json({
               status: false,
               message: "Invalid token. Please log in again.",
               response: `${error.message}`
          });
     }
}
