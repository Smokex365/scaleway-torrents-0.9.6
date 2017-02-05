<?php

  include('/var/www/rutorrent/plugins/screenshots/conf_base.php');

  // libav sucks compared to ffmpeg, but:
  // - it's enough to take screenshots
  // - it's packaged
  // - ffmpeg is only packaged in Ubuntu Vivid
  $pathToExternals['ffmpeg'] = '/usr/bin/avconv';
