Sequelize = require("sequelize")
db = new Sequelize 'music', 'root', 'root',
      pool:
        maxConnections: 20
        maxIdleTime: 30
      define:
        underscored: true
        charset: 'utf8'
        collate: 'utf8_general_ci'
        timestamps: true

module.exports = db
