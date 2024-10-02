const router = require('express').Router()
const linkRouter = require('./linkRouter.js') 
const userRouter = require('./userRouter.js')
const authenticationRouter = require('./authenticationRouter.js')

router.use(authenticationRouter); 
router.use(userRouter); 
router.use(linkRouter); 

module.exports = router;