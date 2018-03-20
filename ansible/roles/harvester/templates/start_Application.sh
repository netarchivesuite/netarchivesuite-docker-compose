#@IgnoreInspection BashAddShebang
  {% set app = item.app_name+"_"+item.app_id %}
  {% set dir = "/home/"+ansible_ssh_user+"/"+nas_env %}
  echo Starting linux application: {{app}}
  cd {{dir}}
  PIDS=$(ps -wwfe | grep dk.netarkivet.harvester.heritrix3.HarvestControllerApplication | grep -v grep | grep /home/netarkdv/SystemTest/conf/settings_{{app}}.xml | awk "{print \$2}")
  if [ -n "$PIDS" ] ; then
    echo Application already running.
  else
    export CLASSPATH={{dir}}/lib/netarchivesuite-monitor-core.jar:{{dir}}/lib/netarchivesuite-heritrix3-controller.jar:$CLASSPATH;
    java -Xmx1024m  -Ddk.netarkivet.settings.file={{dir}}/conf/settings_{{app}}.xml -Dlogback.configurationFile={{dir}}/conf/logback_{{app}}.xml dk.netarkivet.harvester.heritrix3.{{item.app_name}} < /dev/null > start_{{app}}.log 2>&1 &
  fi
