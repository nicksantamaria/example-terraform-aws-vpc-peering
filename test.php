<?php

// Find info for all the instances in this stack.
$tf_instances = explode("\n", `terraform state list | grep aws_instance`);
$instances = [];
foreach (array_filter($tf_instances) as $instance) {
  $command = "terraform state show ${instance}";
  $retval = `$command`;
  $rows = explode("\n", $retval);

  foreach (array_filter($rows) as $row) {
    list($key, $value) = explode('=', $row);
    $instances[$instance][trim($key)] = trim($value);
  }

  if (strpos($instance, 'primary') !== FALSE) {
    $instances[$instance]['vpc'] = 'primary';
  }

  if (strpos($instance, 'secondary') !== FALSE) {
    $instances[$instance]['vpc'] = 'secondary';
  }
}

$stack = [];
foreach ($instances as $info) {
  $stack[$info['vpc']][$info['availability_zone']] = [
    'public' => $info['public_ip'],
    'private' => $info['private_ip'],
  ];
}

// Run through each permutation and ensure machines can all connect to each other.
foreach ($stack as $source_vpc => $source_instances) {
  foreach ($source_instances as $source_az => $source_ip) {
    foreach ($stack as $dest_vpc => $dest_instances) {
      foreach ($dest_instances as $dest_az => $dest_ip) {
        if ($source_az == $dest_az && $source_ip == $dest_ip) continue;

        $pid = pcntl_fork();
        if ($pid == -1) {
          exit("Error forking...\n");
        }
        else if ($pid == 0) {
          //echo "- Testing connection between ${source_vpc}.${source_az} ${dest_vpc}.${dest_az}\n";
          $response = test_connection($source_ip, $dest_ip);
          print_table_row([
            'source_vpc' => $source_vpc,
            'source_az' => $source_az,
            'dest_vpc' => $dest_vpc,
            'dest_az' => $dest_az,
            'source_ip' => $source_ip['private'],
            'dest_ip' => $dest_ip['private'],
            'response' => trim($response),
          ]);
          exit();
        }
      }
    }
  }
}

while(pcntl_waitpid(0, $status) != -1);

function test_connection($source_ip, $dest_ip) {
  $remote_command = "curl -s --connect-timeout 3 -I -XGET ${dest_ip['private']} | grep HTTP";
  $local_command = "ssh -q ubuntu@${source_ip['public']} '${remote_command}'";
  $response = `$local_command`;
  return $response;
}

function print_table_row($row) {
  foreach ($row as $i => & $col) {
    $col = str_pad($col, 16, " ", STR_PAD_BOTH);
  }
  print "| " . implode(" | ", $row) . " |\n";
}
