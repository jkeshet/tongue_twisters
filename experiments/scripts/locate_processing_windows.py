
import argparse
from textgrid import *


def main(args_textgrid, debug_mode):

    # read the whole input text grid
    textgrid = TextGrid()
    textgrid.read(args_textgrid)
    tier_names = textgrid.tierNames()

    # generate "Processing Window" tier by processing the
    window_xmin = list()
    window_xmax = list()
    window_mark = list()
    if "Forced Alignment" in tier_names:
        tier_index = tier_names.index("Forced Alignment")
        # print all its interval, which has some value in their description (mark)
        for (i, interval) in enumerate(textgrid[tier_index]):
            if "*" in interval.mark():
                # define processing window
                window_xmin.append(textgrid[tier_index][i-1].xmin() +
                                0.2*(textgrid[tier_index][i-1].xmax()-textgrid[tier_index][i-1].xmin()))
                window_xmax.append(min((textgrid[tier_index][i].xmax() + 0.1, textgrid.xmax())))
                window_mark.append(i)
                current = len(window_xmin)-1
                previous = current-1
                # fix window of prev phoneme: if the right boundary of prev window is greater than the left boundary
                # of the current window, then fix the window
                if current >= 1 and window_xmin[current] < window_xmax[previous]:
                    window_xmax[previous] = window_xmin[current]
                    if debug_mode:
                        print "fixing--> %f %f %s" % (window_xmin[previous], window_xmax[previous], window_mark[previous])
    else:
        print "Error: the tier 'Forced Alignment' was not found in %s" % args_textgrid_filename

    # prepare TextGrid
    window_tier = IntervalTier(name='Processing Window', xmin=0.0, xmax=textgrid.xmax())
    window_tier.append(Interval(textgrid.xmin(), window_xmin[0], ''))
    for i in xrange(0, len(window_xmin)-1):
        window_tier.append(Interval(window_xmin[i], window_xmax[i], window_mark[i]))
        window_tier.append(Interval(window_xmax[i], window_xmin[i+1], ''))
    window_tier.append(Interval(window_xmin[-1], window_xmax[-1], window_mark[-1]))
    window_tier.append(Interval(window_xmax[-1], textgrid.xmax(), ''))

    if debug_mode:
        for interval in window_tier:
            if interval.mark():
                print interval.xmin(), interval.xmax(), interval.xmax()-interval.xmin(), interval.mark()

    textgrid.append(window_tier)
    textgrid.write(args_textgrid)


if __name__ == "__main__":

    # command line arguments
    parser = argparse.ArgumentParser("This utility adds a tier to the input TextGrid file which contains the "
                                     "processing window used by the VOT predictor. This utility assumes that the "
                                     "TextGrid contains a tier called \"Forced Alignment\", and locates the "
                                     "processing windows around the phonemes labels that contain a * sign (like /*b/).")
    parser.add_argument("textgrid", help="TextGrid file name")
    parser.add_argument("--debug", dest='debug_mode', help="extra verbosity", action='store_true')
    args = parser.parse_args()
    main(args.textgrid, args.debug_mode)
