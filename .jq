def decode_ddb:
    def _prop($key): select(has($key))[$key];
       ((objects | { value: _prop("S") })                           # string (from string)
    // (objects | { value: _prop("B") })                            # blob (from string)
    // (objects | { value: _prop("N") | tonumber })                 # number (from string)
    // (objects | { value: _prop("BOOL") })                         # boolean (from boolean)
    // (objects | { value: _prop("M") | map_values(decode_ddb) })   # map (from object)
    // (objects | { value: _prop("L") | map(decode_ddb) })          # list (from encoded array)
    // (objects | { value: _prop("SS") })                           # string set (from string array)
    // (objects | { value: _prop("NS") | map(tonumber) })           # number set (from string array)
    // (objects | { value: _prop("BS") })                           # blob set (from string array)
    // (objects | { value: map_values(decode_ddb) })                # all other non-conforming objects
    // (arrays | { value: map(decode_ddb) })                        # all other non-conforming arrays
    // { value: . }).value                                          # everything else
    ;

def tocsv($x):
    $x
    |(map(keys)
        |add
        |unique
        |sort
    ) as $cols
    |map(. as $row
        |$cols
        |map($row[.]|tostring)
    ) as $rows
    |$cols,$rows[]
    | @csv;
