import 'dart:math';
import 'package:voquadro/src/ai-integration/ollama_service.dart';

/// Fallback service that provides static questions when Ollama is not available
class FallbackQuestionService {
  static const Map<String, List<String>> _topicQuestions = {
    'Technology': [
      'How will AI change education?',
      'Is social media harmful to society?',
      'Should we fear automation?',
      'Can technology solve climate change?',
      'Is privacy dead in the digital age?',
      'Should coding be mandatory in schools?',
      'Will robots replace human workers?',
      'Is virtual reality the future?',
    ],
    'Environment': [
      'Can individuals save the planet?',
      'Is nuclear energy the solution?',
      'Should we ban plastic completely?',
      'Are electric cars truly green?',
      'Should we eat less meat?',
      'Is climate change reversible?',
      'Should we invest in renewable energy?',
      'Can cities be sustainable?',
    ],
    'Education': [
      'Should homework be banned?',
      'Is online learning effective?',
      'Should college be free?',
      'Are standardized tests fair?',
      'Should students choose their subjects?',
      'Is memorization still important?',
      'Should teachers be paid more?',
      'Can technology replace teachers?',
    ],
    'Health': [
      'Should junk food be banned?',
      'Is mental health as important as physical?',
      'Should healthcare be free?',
      'Are vaccines safe for everyone?',
      'Should we legalize all drugs?',
      'Is exercise more important than diet?',
      'Should smoking be completely banned?',
      'Can technology cure all diseases?',
    ],
    'Travel': [
      'Is travel essential for growth?',
      'Should we limit air travel?',
      'Is tourism harmful to local cultures?',
      'Should we explore space instead?',
      'Is virtual travel the future?',
      'Should travel be a human right?',
      'Are travel restrictions necessary?',
      'Can travel change your perspective?',
    ],
    'Food': [
      'Should we all be vegetarian?',
      'Is organic food worth the cost?',
      'Should fast food be banned?',
      'Is cooking a dying art?',
      'Should we eat locally grown food?',
      'Is food waste a global problem?',
      'Should school lunches be healthier?',
      'Can food bring people together?',
    ],
    'Sports': [
      'Should professional athletes be paid less?',
      'Is competition good for children?',
      'Should sports be mandatory in schools?',
      'Are video games real sports?',
      'Should we ban dangerous sports?',
      'Is winning everything in sports?',
      'Should women\'s sports get equal pay?',
      'Can sports unite divided communities?',
    ],
    'Art': [
      'Is art essential for society?',
      'Should art be censored?',
      'Is digital art real art?',
      'Should art be taught in schools?',
      'Can anyone be an artist?',
      'Is art subjective or objective?',
      'Should art be free for everyone?',
      'Can art change the world?',
    ],
    'Music': [
      'Is music a universal language?',
      'Should music be free online?',
      'Is classical music dying?',
      'Should music be taught in schools?',
      'Can music heal emotional wounds?',
      'Is autotune ruining music?',
      'Should musicians be paid more?',
      'Can music bring world peace?',
    ],
    'Science': [
      'Should we fund space exploration?',
      'Is genetic engineering ethical?',
      'Should we clone humans?',
      'Is science the answer to everything?',
      'Should we experiment on animals?',
      'Is artificial intelligence dangerous?',
      'Should we terraform Mars?',
      'Can science solve world hunger?',
    ],
    'Business': [
      'Should businesses prioritize profit or people?',
      'Is remote work the future?',
      'Should we raise the minimum wage?',
      'Is capitalism the best system?',
      'Should companies be more transparent?',
      'Is entrepreneurship for everyone?',
      'Should we regulate big tech?',
      'Can small businesses compete?',
    ],
    'Politics': [
      'Should voting be mandatory?',
      'Is democracy the best system?',
      'Should politicians have term limits?',
      'Is political correctness helpful?',
      'Should we lower the voting age?',
      'Is social media ruining politics?',
      'Should we have more women in politics?',
      'Can politics solve social problems?',
    ],
    'Social Media': [
      'Is social media connecting or dividing us?',
      'Should social media be regulated?',
      'Is social media addiction real?',
      'Should we ban social media for kids?',
      'Is social media ruining relationships?',
      'Should we have digital detox days?',
      'Is social media free speech?',
      'Can social media change the world?',
    ],
    'Climate Change': [
      'Is climate change the biggest threat?',
      'Should we declare climate emergency?',
      'Is it too late to stop climate change?',
      'Should we tax carbon emissions?',
      'Is renewable energy the solution?',
      'Should we eat less meat for climate?',
      'Is climate change natural or man-made?',
      'Can technology save us from climate change?',
    ],
    'Artificial Intelligence': [
      'Will AI replace human jobs?',
      'Is AI dangerous for humanity?',
      'Should we regulate AI development?',
      'Can AI be creative?',
      'Is AI the future of education?',
      'Should we fear AI consciousness?',
      'Can AI solve world problems?',
      'Is AI making us lazy?',
    ],
    'Space Exploration': [
      'Should we colonize Mars?',
      'Is space exploration worth the cost?',
      'Should we search for alien life?',
      'Is space tourism ethical?',
      'Should we mine asteroids?',
      'Is space the final frontier?',
      'Should we build space stations?',
      'Can humans survive in space?',
    ],
    'Mental Health': [
      'Is mental health as important as physical?',
      'Should therapy be free?',
      'Is social media bad for mental health?',
      'Should we talk more about mental health?',
      'Is medication the answer to depression?',
      'Should schools teach mental health?',
      'Is mental health a choice?',
      'Can exercise cure mental illness?',
    ],
    'Remote Work': [
      'Is remote work the future?',
      'Should all jobs be remote?',
      'Is remote work less productive?',
      'Should we have hybrid work models?',
      'Is remote work bad for team building?',
      'Should remote workers be paid less?',
      'Is remote work good for work-life balance?',
      'Can remote work save the environment?',
    ],
    'Sustainable Living': [
      'Should we all live sustainably?',
      'Is sustainable living expensive?',
      'Should we ban single-use plastics?',
      'Is zero waste possible?',
      'Should we all grow our own food?',
      'Is sustainable fashion worth it?',
      'Should we use renewable energy only?',
      'Can individuals make a difference?',
    ],
    'Digital Privacy': [
      'Is privacy dead in the digital age?',
      'Should we have the right to be forgotten?',
      'Is data the new oil?',
      'Should companies protect our data?',
      'Is encryption a human right?',
      'Should we ban facial recognition?',
      'Is online privacy an illusion?',
      'Can we trust tech companies?',
    ],
    'LGBT': [
      'Should LGBT rights be universal?',
      'Is coming out still necessary?',
      'Should schools teach LGBT history?',
      'Is representation in media important?',
      'Should we have pride parades?',
      'Is acceptance growing worldwide?',
      'Should LGBT people have equal rights?',
      'Can love overcome prejudice?',
    ],
    'Abortion': [
      'Should abortion be a woman\'s choice?',
      'Is abortion a human right?',
      'Should we have abortion restrictions?',
      'Is life sacred from conception?',
      'Should men have a say in abortion?',
      'Is abortion healthcare?',
      'Should we teach about abortion?',
      'Can we find common ground?',
    ],
    'Gun Control': [
      'Should we have stricter gun laws?',
      'Is the right to bear arms absolute?',
      'Should teachers carry guns?',
      'Is gun violence a mental health issue?',
      'Should we ban assault weapons?',
      'Is self-defense a human right?',
      'Should we have background checks?',
      'Can we prevent mass shootings?',
    ],
  };

  /// Generates a random question for the given topic
  static String getRandomQuestion(String topic) {
    final questions = _topicQuestions[topic] ?? _topicQuestions['Technology']!;
    final random = Random();
    return questions[random.nextInt(questions.length)];
  }

  /// Gets all available topics
  static List<String> getAvailableTopics() {
    return _topicQuestions.keys.toList();
  }

  /// Checks if a topic has questions available
  static bool hasQuestionsForTopic(String topic) {
    return _topicQuestions.containsKey(topic) &&
        _topicQuestions[topic]!.isNotEmpty;
  }

  /// Creates a SpeechSession with a fallback question
  static SpeechSession createFallbackSession(String topic) {
    final question = getRandomQuestion(topic);
    return SpeechSession(
      topic: topic,
      generatedQuestion: question,
      timestamp: DateTime.now(),
    );
  }
}
