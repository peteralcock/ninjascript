from pydub import AudioSegment, silence
from moviepy.editor import VideoFileClip, concatenate_videoclips
import os

# Function to detect non-silent segments in audio
def detect_non_silent_segments(audio_path, min_silence_len=500, silence_thresh=-40):
    audio = AudioSegment.from_file(audio_path)
    non_silent_ranges = silence.detect_nonsilent(audio, min_silence_len=min_silence_len, silence_thresh=silence_thresh)
    
    # Convert from milliseconds to seconds
    non_silent_ranges = [(start / 1000, end / 1000) for start, end in non_silent_ranges]
    return non_silent_ranges

# Function to remove silent parts from video
def remove_silence_from_video(video_path, output_path, min_silence_len=500, silence_thresh=-40):
    # Extract audio from video
    temp_audio_path = "temp_audio.wav"
    video_clip = VideoFileClip(video_path)
    video_clip.audio.write_audiofile(temp_audio_path, logger=None)
    
    # Detect non-silent segments
    non_silent_segments = detect_non_silent_segments(temp_audio_path, min_silence_len, silence_thresh)
    
    # Cut non-silent parts from video
    clips = [video_clip.subclip(start, end) for start, end in non_silent_segments]
    final_clip = concatenate_videoclips(clips)
    
    # Write the final video
    final_clip.write_videofile(output_path, codec="libx264", audio_codec="aac")
    
    # Cleanup temporary audio file
    os.remove(temp_audio_path)

# Example usage
video_path = "savetheshrimp.mp4"  # Replace with your input video path
output_path = "output_video_no_pauses.mp4"

remove_silence_from_video(video_path, output_path, min_silence_len=700, silence_thresh=-35)
