<?php

include('../includes/db-login.php');

$conn = new mysqli($hn, $un, $pw, $db);

if ($conn->connect_error) die($conn->connect_error);

if (isset($_GET['num_readings']) && !empty($_GET['num_readings']) && ($_GET['num_readings'] <= 2000)) {
	$num_readings = $_GET['num_readings'];
} else {
	$num_readings = 2000;
}

$query = "SELECT * FROM (
			select CONCAT(SUBSTR(reading_dt,1,15),'0:00') AS `datetime`,
			GROUP_CONCAT(device_address) AS device_address,
	     		GROUP_CONCAT(temp_f) AS temp_f, GROUP_CONCAT(rh) AS rh from reading
			GROUP BY `datetime` ORDER BY `datetime` DESC LIMIT ?
			) as inner_q ORDER BY inner_q.datetime ASC";

$stmt = $conn->prepare($query);
$stmt->bind_param("i", $num_readings);

$stmt->execute();

$result = $stmt->get_result();

if (!$result) die ("Database access failed: " . $conn->error);

$rows = Array();

while ($row = $result->fetch_assoc()){
	$rows[] = $row;
}

print(json_encode($rows,JSON_NUMERIC_CHECK));

$conn->close();

?>
