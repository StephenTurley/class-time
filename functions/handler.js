'use strict'

module.exports.schedule = (event, context, callback) => {
  callback(null, {
    statusCode: 200,
    isBase64Encoded: false,
    headers: {},
    body: 'Hello'
  })
}
