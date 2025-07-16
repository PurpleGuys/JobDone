module.exports = {
  apps: [{
    name: 'bennespro',
    script: './server/index.ts',
    interpreter: 'tsx',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 5000
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 5000
    },
    error_file: './logs/pm2-error.log',
    out_file: './logs/pm2-out.log',
    log_file: './logs/pm2-combined.log',
    time: true,
    watch: false,
    ignore_watch: ['node_modules', 'logs', 'dist'],
    max_memory_restart: '500M',
    min_uptime: '10s',
    listen_timeout: 3000,
    kill_timeout: 5000,
    autorestart: true,
    restart_delay: 4000,
    max_restarts: 10
  }]
}