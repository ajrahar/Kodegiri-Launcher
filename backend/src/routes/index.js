const router = require('express').Router()
const linkRouter = require('./linkRouter.js') 
const userRouter = require('./userRouter.js')
const authenticationRouter = require('./authenticationRouter.js')

router.use(authenticationRouter); 
router.use(linkRouter); 
router.use(userRouter); 

module.exports = router;