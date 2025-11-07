import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/src/models/session_model.dart';

// Placeholder for the service!

final List<Session> placeholderSessions = [
  Session(
    id: 'sid_001',
    modeId: 'impromptu',
    modeEXP: 25.0,
    paceControlEXP: 5.5,
    fillerControlEXP: 5.5,
    topic: 'Artificial Intelligence',
    generatedQuestion: 'Discuss the ethical implications of advanced AI.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    paceControl: 4.5,
    fillerControl: 4.2,
    overallRating: 4.6,
    contentClarityScore: 4.8,
    clarityStructureScore: 4.5,
    transcript:
        'Good morning. Today, I will discuss the ethical implications of advanced AI. Firstly, there is the issue of job displacement...',
    feedback:
        'Excellent pace and clear structure. You articulated your points very well. Try to reduce the use of "so" at the start of sentences.',
  ),
  Session(
    id: 'sid_002',
    modeId: 'prepared',
    modeEXP: 35.0,
    paceControlEXP: 7.0,
    fillerControlEXP: 8.0,
    topic: 'Climate Change',
    generatedQuestion: 'Present the case for renewable energy investment.',
    timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
    paceControl: 3.8,
    fillerControl: 2.9,
    overallRating: 3.5,
    contentClarityScore: 3.2,
    clarityStructureScore: 3.9,
    transcript:
        'Um, so, climate change is a... a really big problem. We need to invest in solar and wind, you know? It is very important for the future because...',
    feedback:
        'Your content was relevant, but you spoke a bit too quickly and used several filler words like "um" and "so". Focusing on a slower pace next time will greatly improve clarity.',
  ),
  Session(
    id: 'sid_003',
    modeId: 'impromptu',
    modeEXP: 25.0,
    paceControlEXP: 6.0,
    fillerControlEXP: 4.0,
    topic: 'Space Exploration',
    generatedQuestion: 'Is the money spent on space exploration justifiable?',
    timestamp: DateTime.now().subtract(const Duration(days: 5)),
    paceControl: 4.8,
    fillerControl: 3.5,
    overallRating: 4.1,
    contentClarityScore: 4.0,
    clarityStructureScore: 4.3,
    transcript:
        'That is an interesting question. I believe the investment in space exploration is absolutely justifiable. The technological advancements alone, like GPS and medical imaging, have provided immense value back to society.',
    feedback:
        'Great job handling an impromptu topic! Your pace was perfect. A few filler words were noted, but the overall structure was solid.',
  ),
  Session(
    id: 'sid_004',
    modeId: 'interview',
    modeEXP: 50.0,
    paceControlEXP: 10.0,
    fillerControlEXP: 10.0,
    topic: 'Job Interview Practice',
    generatedQuestion: 'Tell me about a time you faced a challenge at work.',
    timestamp: DateTime.now().subtract(const Duration(days: 10, hours: 2)),
    paceControl: 4.9,
    fillerControl: 4.8,
    overallRating: 4.9,
    contentClarityScore: 4.9,
    clarityStructureScore: 5.0,
    transcript:
        'Certainly. In my previous role, we faced a tight deadline for a project with unexpected scope changes. I took the initiative to reorganize the workflow, delegate tasks effectively, and communicate transparently with the client. As a result, we delivered the project successfully on time.',
    feedback:
        'Outstanding performance. You used the STAR method effectively, your pacing was professional, and your response was free of filler words. A textbook answer!',
  ),
  Session(
    id: 'sid_005',
    modeId: 'prepared',
    modeEXP: 35.0,
    paceControlEXP: 4.0,
    fillerControlEXP: 6.5,
    topic: 'Mental Health Awareness',
    generatedQuestion: 'Explain the importance of work-life balance.',
    timestamp: DateTime.now().subtract(const Duration(days: 12)),
    paceControl: 3.2,
    fillerControl: 4.4,
    overallRating: 3.8,
    contentClarityScore: 4.1,
    clarityStructureScore: 3.6,
    transcript:
        'Work-life balance is crucial. It basically helps prevent burnout and improves mental well-being. Companies should, like, encourage employees to take breaks.',
    feedback:
        'A good start with relevant points. The message could be stronger with a more organized structure and formal language. Your pace was a little rushed in the beginning.',
  ),
];

List<Session> getModeSessionHistory(AppMode mode) {
  return placeholderSessions;
}
