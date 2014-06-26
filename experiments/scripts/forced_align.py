

import argparse
from subprocess import call
import os
import errno
from textgrid import *


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


if __name__ == "__main__":

    # command line arguments
    parser = argparse.ArgumentParser("Given a WAV file and its phonetic content, this script generates a TextGrid "
                                     "with a tier called \"Forced Alignment\" that has the phonemes aligned with the "
                                     "speech of the WAV.")
    parser.add_argument("wav_filename", help="input WAV file name")
    parser.add_argument("phonemes_filename", help="list of phoneme to align")
    parser.add_argument("outout_textgrid", help="output TextGrid file name")
    parser.add_argument("--debug", dest='debug_mode', help="extra verbosity", action='store_true')
    args = parser.parse_args()

    # data and temp directory
    data_directory = "data"

   # clean filename from its path
    stem = os.path.basename(args.wav_filename)

    # and its extension
    stem = os.path.splitext(stem)[0]

    # the path of the stem name
    stem_path = "%s/%s/%s" % (data_directory, stem, stem)

    # create a directory for
    mkdir_p(stem_path)

    mfc_filename = "%s.mfc" % stem_path
    mfc_filelist = "%s.mfc_filelist" % stem_path
    with open(mfc_filelist, 'w') as f:
        f.write(mfc_filename)

    dist_filename = "%s.dist" % stem_path
    dist_filelist = "%s.dist_filelist" % stem_path
    with open(dist_filelist, 'w') as f:
        f.write(dist_filename)

    scores_filename = "%s.scores" % stem_path
    scores_filelist = "%s.scores_filelist" % stem_path
    with open(scores_filelist, 'w') as f:
        f.write(scores_filename)

    # extract MFCC features
    easy_call("packages/htk/HCopy -C config/wav_htk.config %s %s" % (args.wav_filename, mfc_filename), args.debug_mode)

    # compute MFCC distance feature
    easy_call("packages/forced_alignment/bin/htk_ceps_dist %s config/timit_mfcc.stats %s" % (mfc_filename,
                                                                                             dist_filename),
              args.debug_mode)

    # frame-base phoneme classifier parameters
    sigma = "4.3589"
    C = "1"
    B = "0.8"
    epochs = "1"
    pad = "1"
    ##JK epochs = "3"
    ##JK pad = "5"
    # model filename
    phoneme_frame_based_model = "models/phoeneme_frame_based.pa1.C_%s.B_%s.sigma_%s.pad_%s.epochs_%s.model" % \
                                (C, B, sigma, pad, epochs)
    easy_call("packages/forced_alignment/bin/PhonemeFrameBasedDecode -n %s -kernel_expansion rbf3 -sigma %s "
              "-mfcc_stats config/timit_mfcc.stats -averaging -scores %s %s null config/phonemes_39 %s "
              "> %s.phoneme_classifier_log" % (pad, sigma, scores_filelist, mfc_filelist, phoneme_frame_based_model, 
                stem_path), args.debug_mode)

    # forced-aligned classifier parameters\
    beta1 = "0.01"
    beta2 = "1.0"
    beta3 = "1.0"
    min_sqrt_gamma = "1.0"
    loss = "tau_insensitive_loss"
    eps = "1.1"
    forced_alignment_model = "models/forced_alignment.beta1_%s.beta2_%s.beta3_%s.gamma_%s.eps_%s.%s.model" % \
                             (beta1, beta2, beta3, min_sqrt_gamma, eps, loss)
    pred_align_filelist = "%s.pred_align_filelist" % stem_path
    with open(pred_align_filelist, 'w') as f:
        f.write(args.outout_textgrid)

    phonemes_filename = "%s.phonemes" % stem_path
    phonemes_filelist = "%s.phonemes_filelist" % stem_path
    with open(phonemes_filelist, 'w') as f:
        f.write(phonemes_filename)

    # remove the signed * from the phonemes
    phonemes_file = open(phonemes_filename, 'w')
    phonemes_file_with_sign = open(args.phonemes_filename)
    for line in phonemes_file_with_sign:
        phonemes_file.write(line.rstrip().replace("*", ""))
    phonemes_file.close()
    phonemes_file_with_sign.close()

    easy_call("packages/forced_alignment/bin/ForcedAlignmentDecode -beta1 %s -beta2 %s -beta3 %s "
              "-output_textgrid %s %s %s %s null config/phonemes_39 config/phonemes_39.stats %s "
              "> %s.forced_alignment_log" % (beta1, beta2, beta3, pred_align_filelist, scores_filelist,
                                             dist_filelist, phonemes_filelist, forced_alignment_model, stem_path),
              args.debug_mode)

    ## the code now handle the addition of the phonemes signed with *

    # first read the original phoneme file
    phonemes = list()
    with open(args.phonemes_filename) as f:
        for line in f:
            phonemes += line.rstrip().split()

    # read the textgrid tier called "Forced Alignment"
    textgrid = TextGrid()
    textgrid.read(args.outout_textgrid)
    tier_names = textgrid.tierNames()
    if "Forced Alignment" in tier_names:
        tier_index = tier_names.index("Forced Alignment")
        # print all its interval, which has some value in their description (mark)
        for i, interval in enumerate(textgrid[tier_index]):
            if textgrid[tier_index][i].mark() != '':
                textgrid[tier_index][i]._Interval__mark = phonemes[i]
        textgrid.write(args.outout_textgrid)
    else:
        print "Error: the tier 'Forced Alignment' was not found in %s" % args.textgrid_filename
