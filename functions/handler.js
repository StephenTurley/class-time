'use strict'

const createEvent = (title, url, startHour, startMinute, durationInMinutes) => {
  return {
    title: title,
    url: url,
    startHour: startHour,
    startMinute: startMinute,
    durationInMinutes: durationInMinutes
  }
}

module.exports.schedule = (event, context, callback) => {
  const schedule = [
    createEvent('first', 'http://google.com', 8, 30, 30),
    createEvent('third', 'http://google.com', 12, 0, 120),
    createEvent('last', 'http://google.com', 16, 30, 30),
    createEvent('second', 'http://google.com', 9, 0, 30)
  ]
  callback(null, {
    statusCode: 200,
    isBase64Encoded: false,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Credentials': true
    },
    body: JSON.stringify(schedule)
  })
}
