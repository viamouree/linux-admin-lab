# linux-admin-lab
тут лежит все чтобы экстренно развернуть упавшую сеть 
все будет выглядить примерно вот так 
01-web-lb/
    frontend/
      install_nginx_lb.sh
      nginx_lb.conf
    backend/
      install_apache_backend.sh

  02-mysql-repl-cms-backup/
    master/
      install_mysql_master.sh
    slave/
      install_mysql_slave.sh
      backup_mysql_tables_with_binlog.sh
      cron_mysql_backup

     wordpress/
      install_wordpress_on_master.sh

  03-monitoring/
    node_exporter/
      install_node_exporter.sh
    prometheus/
      install_prometheus.sh
      prometheus.yml
