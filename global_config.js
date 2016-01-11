var config = {
   server: {
      ip: '192.168.2.44',
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
