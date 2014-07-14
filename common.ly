%% Common stuff to include in each src_block
%% extracted from /openbook/src/include/common.makoi
%% at https://github.com/veltzer/openbook

  \version "2.18.2"
  \paper{
    between-system-padding = 2\mm
    oddFooterMarkup = \markup {}
    scoreTitleMarkup = \markup {}
    bookTitleMarkup = \markup {}
    % indent=0\mm
    % line-width=170\mm
    % oddFooterMarkup=##f
    % oddHeaderMarkup=##f
    % bookTitleMarkup=##f
    % scoreTitleMarkup=##f
  }
  \layout {
  indent = 0.0 \cm
  \context {
         \Score
		%% change the size of the text fonts
		%%\override LyricText #'font-family = #'typewriter
		\override LyricText #'font-size = #'-2

		%% set the style of the chords to Jazz - I don't see
		%% this making any effect
		\override ChordName #'style = #'jazz
		%%\override ChordName #'word-space = #2

		%% set the chord size and font
		%%\override ChordName #'font-series = #'bold
		%%\override ChordName #'font-family = #'roman
		%%\override ChordName #'font-size = #-1

		%% don't show bar numbers (for jazz it makes it too
		%% cluttery)
		\remove "Bar_number_engraver"
	}
   }

#(set-global-staff-size 17.82)

  %% chord related matters
  myChordDefinitions={
    <c ees ges bes des' fes' aes'>-\markup \super {7alt}
    <c e g bes f'>-\markup \super {7sus}
  }
  myChordExceptions=#(append
                      (sequential-music-to-chord-exceptions
		         myChordDefinitions #t)
                      ignatzekExceptions
                    )

  %% some macros to be reused all over
  %% ============================================
  myBreak=\break
  %% do line breaks really matter?
  myEndLine=\break
  %%myEndLine={}
  myEndLineVoltaNotLast={}
  myEndLineVoltaLast=\break
  partBar=\bar "||"
  endBar=\bar "|."
  startBar=\bar ".|"
  startRepeat=\bar "|:"
  endRepeat=\bar ":|"
  startTune={}
  endTune=\bar "|."
  myFakeEndLine={}

  %% this is a macro that * really * breaks lines. You don't really
  %% need this since a regular \break will work AS LONG AS you have
  %% the '\remove Bar_engraver' enabled...
  hardBreak={ \bar "" \break }

  %% a macro to make vertical space
  verticalSpace=\markup { \null }

  %% some macros for marking parts of jazz tunes
  %% ===========================================
  startSong={}
  endSong=\bar "|."
  startPart={}
  endPart=\bar "||"
  startIntro=\mark "Intro"
  endIntro={}
  startChords={
    %% this causes chords that do not change to disappear...
    \set chordChanges = ##t
    %% use my own chord exceptions
    \set chordNameExceptions = #myChordExceptions
  }
  endChords={}
  %% lets always include guitar definitions
  \include "predefined-guitar-fretboards.ly"
