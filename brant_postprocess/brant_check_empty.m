function brant_check_empty(check_item, errstr)

if isempty(check_item)
    error(sprintf(errstr)); %#ok<SPERR>
end