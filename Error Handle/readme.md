To get all error lines like a restore terminated by an error but if you allow the error_message() it will only get you the last error message because it's a scaler function.

but now you can handle these errors by creating an extended event to capture all events and error messages and then reading the XML and converting it back to a table-valued function.

like your error for restoring because you don't have sufficient space on some disks.
