<?php
# Copyright 2010 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
####Added
###The below class allows for sending to statsD on the head node
class StatsD {

    private $host, $port;

    // Instantiate a new client
    public function __construct($host = 'localhost', $port = 8125) {
        $this->host = $host;
        $this->port = $port;
    }

    // Record timing
    public function timing($key, $time, $rate = 1) {
        $this->send("$key:$time|ms", $rate);
    }

    // Time something
    public function time_this($key, $callback, $rate = 1) {
        $begin = microtime(true);
        $callback();
        $time = floor((microtime(true) - $begin) * 1000);
        // And record
        $this->timing($key, $time, $rate);
    }

    // Record counting
    public function counting($key, $amount = 1, $rate = 1) {
        $this->send("$key:$amount|c", $rate);
    }

    // Send
    private function send($value, $rate) {
        $fp = fsockopen('udp://' . $this->host, $this->port, $errno, $errstr);
        // Will show warning if not opened, and return false
        if ($fp) {
            fwrite($fp, "$value|@$rate");
            fclose($fp);
        }
    }

}

#create the stats sending object.
$stats = new StatsD('10.42.41.1', 8125);
#configure $myname
$debian_chroot = '/etc/debian_chroot';

if (file_exists($debian_chroot)) {
        $thename = file_get_contents($debian_chroot);
        $myname = trim($thename);
}



