var config = {
   server: {
      ip: '192.168.3.88',
      port: '3000'
   },
   sockets: {
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
