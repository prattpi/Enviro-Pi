<?php

include('../includes/db-login.php');

$conn = new mysqli($hn, $un, $pw, $db);

if ($conn->connect_error) die($conn->connect_error);

$query = "SELECT num_readings, min_temp, max_temp, avg_temp, min_rh, max_rh, avg_rh, last_temp_f, last_rh, last_reading_dt FROM summaryData";

$result = $conn->query($query);
if (!$result) die ("Database access failed: " . $conn->error);

$row = $result->fetch_assoc();
print(json_encode($row,JSON_NUMERIC_CHECK));

$conn->close();

?>
