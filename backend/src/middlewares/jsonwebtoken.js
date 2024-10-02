const jsonwebtoken = require('jsonwebtoken');
const jwtToken = process.env.JWT_SECRET;

exports.middleware = async (req, res, next) => { 
     const authHeader = req.header('Authorization');    
     if (!authHeader) {
          return res.status(401).json({
               status: false,
               message: "Access denied. No token provided. Please log in to continue.",
               reponse : authHeader
          })
     }  
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
