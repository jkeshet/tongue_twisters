
import argparse
import os
import errno
import shutil
import wave
import sys
from subprocess import call

import filename2phonemes
import forced_align
import locate_processing_windows
import alignment_confidence
import predict_vot


def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise


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


def alignment_score(wav16_filename, phonemes_filename, textgrid_filename, num_repetitions, debug_mode):

    # find the template transciption
    filename2phonemes.main(wav16_filename, phonemes_filename, num_repetitions, num_repetitions, debug_mode)

    # forced align the trascription against the WAV file
    textgrid_filename = "%s.%d" % (textgrid_filename, num_repetitions)
    conf = forced_align.main(wav16_filename, phonemes_filename, textgrid_filename, debug_mode)

    # located processing windows based on the forced alignement
    locate_processing_windows.main(textgrid_filename, debug_mode)

    # check the alignment confidence
    score = alignment_confidence.main(textgrid_filename, debug_mode)

    return score, conf


if __name__ == "__main__":

    # command line arguments
    parser = argparse.ArgumentParser("Predicts VOT of stops in a WAV file. The WAV file name has a pattern that "
                                     "defines the what is pronounced.")
    parser.add_argument("wav_filename", help="input WAV file name")
    parser.add_argument("--debug", dest='debug_mode', help="extra verbosity", action='store_true')
    args = parser.parse_args()

    if not os.path.isfile(args.wav_filename):
        print "Error: cannot find WAV file", args.wav_filename
        exit()

    # define filenames
    basename = os.path.splitext(os.path.basename(args.wav_filename))[0]
    wav16_filename = "data/%s.wav" % basename
    textgrid_filename = "data/%s.TextGrid" % basename
    phonemes_filename = "data/%s.phonemes" % basename
    best_alignment_filename = "data/%s.best_alignment" % basename

    # make dir data, if does not exist
    mkdir_p("data")
    if args.wav_filename != ("data/%s.wav" % basename):
        shutil.copy2(args.wav_filename, "data/%s.wav" % basename)

    # converts WAV to 16kHz
    wav_file = wave.open(args.wav_filename)
    if wav_file.getframerate() != 16000:
        if args.debug_mode:
            print >>sys.stderr, "Info: calling sox since rate is not 16kHz"
            easy_call("packages/sox/sox %s -c 1 -r 16000 %s" % (args.wav_filename, wav16_filename))
    else:
        wav16_filename = args.wav_filename

    # get alignment score of standard 12 repetitions
    num_reps = 12
    print >>sys.stderr, "Info: running alignment with %d repetitions" % num_reps
    (min_score, arg_min_conf) = alignment_score(wav16_filename, phonemes_filename, textgrid_filename, num_reps,
                                                args.debug_mode)
    print >>sys.stderr, "Info: score= %f conf= %f" % (min_score, arg_min_conf)
    arg_min_score = num_reps
    if min_score > 0.0035:
        # find best alignment for number of repetitions between 7 and 16
        for num_reps in range(7, 16+1):
            print >>sys.stderr, "Info: running alignment with %d repetitions" % num_reps
            (score, conf) = alignment_score(wav16_filename, phonemes_filename, textgrid_filename, num_reps,
                                            args.debug_mode)
            print >>sys.stderr, "Info: score= %f conf= %f" % (score, conf)
            if score < min_score:
                min_score = score
                arg_min_score = num_reps
                arg_min_conf = conf
        print >>sys.stderr, "Info: the best alignment found for %d patterns." % arg_min_score
    shutil.copy2("%s.%d" % (textgrid_filename, arg_min_score), textgrid_filename)

    # predict location of VOT based on the forced aligned stop consonants
    predicted_vots = predict_vot.main(wav16_filename, textgrid_filename, args.debug_mode)

    # generates a log file
    print "%s, %f, %f, %s" % (basename, arg_min_conf, min_score, predicted_vots)

    if args.debug_mode:
        shutil.rmtree('data/%s/' % basename)
