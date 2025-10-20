# QList

simple data format that is parsed to a hashmap\
the Q is short for quick because the format is supposed to be quick/easy to write and parse

```qlist
/ comment
i my_int 100
f my_float 10.0
s my_str hello
b my_bool t
```

## format

> [!NOTE]
> the type, name and value are seperated with spaces\
> and the value goes from the end of the name to the end of line

the type of a field is at the front so the parser can easily tell the type or if a line is a comment with a single switch statement
