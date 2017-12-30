import string


def clean_chars(chars):
    valid_chars = "-_.() %s%s" % (string.ascii_letters, string.digits)
    return ''.join(c for c in chars if c in valid_chars)