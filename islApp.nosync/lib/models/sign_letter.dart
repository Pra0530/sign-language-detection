class SignLetter {
  final String letter;
  final String description;
  final String hint;
  final int index;

  const SignLetter({
    required this.letter,
    required this.description,
    required this.hint,
    required this.index,
  });

  static const List<SignLetter> alphabet = [
    SignLetter(letter: 'A', description: 'Closed fist with thumb on the side', hint: 'Make a fist, thumb resting on fingers', index: 0),
    SignLetter(letter: 'B', description: 'Flat hand, fingers together, thumb across palm', hint: 'Open palm, thumb tucked in', index: 1),
    SignLetter(letter: 'C', description: 'Curved hand forming C shape', hint: 'Cup your hand like holding a ball', index: 2),
    SignLetter(letter: 'D', description: 'Index finger up, others curled touching thumb', hint: 'Point up, circle with other fingers', index: 3),
    SignLetter(letter: 'E', description: 'All fingers curled, thumb across front', hint: 'Curl all fingers down', index: 4),
    SignLetter(letter: 'F', description: 'Thumb and index touch, others extended', hint: 'OK sign with three fingers up', index: 5),
    SignLetter(letter: 'G', description: 'Index finger and thumb pointing sideways', hint: 'Point sideways with thumb and index', index: 6),
    SignLetter(letter: 'H', description: 'Index and middle finger extended sideways', hint: 'Two fingers pointing sideways', index: 7),
    SignLetter(letter: 'I', description: 'Pinky finger extended, others closed', hint: 'Raise only your pinky', index: 8),
    SignLetter(letter: 'J', description: 'Pinky traces J shape in air', hint: 'Draw J with your pinky', index: 9),
    SignLetter(letter: 'K', description: 'Index and middle up, thumb between them', hint: 'Peace sign with thumb between', index: 10),
    SignLetter(letter: 'L', description: 'L shape with thumb and index finger', hint: 'Make an L with thumb and index', index: 11),
    SignLetter(letter: 'M', description: 'Three fingers over thumb, fist', hint: 'Tuck thumb under three fingers', index: 12),
    SignLetter(letter: 'N', description: 'Two fingers over thumb, fist', hint: 'Tuck thumb under two fingers', index: 13),
    SignLetter(letter: 'O', description: 'Fingers and thumb form O shape', hint: 'Touch all fingertips to thumb', index: 14),
    SignLetter(letter: 'P', description: 'K hand pointed downward', hint: 'Like K but pointing down', index: 15),
    SignLetter(letter: 'Q', description: 'G hand pointed downward', hint: 'Like G but pointing down', index: 16),
    SignLetter(letter: 'R', description: 'Crossed index and middle finger', hint: 'Cross your fingers', index: 17),
    SignLetter(letter: 'S', description: 'Fist with thumb over fingers', hint: 'Make a fist, thumb in front', index: 18),
    SignLetter(letter: 'T', description: 'Thumb between index and middle', hint: 'Tuck thumb between first two fingers', index: 19),
    SignLetter(letter: 'U', description: 'Index and middle together, pointing up', hint: 'Two fingers up, together', index: 20),
    SignLetter(letter: 'V', description: 'Index and middle apart, V shape', hint: 'Peace/Victory sign', index: 21),
    SignLetter(letter: 'W', description: 'Three fingers up and apart', hint: 'Three fingers spread upward', index: 22),
    SignLetter(letter: 'X', description: 'Index finger hooked', hint: 'Hook your index finger', index: 23),
    SignLetter(letter: 'Y', description: 'Thumb and pinky extended', hint: 'Hang loose / shaka sign', index: 24),
    SignLetter(letter: 'Z', description: 'Index finger traces Z in air', hint: 'Draw Z with index finger', index: 25),
  ];
}
