<?php

// Usage: mysql_magic($query [, $arg...]);
function mysql_magic()
{
    global $dblink, $sqlhost, $sqluser, $sqlpass, $sqlbase;
    $narg = func_num_args();
    $args = func_get_args();
    
    if (!$dblink)
    {
        $dblink = mysql_connect( $sqlhost, $sqluser, $sqlpass );
        mysql_select_db( $sqlbase, $dblink );
    }
    
    $req_sql = array_shift($args);
    $req_args = $args;
    
    $req_query = mysql_bind($req_sql, $req_args);
    $req_result = mysql_query($req_query);
    
    if (!$req_result)
    {
        trigger_error(mysql_error());
        return false;
    }
    
    if (startsWith($req_sql, 'delete') || startsWith($req_sql, 'update'))
    {
        return mysql_affected_rows(); // -1 || N
    }
    else if (startsWith($req_sql, 'insert'))
    {
        return mysql_insert_id(); // ID || 0 || FALSE
    }
    else if (endsWith($req_sql, 'limit 1'))
    {
        return mysql_fetch_assoc($req_result); // [] || FALSE
    }
    else
    {
        return mysql_fetch_all($req_result); // [][]
    }
}

function mysql_bind($sql, $values=array())
{
    //foreach ($values as &$value) $value = mysql_real_escape_string($value);
    //$sql = vsprintf( str_replace('?', "'%s'", $sql), $values); 
    return $sql;
}

function mysql_fetch_all($result)
{
    $resultArray = array();
    while(($resultArray[] = mysql_fetch_assoc($result)) || array_pop($resultArray));
    return $resultArray;
}

function startsWith($haystack,$needle,$case=false) {
    if($case){return (strcmp(substr($haystack, 0, strlen($needle)),$needle)===0);}
    return (strcasecmp(substr($haystack, 0, strlen($needle)),$needle)===0);
}

function endsWith($haystack,$needle,$case=false) {
    if($case){return (strcmp(substr($haystack, strlen($haystack) - strlen($needle)),$needle)===0);}
    return (strcasecmp(substr($haystack, strlen($haystack) - strlen($needle)),$needle)===0);
}
?>
