import string


def clean_chars(chars, add_chars="-_.() "):
    valid_chars = add_chars + "%s%s" % (string.ascii_letters, string.digits)
    return ''.join(c for c in chars if c in valid_chars)


def filter_dictionary(dictlist, keysdict):
    return {elem: {keysdict[k]: v for k, v in value.items() if k in keysdict}
            for elem, value in dictlist.items()}


