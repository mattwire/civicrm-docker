#!/usr/bin/env bash

CIVI_ROOT='/opt/buildkit/build/test-build/sites/all/modules/civicrm'
MOUNTED_DIR='/var/www/civicrm'
EXTENSION_DIR='/var/www/extensions'

chmod a+rwx /var/www/extensions/

if [ -d ${MOUNTED_DIR} ]; then
  PATH=$PATH:/opt/buildkit/bin
  cp -n ${CIVI_ROOT}/bin/setup.conf ${MOUNTED_DIR}/bin/setup.conf
  cp -n ${CIVI_ROOT}/civicrm.config.php ${MOUNTED_DIR}/
  rm -rf ${CIVI_ROOT} && ln -s ${MOUNTED_DIR} ${CIVI_ROOT};
  [ ! -d ${MOUNTED_DIR}/packages ] && git clone git://github.com/civicrm/civicrm-packages.git ${MOUNTED_DIR}/packages
  [ ! -d ${MOUNTED_DIR}/drupal ] && git clone https://github.com/civicrm/civicrm-drupal.git ${MOUNTED_DIR}/drupal
  cd ${CIVI_ROOT} && service mysql start && ./bin/setup.sh
  cd ${CIVI_ROOT}/../../ && /opt/buildkit/bin/drush cc civicrm;
fi;

service mysql start && sleep 5;
cd ${CIVI_ROOT} && cv api Setting.create extensionsDir=${EXTENSION_DIR} > /dev/null

for info in $(find ${EXTENSION_DIR} -name info.xml); do
  NEW_KEY=$(sed -n '/^ *<file>/s/<file>\(.*\)<\/file>/\1/p' ${info});
  EXTENSION_KEYS=${EXTENSION_KEYS}" "${NEW_KEY}
done;
cd ${CIVI_ROOT} && cv ext:enable ${EXTENSION_KEYS}

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
