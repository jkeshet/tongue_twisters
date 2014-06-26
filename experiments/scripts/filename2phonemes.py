
import argparse
from os.path import basename, splitext
import sys

if __name__ == "__main__":

    # command line arguments
    parser = argparse.ArgumentParser(description="This utility find the phoneme string from a name of a file.")
    parser.add_argument("filename", help="name of a file to process")
    parser.add_argument("--debug", dest='debug_mode', help="extra verbosity", action='store_true')
    args = parser.parse_args()

    # variales used
    pattern_mapping_file = "config/Script-phon.csv"
    other_plosives = ['B', 'D', 'G', 'K', 'P', 'T']
    start_plosives = ['*B', '*D', '*G', '*K', '*P', '*T']
    nasals_and_liquids = ['NG', 'N', 'M', 'L', 'R']

    # read filename to patter mapping
    filename2pattern = dict()
    with open(pattern_mapping_file) as mapping_file:
        for row in mapping_file:
            [filename, pattern] = row.rstrip().split(",", 1)
            filename2pattern[filename] = "," + pattern
            #print filename, "<->", filename2pattern[filename]

    # clean filename from its path
    pfilename = basename(args.filename)

    # and its extension
    pfilename = splitext(pfilename)[0]

    # remove the first 4 characters at the beginning (subjID '001-'') and the last character at the end
    pfilename = pfilename[4:-1]

    if pfilename in filename2pattern:
        pstring = filename2pattern[pfilename]
        pstring = pstring.replace(",", " *")
        pstring = pstring.replace(".", " ")
        pstring = pstring.lstrip()
        if args.debug_mode:
            print >> sys.stderr, "/%s/" % pstring

        # add closure to some of the plosives
        new_pstring = ""
        phonemes = pstring.split(" ")
        for i, phoneme in enumerate(phonemes):
            if i == 0:
                new_pstring = "SIL %s " % phoneme
            elif phoneme in start_plosives:
                new_pstring += "SIL %s " % phoneme
            elif phoneme in other_plosives and phonemes[i - 1] not in nasals_and_liquids:
                new_pstring += "SIL %s " % phoneme
            else:
                new_pstring += "%s " % phoneme

        # convert phoneme to lowercase
        pstring = new_pstring.lower()

        # multiply by 3 and add /sil/ at the end
        print "%s %s %s sil" % (pstring, pstring, pstring)
    else:
        print >> sys.stderr, "Error: unable to find phoneme mapping to %s (shortened to %s) in %s" % \
                             (args.filename, pfilename, pattern_mapping_file)
