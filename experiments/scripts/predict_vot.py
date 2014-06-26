
import argparse
from subprocess import call
import os
import csv


def easy_call(command, debug_mode=False):
    try:
        if debug_mode:
            print command
        call(command, shell=True)
    except Exception as exception:
        print "Error: could not execute the following"
        print ">>", command
        print type(exception)     # the exception instance
        print exception.args      # arguments stored in .args
        exit(-1)


if __name__ == "__main__":

    # command line arguments
    parser = argparse.ArgumentParser("Predicts VOT of stops in a WAV file and a corresponding TextGrid that "
                                     "has a tier containing windows to be searched as possible starts of the "
                                     "predicted VOT.")
    parser.add_argument("wav_filename", help="input WAV file name")
    parser.add_argument("textgrid", help="list of phoneme to align")
    parser.add_argument("--debug", dest='debug_mode', help="extra verbosity", action='store_true')
    args = parser.parse_args()

    # data and temp directory
    data_directory = "data"

   # clean filename from its path
    stem = os.path.basename(args.wav_filename)

    # and its extension
    stem = os.path.splitext(stem)[0]

    preds_csv_filename = "%s/%s.csv" % (data_directory, stem)
    vot_classifier_model = 'models/vot_amanda.classifier'
    easy_call("auto_vot_decode.py --min_vot_length 5 --max_vot_length 500 --window_tier 'Processing Window' "
              "%s %s %s  --csv_file %s" % (args.wav_filename, args.textgrid, vot_classifier_model, preds_csv_filename))

    # read CSV file and output the results as a single line
    with open(preds_csv_filename, 'r') as preds_csv_file:
        header_read = False
        for row in preds_csv_file:
            if not header_read:
                header_read = True
                continue
            filename, xmin, vot, confidence = row.rstrip().split(",")
            print "%s, %s," % (confidence, vot),