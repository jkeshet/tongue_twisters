
import argparse
import wave

if __name__ == "__main__":

    # command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("input_wav", help="input WAV file name")
    parser.add_argument("output_wav", help="output WAV file name")
    parser.add_argument("start_time", help="start time")
    parser.add_argument("end_time", help="end time")
    args = parser.parse_args()

    wav_in_file = wave.Wave_read(args.input_wav)
    wav_in_num_samples = wav_in_file.getnframes()
    wav_out_file = wave.Wave_write(args.output_wav)
    wav_out_file.setparams((wav_in_file.getnchannels(), wav_in_file.getsampwidth(), wav_in_file.getframerate(),
                            float(args.end_time)-float(args.start_time)+1, 'NONE', 'noncompressed'))
    start_sample = int(float(args.start_time)*wav_in_file.getframerate())
    end_sample = int(float(args.end_time)*wav_in_file.getframerate())
    for i in range(0, wav_in_num_samples):
        samples = wav_in_file.readframes(1)
        if start_sample <= i <= end_sample:
            wav_out_file.writeframes(samples)
            #samples_unpacked = struct.unpack("<h", samples)
            #print i, int(samples_unpacked[0])
    wav_in_file.close()
    wav_out_file.close()


