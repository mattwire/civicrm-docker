#!/usr/bin/env bash

ORIG_CIVI_DIR='/opt/buildkit/build/test-build/sites/all/modules/civicrm'
MOUNTED_DIR='/var/www/civicrm'


if [ -d ${MOUNTED_DIR} ]; then
  PATH=$PATH:/opt/buildkit/bin
  cp -n ${ORIG_CIVI_DIR}/bin/setup.conf ${MOUNTED_DIR}/bin/setup.conf
  cp -n ${ORIG_CIVI_DIR}/civicrm.config.php ${MOUNTED_DIR}/
  rm -rf ${ORIG_CIVI_DIR} && ln -s ${MOUNTED_DIR} ${ORIG_CIVI_DIR};
  [ ! -d ${MOUNTED_DIR}/packages ] && git clone git://github.com/civicrm/civicrm-packages.git ${MOUNTED_DIR}/packages
  [ ! -d ${MOUNTED_DIR}/drupal ] && git clone https://github.com/civicrm/civicrm-drupal.git ${MOUNTED_DIR}/drupal
  cd ${ORIG_CIVI_DIR} && service mysql start && ./bin/setup.sh
  cd ${ORIG_CIVI_DIR}/../../ && /opt/buildkit/bin/drush cc civicrm;
fi;

/usr/bin/supervisord
