
import argparse
from textgrid import *
from scipy.ndimage.filters import median_filter


def argmax(array):
    return max(enumerate(array), key=lambda x: x[1])[0]


if __name__ == "__main__":

    # command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("scores_filename", help="input scores file name")
    parser.add_argument("textgrid_filename", help="output TextGrid file name")
    parser.add_argument("--debug", help="verbose printing", action='store_const', const=True, default=False)
    parser.add_argument("--frame_rate", help="frame rate in sec", default=0.010)
    parser.add_argument("--post_smoothing", help="final smoothing", action='store_const', const=True, default=False)
    args = parser.parse_args()

    # load matrix of scores matrix and build phoneme vector
    scores_file = open(args.scores_filename)
    header_read = False
    current_frame = 0
    phonemes = list()
    for line in scores_file:
        line.rstrip()
        if not header_read:
            header_read = True
        else:
            scores = map(float, line.split())
            phonemes.append(argmax(scores))

    # smoothing
    phonemes_smoothed = list()
    if args.post_smoothing:
        phonemes_smoothed = median_filter(phonemes, 100)
        if args.debug:
            for (p, q) in zip(phonemes, phonemes_smoothed):
                print p, q
    else:
        phonemes_smoothed = phonemes

    # contract frame sequence of phonemes
    phonemes_contracted = list()
    prev_p = -1
    prev_start_frame = 0
    current_frame = 0
    for p in phonemes_smoothed:
        if p != prev_p:
            if prev_p != -1:
                phonemes_contracted.append((prev_p, prev_start_frame, current_frame))
            prev_p = p
            prev_start_frame = current_frame
        current_frame += 1
    phonemes_contracted.append((prev_p, prev_start_frame, current_frame))

    if args.debug:
        print phonemes_contracted

    # find the longest interval
    len_max = 0
    p_max = ()
    for p in phonemes_contracted:
        len_p = p[2] - p[1]
        if len_p > len_max and p[0] > 0:
            len_max = len_p
            p_max = p
    if args.debug:
        print "longest interval -->", p_max, len_max

    # build TextGrid, if needed
    if args.textgrid_filename:
        textgrid = TextGrid()
        vad_tier = IntervalTier(name='VAD', xmin=0.0, xmax=len(phonemes)*float(args.frame_rate))
        for i in range(len(phonemes_contracted)):
            vad_tier.append(
                Interval(phonemes_contracted[i][1]*float(args.frame_rate),
                         phonemes_contracted[i][2]*float(args.frame_rate),
                         phonemes_contracted[i][0]))
        textgrid.append(vad_tier)
        textgrid.write(args.textgrid_filename)