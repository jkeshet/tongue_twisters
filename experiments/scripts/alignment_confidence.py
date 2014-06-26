
import argparse
from textgrid import *

if __name__ == "__main__":

    # command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("textgrid_filename", help="TextGrid to be examined")
    args = parser.parse_args()

    tier_name = "Processing Window"
    textgrid = TextGrid()

    # read TextGrid
    textgrid.read(args.textgrid_filename)

    # extract tier names
    tier_names = textgrid.tierNames()

    # check if the tier name is in the TextGrid
    windows_centers = list()
    if tier_name in tier_names:
        tier_index = tier_names.index(tier_name)
        # print all its interval, which has some value in their description (mark)
        for interval in textgrid[tier_index]:
            if interval.mark() != '':
                window_center = (interval.xmax()-interval.xmin())/2.0 + interval.xmin()
                ##print interval.xmin(), interval.xmax(), window_center, interval.mark()
                windows_centers.append(window_center)
    else:
        print "The tier '%s' is not found in %s" % (args.tier_name, args.textgrid_filename)
    ##print "----"

    # after we have the centers of the processing window we compute the average distance between adjacent window
    # centers
    average_windows_distance = 0
    for i in range(1, len(windows_centers)):
        window_distance = windows_centers[i]-windows_centers[i-1]
        ##print windows_centers[i], "-", windows_centers[i-1], "=", window_distance
        average_windows_distance = average_windows_distance + window_distance
    average_windows_distance /= len(windows_centers)-1
    ##print "average_windows_distance=", average_windows_distance
    ##print "----"

    # now compute the mse
    mse = 0
    for i in range(1, len(windows_centers)):
        window_distance = windows_centers[i]-windows_centers[i-1]
        mse += (window_distance - average_windows_distance)*(window_distance - average_windows_distance)
        ##print (window_distance - average_windows_distance)*(window_distance - average_windows_distance)
    mse /= len(windows_centers)-1
    print mse