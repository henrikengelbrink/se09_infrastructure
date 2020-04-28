wget https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.3.2-darwin-x86_64.tar.gz
tar xvzf metricbeat-7.3.2-darwin-x86_64.tar.gz
cd metricbeat-7.3.2-darwin-x86_64
./metricbeat setup --dashboards
rm -rf ../metricbeat-7.3.2-darwin-x86_64.tar.gz
rm -rf ../metricbeat-7.3.2-darwin-x86_64