if (isset($_REQUEST['planet']) and ($_REQUEST['planet'] != '')) {
  $handle = @fopen("/tmp/query_php.txt", "w");
  if ($handle) {
    fwrite($handle, "planet=" . $_REQUEST['planet']);
    fclose($handle);
  }
  exec('/lg/chown_tmp_query');
  echo "Going to " . ucwords($_REQUEST['planet']);
  $stats->counting("$myname.usage.relaunched." . $_REQUEST['planet'], 1);
} elseif (isset($_REQUEST['query']) and (preg_match('/^relaunch(.*)?/', $_REQUEST['query']))) {
  $action = split('-', $_REQUEST['query']);
  if (($action[0] == $_REQUEST['query']) and !isset($action[1])) {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/lg-sudo-bg service lightdm restart');
    echo "Attempting Relaunch";
    $stats->counting("$myname.usage.relaunched." . $_REQUEST['query'], 1);
  } elseif ($action[1] == 'aquarium' || $action[1] == 'mplayer' || $action[1] == 'earth') {
    exec('/usr/bin/sudo -H -u lg ln -snf /home/lg/earth/scripts/launch-'.$action[1].'.sh /home/lg/earth/scripts/launch-galaxy.sh');
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/lg-sudo-bg service lightdm restart');
    echo "Attempting " . $action[1] . " Relaunch";
    $stats->counting("$myname.usage.relaunch." . $action[1], 1);
  } else {
    echo "Unknown command";
  }
  unset($action);
} elseif (isset($_REQUEST['query']) and (preg_match('/^sview(.*)?/', $_REQUEST['query']))) {
  $action = split('-', $_REQUEST['query']);
  if (($action[0] == $_REQUEST['query']) and !isset($action[1])) {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/lg-run-bg /home/lg/bin/streetview');
    echo "Attempting to load StreetView";
    $stats->counting("$myname.usage.relaunch.streetview", 1);
  } elseif ($action[1] == 'fwd') {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/lg-run-bg /home/lg/bin/streetview fwd');
    echo "StreetView " . $action[1];
    $stats->counting("$myname.usage.streetview-movement-forward", 1);
  } elseif ($action[1] == 'rev') {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/lg-run-bg /home/lg/bin/streetview rev');
    echo "StreetView  " . $action[1];
    $stats->counting("$myname.usage.streetview-movement-reverse", 1);
  } elseif ($action[1] == 'left') {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/lg-run-bg /home/lg/bin/streetview left');
    echo "StreetView  " . $action[1];
    $stats->counting("$myname.usage.streetview-movement-left", 1);
  } elseif ($action[1] == 'right') {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/lg-run-bg /home/lg/bin/streetview right');
    echo "StreetView  " . $action[1];
    $stats->counting("$myname.usage.streetview-movement-right", 1);
  } elseif ($action[1] == 'un') {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/lg-run-bg /home/lg/bin/streetview unload');
    echo "StreetView  " . $action[1];
    $stats->counting("$myname.usage.streetview-exit", 1);
  } else {
    echo "Unknown command";
  }
  unset($action);
} elseif (isset($_REQUEST['query']) and ($_REQUEST['query'] == 'keystroke')) {
  exec('/usr/bin/sudo -H -u lg /home/lg/bin/lg-run-bg /home/lg/bin/streetview key ' . escapeshellarg($_REQUEST['keystroke']));
  echo "Keystroke " . $_REQUEST['keystroke'];
} elseif (isset($_REQUEST['query']) and (preg_match('/^mpctl(.*)?/', $_REQUEST['query']))) {
  $action = split('-', $_REQUEST['query']);
  if (($action[0] == $_REQUEST['query']) and !isset($action[1])) {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/lg-run-bg /home/lg/bin/launchmplayer 3 /home/lg/media/videos/nature.mp4');
    echo "Attempting to launch MPlayer";
    $stats->counting("$myname.usage.mplayer-launches", 1);
  } elseif ($action[1] == 'prev') {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/mp-control pt_step -1');
    echo "MPlayer " . $action[1];
    $stats->counting("$myname.usage.mplayer-" . $action[1], 1);
  } elseif ($action[1] == 'rev') {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/mp-control master seek -15');
    echo "MPlayer " . $action[1];
    $stats->counting("$myname.usage.mplayer-" . $action[1], 1);
  } elseif ($action[1] == 'fwd') {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/mp-control master seek +15');
    $stats->counting("$myname.usage.mplayer-" . $action[1], 1);
    echo "MPlayer " . $action[1];
    $stats->counting("$myname.usage.mplayer-" . $action[1], 1);
  } elseif ($action[1] == 'next') {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/mp-control pt_step +1');
    echo "MPlayer " . $action[1];
    $stats->counting("$myname.usage.mplayer-" . $action[1], 1);
  } elseif ($action[1] == 'pause') {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/mp-control pause');
    echo "MPlayer " . $action[1];
    $stats->counting("$myname.usage.mplayer-" . $action[1], 1);
  } elseif ($action[1] == 'stop') {
    exec('/usr/bin/sudo -H -u lg /home/lg/bin/mp-control stop');
    echo "MPlayer " . $action[1];
    $stats->counting("$myname.usage.mplayer-" . $action[1], 1);
  } else {
    echo "Unknown command";
    $stats->counting("$myname.usage.woopsy-daisies", 1);
  }
  unset($action);
} elseif (isset($_REQUEST['query']) and ($_REQUEST['query'] != '') and isset($_REQUEST['name']) and ($_REQUEST['name'] != '')) {
  $handle = @fopen("/tmp/query_php.txt", "w");
  if ($handle) {
    fwrite($handle, $_REQUEST['query']);
    fclose($handle);
  }
  exec('/lg/chown_tmp_query');
  echo "Going to " . $_REQUEST['name'];
  $stats->counting("$myname.usage.travels." . $_REQUEST['name'], 1);
} elseif (isset($_REQUEST['layer']) and ($_REQUEST['layer'] != '') and isset($_REQUEST['name']) and ($_REQUEST['name'] != '')) {

  # Do something awesome to add or remove "layer" from kml.txt.
  $layerfilename = "kmls.txt";
  $foundlayer = FALSE;

  # These flags require PHP 5.
  $layerarray = file($layerfilename, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

  foreach ($layerarray as $linenumber => $line) {
    # echo $linenumber . PHP_EOL . $line; #debug
    if ($line == $_REQUEST['layer']) {
      echo("Disabling layer " . $_REQUEST['name']);
      $stats->counting("$myname.usage.layers-disabled." . $_REQUEST['name'], 1);
      unset($layerarray[$linenumber]);
      $foundlayer = TRUE;
    }
  }
  unset($line);

  # If we didn't find the layer in the file, add it.
  if (! $foundlayer) {
    $layerarray[] = $_REQUEST['layer'];
    echo "Enabling layer " . $_REQUEST['name'];
    $stats->counting("$myname.usage.layers-enabled." . $_REQUEST['name'], 1);
  }

  # Write the array back to the file.
  # This raises some obvious concurrency concerns since there's no file locking.
  $handle = @fopen($layerfilename, "wb");
  if ($handle) {
    fwrite($handle, implode(PHP_EOL, $layerarray));
    fclose($handle);
  }
}
?>
