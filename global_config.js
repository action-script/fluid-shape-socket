var config = {
   server: {
      ip: '10.230.0.234',
      port: '3000'
   },
   socket: {
      maxConnections: 4
   },
   collision: {
      maxRadius: 240,
      time: 2000,
      interval: 10
   },
   spheres:{
      radius: 50,
      box: 60
   }
}

module.exports = config;
