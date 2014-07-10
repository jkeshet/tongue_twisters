
import argparse
from os.path import basename, splitext
import sys

if __name__ == "__main__":

    # command line arguments
    parser = argparse.ArgumentParser(description="This utility find the phoneme string from a name of a file.")
    parser.add_argument("filename", help="name of a file to process")
    parser.add_argument("--begin", help="from num. repetitions", default=12, type=int)
    parser.add_argument("--end", help="to num. repetitions", default=12, type=int)
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

    # clean filename from its path
    wav_filename = basename(args.filename)

    # and its extension
    wav_filename = splitext(wav_filename)[0]

    # remove the first 4 characters at the beginning (subjID '001-'') and the last character at the end
    wav_filename = wav_filename[4:-1]

    if wav_filename in filename2pattern:

        # load string
        pattern_string = filename2pattern[wav_filename]
        pattern_string = pattern_string.rstrip()

        # split into sub-strings
        sub_patterns = pattern_string.split(",")[1:]

        # convert each substring into phonemes
        sub_patterns_phonemes = list()
        for sub_pattern in sub_patterns:
            phonemes = sub_pattern.split(".")
            sub_patterns_phonemes.append(phonemes)
        if args.debug_mode:
            print >> sys.stderr, sub_patterns_phonemes

        for num_reps in xrange(args.begin, args.end+1):
            # generate a string with num_reps repetitions
            new_pattern_string = ""
            for i in xrange(num_reps):
                pattern_id = i % 4
                for j, p in enumerate(sub_patterns_phonemes[pattern_id]):
                    if j == 0:
                        new_pattern_string += "SIL *%s " % p
                    elif p in other_plosives and sub_patterns_phonemes[pattern_id][j - 1] not in nasals_and_liquids:
                        new_pattern_string += "SIL %s " % p
                    else:
                        new_pattern_string += "%s " % p
            new_pattern_string += "SIL"

            # convert phoneme to lowercase and print
            print new_pattern_string.lower()

    else:

        print >> sys.stderr, "Error: unable to find phoneme mapping to %s (shortened to %s) in %s" % \
                             (args.filename, wav_filename, pattern_mapping_file)
