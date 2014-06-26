
import argparse
from textgrid import *

if __name__ == "__main__":

    # command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("textgrid_filename", help="input TextGrid file name")
    parser.add_argument("labels_filename", help="output PHN file name")
    parser.add_argument("--frame_rate", help="frame rate in sec", default=0.010)
    args = parser.parse_args()

    textgrid = TextGrid()
    textgrid.read(args.textgrid_filename)
    num_frames = int(textgrid.xmax()/float(args.frame_rate))
    #print num_frames
    
    out_file = open(args.labels_filename, "w")    

    interval = 0
    t = 0.0
    while t < num_frames:
        # in some cases the first interval does not start exactly at zero
        if interval == 0 and t == 0.0:
            if 0.0 <= t < textgrid[0][interval].xmax():
                if textgrid[0][interval].mark() == "":
                    #print t, interval, "-"
                    print >>out_file, "-"
                else:
                    #print t, interval, textgrid[0][interval].mark()
                    print >>out_file, textgrid[0][interval].mark()
                t += float(args.frame_rate)
        elif textgrid[0][interval].xmin() <= t < textgrid[0][interval].xmax():
            if textgrid[0][interval].mark() == "":
                #print t, interval, "-"
                print >>out_file, "-"
            else:
                #print t, interval, textgrid[0][interval].mark()
                print >>out_file, textgrid[0][interval].mark()
            t += float(args.frame_rate)
        elif t >= textgrid[0][interval].xmax():
            if interval < len(textgrid[0])-1:
                interval += 1
            else:
                break

    out_file.close()