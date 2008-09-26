
import com.myronmarston.music.*;
import com.myronmarston.music.settings.*;
import com.myronmarston.music.scales.*;
import com.myronmarston.music.transformers.*;
import com.myronmarston.util.Fraction;

import java.util.*;

public class GenerateExamples
{
    public static void main(String[] args) throws Exception {        
        FractalPiece fp = new FractalPiece();
        fp.setTempo(90);
        fp.setTimeSignature(new TimeSignature(3, 4));
        fp.setScale(new MajorScale(NoteName.F));
        //fp.setGermString("E4 F#4,1/8,F G#4,MF E4,1/4");                       
        fp.setGermString("F4 G4,1/8,F A4,MF F4,1/4");                       
        HashMap<String, NoteList> hm = new java.util.HashMap<String, NoteList>();
        
        hm.put("germ", fp.getGerm());
        
        hm.put("inversion", new InversionTransformer().transform(fp.getGerm()));
        hm.put("retrograde", new RetrogradeTransformer().transform(fp.getGerm()));
        
        hm.put("octave_adjustment_pos_2", new OctaveTransformer(2).transform(fp.getGerm()));
        hm.put("octave_adjustment_neg_1", new OctaveTransformer(-1).transform(fp.getGerm()));
        
        hm.put("rhythm_scale_factor_half", new RhythmicDurationTransformer(new Fraction(1, 2)).transform(fp.getGerm()));
        hm.put("rhythm_scale_factor_2", new RhythmicDurationTransformer(new Fraction(2, 1)).transform(fp.getGerm()));
        
        hm.put("scale_step_offset_pos_2", new TransposeTransformer(2, 2).transform(fp.getGerm()));
        hm.put("scale_step_offset_neg_1", new TransposeTransformer(-1, -1).transform(fp.getGerm()));        
        
        hm.put("volume_adjustment_pos_half", new VolumeTransformer(new Fraction(1, 2)).transform(fp.getGerm()));
        hm.put("volume_adjustment_neg_half", new VolumeTransformer(new Fraction(-1, 2)).transform(fp.getGerm()));        
        
        hm.put("self_similarity_pitch", new SelfSimilarityTransformer(true, false, false, 1).transform(fp.getGerm()));
        hm.put("self_similarity_pitch_rhythm_volume", new SelfSimilarityTransformer(true, true, true, 1).transform(fp.getGerm()));
        hm.put("self_similarity_rhythm", new SelfSimilarityTransformer(false, true, false, 1).transform(fp.getGerm()));
        
        hm.put("self_similarity_iterations_1", new SelfSimilarityTransformer(true, true, false, 1).transform(fp.getGerm()));
        hm.put("self_similarity_iterations_2", new SelfSimilarityTransformer(true, true, false, 2).transform(fp.getGerm()));
        hm.put("self_similarity_iterations_3", new SelfSimilarityTransformer(true, true, false, 3).transform(fp.getGerm()));        
        
        for (Map.Entry<String, NoteList> e : hm.entrySet()) {
            OutputManager om = new OutputManager(fp, Arrays.asList(e.getValue()), false, false);            
            om.savePngFile("examples/" + e.getKey() + ".png", 700);
            om.saveMp3File("examples/" + e.getKey() + ".mp3");
        }
    }
}