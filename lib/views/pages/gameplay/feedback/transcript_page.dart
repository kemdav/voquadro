import 'package:flutter/material.dart';

class TranscriptPage extends StatelessWidget {
  const TranscriptPage({
    super.key,
    required this.cardBackground,
    required this.primaryPurple,
    required this.transcript, // Add transcript parameter
  });

  final Color cardBackground;
  final Color primaryPurple;
  final String transcript; // Store the transcript

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transcript',
                style: TextStyle(
                  color: primaryPurple,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                //transcript, //?will use this variable during AI speech transcription feature implemented
                '''
                  Good morning. Look at the person to your left. Now, look to your right. Each of you, and every person in this room, carries with you an invisible birthright. 
                  It's not a passport, it's not a bank account—it's something more fundamental. It's a set of inherent rights, simply because you are a human being.
                  This idea—that we all possess basic, inalienable rights—is one of the most powerful and revolutionary concepts in human history. But what are these 'human rights'? 
                  They aren't physical objects; they are a framework, a promise. A promise of dignity, of fairness, of a life free from fear and want. 
                  Today, we're going to explore what that promise really means, why it matters to you, right here, right now, and why it remains a battle we must all fight.
                ''',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
